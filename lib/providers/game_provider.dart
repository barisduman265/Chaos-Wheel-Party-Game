import 'dart:math';

import 'package:chaos_wheel/models/game_state.dart';
import 'package:chaos_wheel/models/player.dart';
import 'package:chaos_wheel/models/prompt_models.dart';
import 'package:chaos_wheel/services/app_localization_service.dart';
import 'package:chaos_wheel/services/game_logic_service.dart';
import 'package:chaos_wheel/services/chaos_audio_service.dart';
import 'package:chaos_wheel/services/interstitial_ad_manager.dart';
import 'package:chaos_wheel/services/premium_purchase_service.dart';
import 'package:chaos_wheel/services/prompt_engine.dart';
import 'package:chaos_wheel/services/prompt_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({
    GameLogicService? gameLogicService,
    PromptEngine? promptEngine,
    PremiumPurchaseService? premiumPurchaseService,
  }) : _gameLogicService = gameLogicService ?? GameLogicService(),
       _promptEngine = promptEngine ?? PromptEngine(),
       _premiumPurchaseService =
           premiumPurchaseService ?? PremiumPurchaseService() {
    _loadPremiumEntitlement();
    _premiumPurchaseService.start(
      onEntitlementGranted: _grantPremiumEntitlement,
      onError: (message) {
        _premiumPurchaseInProgress = false;
        _premiumPurchaseMessage = message;
        notifyListeners();
      },
    );
    _restorePremiumEntitlementOnStartup();
    _loadUserSettings();
    _loadPremiumProductDetails();
    _syncAudioSettings();
  }

  static const _premiumEntitlementKey = 'chaos_premium_lifetime';
  static const _legacyPremiumEntitlementKey = 'chaos_wheel_lifetime_premium';
  static const _soundEnabledKey = 'settings_sound_enabled';
  static const _vibrationEnabledKey = 'settings_vibration_enabled';
  static const _backgroundMusicEnabledKey = 'settings_background_music';
  static const _reduceAnimationsEnabledKey = 'settings_reduce_animations';
  static const _drinkingPromptsEnabledKey = 'settings_drinking_prompts';
  static const _extremePromptsEnabledKey = 'settings_extreme_prompts';
  static const _promptLanguageKey = 'settings_prompt_language';

  final GameLogicService _gameLogicService;
  final PromptEngine _promptEngine;
  final PremiumPurchaseService _premiumPurchaseService;
  final Random _random = Random();

  /// Probability that being targeted grants a revenge-back in revenge mode.
  /// Revenge no longer triggers on every target — it now lands randomly.
  static const double _revengeChance = 0.35;

  /// Free players see the premium pop-up once every this many completed turns.
  static const int _upsellEveryTurns = 3;
  int _turnsSinceUpsell = 0;

  /// Free players see a full-screen interstitial ad once every this many turns.
  static const int _interstitialEveryTurns = 4;
  int _turnsSinceInterstitial = 0;

  /// Counts a completed turn and reports whether the in-game premium pop-up
  /// should be shown now. Returns false for premium users.
  bool consumeUpsellTrigger() {
    if (_isPremiumUser) {
      return false;
    }
    _turnsSinceUpsell++;
    if (_turnsSinceUpsell < _upsellEveryTurns) {
      return false;
    }
    _turnsSinceUpsell = 0;
    return true;
  }

  /// Counts a completed turn and reports whether an interstitial ad should be
  /// shown now (every [_interstitialEveryTurns] turns). False for premium users.
  bool consumeInterstitialTrigger() {
    if (_isPremiumUser) {
      return false;
    }
    _turnsSinceInterstitial++;
    if (_turnsSinceInterstitial < _interstitialEveryTurns) {
      return false;
    }
    _turnsSinceInterstitial = 0;
    return true;
  }

  /// Shows a full-screen interstitial ad unless the player owns premium.
  void showInterstitial() {
    if (_isPremiumUser) {
      return;
    }
    InterstitialAdManager.instance.show();
  }

  GameStateModel _state = const GameStateModel();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = true;
  bool _backgroundMusicEnabled = true;
  bool _reduceAnimationsEnabled = false;
  bool _drinkingPromptsEnabled = true;
  bool _extremePromptsEnabled = true;
  bool _gamePaused = false;
  bool _isPremiumUser = false;
  bool _premiumPurchaseInProgress = false;
  String? _premiumPurchaseMessage;
  String? _premiumPriceLabel;
  bool _defaultBalanceRuleEnabled = true;
  bool _defaultRandomButtonEnabled = true;
  String _promptLanguage = 'English';
  String? _pendingSpinPlayerId;

  GameStateModel get state => _state;
  List<Player> get players => _state.players;
  Player? get selectedPlayer => _state.selectedPlayer;
  ContentPrompt? get currentPrompt => _state.currentPrompt;
  PromptVibeMode get vibeMode => _state.vibeMode;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get backgroundMusicEnabled => _backgroundMusicEnabled;
  bool get reduceAnimationsEnabled => _reduceAnimationsEnabled;
  bool get drinkingPromptsEnabled => _drinkingPromptsEnabled;
  bool get extremePromptsEnabled => _extremePromptsEnabled;
  bool get gamePaused => _gamePaused;
  bool get isPremiumUser => _isPremiumUser;
  bool get premiumPurchaseInProgress => _premiumPurchaseInProgress;
  String? get premiumPurchaseMessage => _premiumPurchaseMessage;
  String? get premiumPriceLabel => _premiumPriceLabel;
  String get promptLanguage => _promptLanguage;
  bool get defaultBalanceRuleEnabled => _defaultBalanceRuleEnabled;
  bool get defaultRandomButtonEnabled => _defaultRandomButtonEnabled;
  bool get revengeModeEnabled => _state.revengeModeEnabled;
  bool get isEvilModeActive => _state.vibeMode == PromptVibeMode.evil;

  String l(String key) {
    return AppLocalizationService.text(key, _promptLanguage);
  }

  String lf(String key, Map<String, Object> values) {
    return AppLocalizationService.format(key, _promptLanguage, values);
  }

  /// Prompt text translated into the current language, falling back to the
  /// English source text when a translation is not yet available.
  String localizedPromptText(ContentPrompt prompt) {
    return PromptLocalizations.textFor(prompt.id, _promptLanguage) ??
        prompt.text;
  }

  int calculatePassRights(int roundCount) {
    return _gameLogicService.calculatePassRights(roundCount);
  }

  int calculateTargetRights(int roundCount) {
    return _gameLogicService.calculateTargetRights(roundCount);
  }

  int noEscapeRoundCountFor(int totalRounds) {
    return switch (totalRounds) {
      15 => 5,
      25 => 8,
      40 => 10,
      _ => (totalRounds * 0.25).ceil().clamp(3, 10),
    };
  }

  int noEscapeStartRoundFor(int totalRounds) {
    if (totalRounds <= 0) {
      return 0;
    }
    return totalRounds - noEscapeRoundCountFor(totalRounds) + 1;
  }

  /// The active game's No Escape start round: a custom value when the host set
  /// one (custom game), otherwise the automatic formula.
  int get effectiveNoEscapeStartRound {
    if (_state.noEscapeStartRound > 0) {
      return _state.noEscapeStartRound;
    }
    return noEscapeStartRoundFor(_state.totalRounds);
  }

  /// How many prompt changes a player gets each turn in the active game.
  int get changeRightsPerTurn => _state.changeRightsPerTurn;

  bool get isNoEscapeActive {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return false;
    }
    return _state.currentRound >= effectiveNoEscapeStartRound;
  }

  bool get isNoEscapeStartRound {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return false;
    }
    return _state.currentRound == effectiveNoEscapeStartRound;
  }

  bool get isFinalSpin {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return false;
    }
    return _state.currentRound > _state.totalRounds - 3;
  }

  bool randomShouldChooseDare() {
    if (truthLocked) {
      return true;
    }
    if (isNoEscapeActive) {
      return _gameLogicService.rollChance(0.70);
    }
    return _gameLogicService.rollChance(0.50);
  }

  String? addPlayer(String rawName) {
    final name = rawName.trim();
    if (name.isEmpty) {
      return l('enterPlayerName');
    }

    final duplicate = players.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      return l('playerNamesUnique');
    }

    final player = Player(
      id: '${DateTime.now().microsecondsSinceEpoch}-${name.toLowerCase()}',
      name: name,
    );

    _state = _state.copyWith(players: [...players, player]);
    notifyListeners();
    return null;
  }

  void removePlayer(String id) {
    final removingSelected = selectedPlayer?.id == id;
    if (_pendingSpinPlayerId == id) {
      _pendingSpinPlayerId = null;
    }
    _state = _state.copyWith(
      players: players
          .where((player) => player.id != id)
          .toList(growable: false),
      clearSelectedPlayer: removingSelected,
    );
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    _saveSetting(_soundEnabledKey, value);
    _syncAudioSettings();
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    _saveSetting(_vibrationEnabledKey, value);
    _syncAudioSettings();
    notifyListeners();
  }

  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
  }

  void setBackgroundMusicEnabled(bool value) {
    _backgroundMusicEnabled = value;
    _saveSetting(_backgroundMusicEnabledKey, value);
    _syncAudioSettings();
    notifyListeners();
  }

  void setReduceAnimationsEnabled(bool value) {
    _reduceAnimationsEnabled = value;
    _saveSetting(_reduceAnimationsEnabledKey, value);
    notifyListeners();
  }

  void setDrinkingPromptsEnabled(bool value) {
    _drinkingPromptsEnabled = value;
    _saveSetting(_drinkingPromptsEnabledKey, value);
    notifyListeners();
  }

  void setExtremePromptsEnabled(bool value) {
    _extremePromptsEnabled = value;
    _saveSetting(_extremePromptsEnabledKey, value);
    if (!value && _state.vibeMode == PromptVibeMode.evil) {
      _state = _state.copyWith(vibeMode: PromptVibeMode.unhinged);
    }
    notifyListeners();
  }

  void setPromptLanguage(String value) {
    if (!AppLocalizationService.supportedLanguages.contains(value)) {
      return;
    }
    _promptLanguage = value;
    _saveSetting(_promptLanguageKey, value);
    notifyListeners();
  }

  Future<void> playSfx(ChaosSfx sfx) {
    return ChaosAudioService.instance.play(sfx);
  }

  /// Fires only the haptic for [sfx] (no sound).
  void haptic(ChaosSfx sfx) {
    ChaosAudioService.instance.haptic(sfx);
  }

  Future<void> playHomeMusic() {
    return ChaosAudioService.instance.playHomeMusic();
  }

  Future<void> playNoEscapeMusic() {
    return ChaosAudioService.instance.playNoEscapeMusic();
  }

  Future<void> stopMusic() {
    return ChaosAudioService.instance.stopMusic();
  }

  void setGamePaused(bool value) {
    _gamePaused = value;
    notifyListeners();
  }

  Future<String?> purchasePremiumLifetime() async {
    if (_isPremiumUser || _premiumPurchaseInProgress) {
      return null;
    }

    _premiumPurchaseInProgress = true;
    _premiumPurchaseMessage = null;
    notifyListeners();

    final result = await _premiumPurchaseService.buyLifetime();
    if (result == PremiumPurchaseStartResult.started) {
      return null;
    }

    // In debug builds the device store is usually unavailable (e.g. Flutter
    // web debug), which would make it impossible to exercise premium features.
    // Grant the entitlement locally so EVIL mode, Revenge and premium prompts
    // can be tested. Release builds keep the real store purchase flow.
    if (kDebugMode && result == PremiumPurchaseStartResult.storeUnavailable) {
      await _grantPremiumEntitlement();
      return null;
    }

    _premiumPurchaseInProgress = false;
    _premiumPurchaseMessage = switch (result) {
      PremiumPurchaseStartResult.storeUnavailable => l('storeUnavailable'),
      PremiumPurchaseStartResult.productUnavailable => l(
        'premiumNotConfigured',
      ),
      PremiumPurchaseStartResult.failedToStart => l('purchaseFailedToStart'),
      PremiumPurchaseStartResult.started => null,
    };
    notifyListeners();
    return _premiumPurchaseMessage;
  }

  Future<void> restorePremiumSilently() async {
    await _premiumPurchaseService.restoreSilently();
    await _loadPremiumEntitlement();
  }

  Future<void> _restorePremiumEntitlementOnStartup() async {
    await _loadPremiumEntitlement();
    if (_isPremiumUser) {
      return;
    }
    await _premiumPurchaseService.restoreSilently();
  }

  Future<void> _loadPremiumProductDetails() async {
    final product = await _premiumPurchaseService.queryLifetimeProduct();
    if (product == null) {
      return;
    }
    _premiumPriceLabel = product.price;
    notifyListeners();
  }

  Future<void> _grantPremiumEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumEntitlementKey, true);
    await prefs.remove(_legacyPremiumEntitlementKey);
    _isPremiumUser = true;
    _premiumPurchaseInProgress = false;
    _premiumPurchaseMessage = null;
    notifyListeners();
  }

  Future<void> _loadPremiumEntitlement() async {
    final prefs = await SharedPreferences.getInstance();
    final legacyEntitlement =
        prefs.getBool(_legacyPremiumEntitlementKey) ?? false;
    if (legacyEntitlement) {
      await prefs.setBool(_premiumEntitlementKey, true);
      await prefs.remove(_legacyPremiumEntitlementKey);
    }
    final entitlement =
        (prefs.getBool(_premiumEntitlementKey) ?? false) || legacyEntitlement;
    if (_isPremiumUser == entitlement) {
      return;
    }
    _isPremiumUser = entitlement;
    notifyListeners();
  }

  @override
  void dispose() {
    _premiumPurchaseService.dispose();
    ChaosAudioService.instance.dispose();
    super.dispose();
  }

  void setDefaultBalanceRuleEnabled(bool value) {
    _defaultBalanceRuleEnabled = value;
    notifyListeners();
  }

  void setDefaultRandomButtonEnabled(bool value) {
    _defaultRandomButtonEnabled = value;
    notifyListeners();
  }

  void initializeGame({
    required int roundCount,
    required bool balanceRuleEnabled,
    required bool randomButtonEnabled,
    required bool revengeModeEnabled,
    required PromptVibeMode vibeMode,
    int? customPassRights,
    int? customTargetRights,
    int? customNoEscapeStartRound,
    int? customChangeRights,
  }) {
    final initializedPlayers = _gameLogicService
        .initializeGame(players, roundCount)
        .map((player) {
          var adjusted = player;
          if (customPassRights != null || customTargetRights != null) {
            adjusted = adjusted.copyWith(
              passRights: customPassRights ?? adjusted.passRights,
              targetRights: customTargetRights ?? adjusted.targetRights,
            );
          }
          if (vibeMode != PromptVibeMode.evil) {
            return adjusted;
          }
          return adjusted.copyWith(targetRights: adjusted.targetRights + 1);
        })
        .toList(growable: false);
    _state = GameStateModel(
      players: initializedPlayers,
      totalRounds: roundCount,
      currentRound: 1,
      balanceRuleEnabled: balanceRuleEnabled,
      randomButtonEnabled: randomButtonEnabled,
      revengeModeEnabled: revengeModeEnabled && _isPremiumUser,
      vibeMode: vibeMode,
      usedPromptIds: const {},
      noEscapeStartRound: customNoEscapeStartRound ?? 0,
      changeRightsPerTurn: customChangeRights ?? 1,
    );
    _pendingSpinPlayerId = null;
    _gamePaused = false;
    if (vibeMode == PromptVibeMode.evil) {
      playSfx(ChaosSfx.evilActivated);
    }
    notifyListeners();
  }

  Player? prepareSpinSelection() {
    if (_state.isSpinning || players.isEmpty || selectedPlayer != null) {
      return null;
    }

    final chosenPlayer = _gameLogicService.selectWeightedRandomPlayer(players);
    _pendingSpinPlayerId = chosenPlayer.id;
    _state = _state.copyWith(isSpinning: true);
    notifyListeners();
    return chosenPlayer;
  }

  String completeSpinSelection() {
    final pendingId = _pendingSpinPlayerId;
    if (pendingId == null) {
      return '';
    }

    final updatedPlayers = players
        .map((player) {
          if (player.id != pendingId) {
            return player;
          }
          return player.copyWith(pickedCount: player.pickedCount + 1);
        })
        .toList(growable: false);

    final selected = updatedPlayers.firstWhere(
      (player) => player.id == pendingId,
    );
    _pendingSpinPlayerId = null;
    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: selected,
      isSpinning: false,
    );
    notifyListeners();

    return lf('playerIsPicked', {'player': selected.name});
  }

  ContentPrompt generatePrompt(PromptType type) {
    final prompt = _promptEngine.generate(
      type: type,
      mode: _state.vibeMode,
      currentRound: _state.currentRound,
      totalRounds: _state.totalRounds,
      playerCount: players.length,
      noEscape: isNoEscapeActive,
      premiumUnlocked: _isPremiumUser,
      drinkingPromptsEnabled: _drinkingPromptsEnabled,
      extremePromptsEnabled: _extremePromptsEnabled,
      usedPromptIds: _state.usedPromptIds,
    );

    _state = _state.copyWith(
      currentPrompt: prompt,
      usedPromptIds: {..._state.usedPromptIds, prompt.id},
    );
    notifyListeners();
    return prompt;
  }

  void setVibeMode(PromptVibeMode mode) {
    if (_state.vibeMode == mode) {
      return;
    }
    _state = _state.copyWith(vibeMode: mode);
    notifyListeners();
  }

  PromptVibeMode toneDownChaos() {
    final softened = switch (_state.vibeMode) {
      PromptVibeMode.evil => PromptVibeMode.unhinged,
      PromptVibeMode.unhinged => PromptVibeMode.spicy,
      PromptVibeMode.spicy => PromptVibeMode.cozy,
      PromptVibeMode.cozy => PromptVibeMode.cozy,
    };
    setVibeMode(softened);
    return softened;
  }

  void giveExtraShot(String playerId) {
    final updatedPlayers = players
        .map((player) {
          if (player.id != playerId) {
            return player;
          }
          return player.copyWith(passRights: player.passRights + 1);
        })
        .toList(growable: false);
    final updatedSelected = selectedPlayer?.id == playerId
        ? updatedPlayers.firstWhere((player) => player.id == playerId)
        : selectedPlayer;
    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: updatedSelected,
    );
    notifyListeners();
  }

  String skipCurrentPlayer() {
    final player = selectedPlayer;
    if (player == null) {
      return l('spinFirstSkip');
    }
    _finishRound();
    return lf('playerSkipped', {'player': player.name});
  }

  String skipRound() {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return l('noActiveRound');
    }
    _pendingSpinPlayerId = null;
    _finishRound();
    return l('roundSkipped');
  }

  String reshuffleWheel() {
    if (_state.isSpinning) {
      return l('letWheelFinish');
    }
    _pendingSpinPlayerId = null;
    _state = _state.copyWith(
      isSpinning: false,
      clearSelectedPlayer: true,
      clearCurrentPrompt: true,
    );
    notifyListeners();
    return l('wheelResetSpinAgain');
  }

  Player? randomizePicker() {
    if (_state.isSpinning || players.isEmpty) {
      return null;
    }

    final chosenPlayer = _gameLogicService.selectWeightedRandomPlayer(players);
    final updatedPlayers = players
        .map((player) {
          if (player.id != chosenPlayer.id) {
            return player;
          }
          return player.copyWith(pickedCount: player.pickedCount + 1);
        })
        .toList(growable: false);
    final selected = updatedPlayers.firstWhere(
      (player) => player.id == chosenPlayer.id,
    );
    _pendingSpinPlayerId = null;
    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: selected,
      isSpinning: false,
    );
    notifyListeners();
    return selected;
  }

  void endGameNow() {
    _pendingSpinPlayerId = null;
    _state = _state.copyWith(
      currentRound: _state.totalRounds + 1,
      isSpinning: false,
      clearSelectedPlayer: true,
      clearCurrentPrompt: true,
    );
    notifyListeners();
  }

  bool get truthLocked {
    final player = selectedPlayer;
    if (player == null) {
      return false;
    }
    return isTruthLockedFor(player);
  }

  bool isTruthLockedFor(Player player) {
    if (!_state.balanceRuleEnabled) return false;
    return player.truthStreak >= 2;
  }

  Player? revengeTargetForSelectedPlayer() {
    final player = selectedPlayer;
    if (player == null ||
        !_state.revengeModeEnabled ||
        _state.revengeUsedThisRound ||
        isNoEscapeActive ||
        !player.revengeAvailable ||
        player.revengeTargetPlayerId == null) {
      return null;
    }

    for (final candidate in players) {
      if (candidate.id == player.revengeTargetPlayerId) {
        return candidate;
      }
    }
    return null;
  }

  String completeSelectedChallenge({required PromptType type}) {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }
    if (type == PromptType.truth && truthLocked) {
      return l('truthLockedMandatory');
    }

    final updated = type == PromptType.truth
        ? _gameLogicService.chooseTruth(player)
        : _gameLogicService.chooseDare(player);
    _replaceSelectedPlayer(updated);
    notifyListeners();

    if (type == PromptType.truth && updated.truthStreak == 2) {
      return l('carefulTruthLocks');
    }
    return lf('playerChose', {
      'player': updated.name,
      'choice': l(type == PromptType.truth ? 'truth' : 'dare'),
    });
  }

  void finishCompletedChallenge() {
    final player = selectedPlayer;
    if (player != null && player.revengeAvailable) {
      _replaceSelectedPlayer(
        player.copyWith(revengeAvailable: false, clearRevengeTarget: true),
      );
    }
    _finishRound();
  }

  String activateRevenge() {
    final revengePlayer = selectedPlayer;
    final target = revengeTargetForSelectedPlayer();
    if (revengePlayer == null || target == null) {
      return '';
    }

    final updatedPlayers = players
        .map((player) {
          if (player.id == revengePlayer.id) {
            return player.copyWith(
              revengeAvailable: false,
              clearRevengeTarget: true,
            );
          }
          if (player.id == target.id) {
            return player.copyWith(pickedCount: player.pickedCount + 1);
          }
          return player;
        })
        .toList(growable: false);

    final newSelected = updatedPlayers.firstWhere(
      (player) => player.id == target.id,
    );
    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: newSelected,
      revengeUsedThisRound: true,
      targetChainCount: _state.targetChainCount + 1,
    );
    notifyListeners();

    return lf('sentItBack', {
      'source': revengePlayer.name,
      'target': newSelected.name,
    });
  }

  String chooseTruth() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }
    if (truthLocked) {
      return l('truthLockedMandatory');
    }

    final updated = _gameLogicService
        .chooseTruth(player)
        .copyWith(revengeAvailable: false, clearRevengeTarget: true);
    final message = updated.truthStreak == 2
        ? l('carefulTruthLocks')
        : lf('playerChose', {'player': updated.name, 'choice': l('truth')});
    _replaceSelectedPlayer(updated);
    _finishRound();
    return message;
  }

  String chooseDare() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }

    final updated = _gameLogicService
        .chooseDare(player)
        .copyWith(revengeAvailable: false, clearRevengeTarget: true);
    _replaceSelectedPlayer(updated);
    _finishRound();
    return lf('playerChose', {'player': updated.name, 'choice': l('dare')});
  }

  String chooseRandom() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }

    final result = _gameLogicService.chooseRandom(
      player,
      truthLocked: truthLocked,
      dareChance: isNoEscapeActive ? 0.70 : 0.50,
    );
    _replaceSelectedPlayer(
      result.player.copyWith(revengeAvailable: false, clearRevengeTarget: true),
    );
    _finishRound();
    return lf('randomChose', {
      'choice': l(result.choice == 'Truth' ? 'truth' : 'dare'),
    });
  }

  String usePass() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }
    if (isNoEscapeActive) {
      return l('noEscapeShotsLocked');
    }
    if (player.passRights <= 0) {
      return l('noShotsLeft');
    }

    final updated = _gameLogicService
        .usePass(player)
        .copyWith(revengeAvailable: false, clearRevengeTarget: true);
    _replaceSelectedPlayer(updated);
    _finishRound();
    return l('shotUsed');
  }

  String? canUseTarget() {
    final player = selectedPlayer;
    if (player == null) {
      return l('spinWheelFirst');
    }
    if (isNoEscapeActive) {
      return l('noEscapeTargetLocked');
    }
    if (player.targetRights <= 0) {
      return l('noTargetsLeft');
    }
    if (_state.targetChainCount >= _state.maxTargetChainsPerRound) {
      return l('targetChainLimit');
    }
    return null;
  }

  String selectTarget(String targetPlayerId) {
    final current = selectedPlayer;
    if (current == null) {
      return '';
    }

    final actingPlayer = _gameLogicService.useTarget(current);
    final updatedPlayers = players
        .map((player) {
          if (player.id == current.id) {
            return actingPlayer;
          }
          if (player.id == targetPlayerId) {
            final targeted = _gameLogicService
                .receiveTarget(player)
                .copyWith(pickedCount: player.pickedCount + 1);
            if (!_state.revengeModeEnabled ||
                isNoEscapeActive ||
                _state.revengeUsedThisRound ||
                _random.nextDouble() >= _revengeChance) {
              return targeted;
            }
            return targeted.copyWith(
              revengeAvailable: true,
              revengeTargetPlayerId: current.id,
            );
          }
          return player;
        })
        .toList(growable: false);

    final newSelected = updatedPlayers.firstWhere(
      (player) => player.id == targetPlayerId,
    );
    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: newSelected,
      targetChainCount: _state.targetChainCount + 1,
    );
    notifyListeners();

    return lf('playerTargetedTarget', {
      'source': current.name,
      'target': newSelected.name,
    });
  }

  void resetGameSamePlayers() {
    _state = _gameLogicService
        .resetGameSamePlayers(_state)
        .copyWith(
          vibeMode: _state.vibeMode,
          usedPromptIds: const {},
          revengeModeEnabled: _state.revengeModeEnabled,
          clearCurrentPrompt: true,
        );
    _pendingSpinPlayerId = null;
    _gamePaused = false;
    notifyListeners();
  }

  void startNewGame() {
    _state = _gameLogicService
        .startNewGame(_state)
        .copyWith(
          balanceRuleEnabled: _defaultBalanceRuleEnabled,
          randomButtonEnabled: _defaultRandomButtonEnabled,
          revengeModeEnabled: false,
          usedPromptIds: const {},
          clearCurrentPrompt: true,
        );
    _pendingSpinPlayerId = null;
    _gamePaused = false;
    notifyListeners();
  }

  Future<void> resetAppData() async {
    _state = const GameStateModel();
    _soundEnabled = true;
    _vibrationEnabled = true;
    _darkModeEnabled = true;
    _backgroundMusicEnabled = true;
    _reduceAnimationsEnabled = false;
    _drinkingPromptsEnabled = true;
    _extremePromptsEnabled = true;
    _gamePaused = false;
    _promptLanguage = 'English';
    _defaultBalanceRuleEnabled = true;
    _defaultRandomButtonEnabled = true;
    _pendingSpinPlayerId = null;
    await _syncAudioSettings();
    notifyListeners();

    // Privacy: wipe persisted settings from the device. Player names and
    // round stats live only in memory and are already cleared above. The
    // premium entitlement is a paid purchase and is intentionally preserved.
    final prefs = await SharedPreferences.getInstance();
    for (final key in const <String>[
      _soundEnabledKey,
      _vibrationEnabledKey,
      _backgroundMusicEnabledKey,
      _reduceAnimationsEnabledKey,
      _drinkingPromptsEnabledKey,
      _extremePromptsEnabledKey,
      _promptLanguageKey,
      _musicDefaultMigratedKey,
    ]) {
      await prefs.remove(key);
    }
  }

  static const _musicDefaultMigratedKey = 'settings_music_default_v2';

  Future<void> _loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? _soundEnabled;
    _vibrationEnabled =
        prefs.getBool(_vibrationEnabledKey) ?? _vibrationEnabled;

    // Migration: ensure background music default is ON for existing users
    final migrated = prefs.getBool(_musicDefaultMigratedKey) ?? false;
    if (!migrated) {
      await prefs.setBool(_backgroundMusicEnabledKey, true);
      await prefs.setBool(_musicDefaultMigratedKey, true);
      _backgroundMusicEnabled = true;
    } else {
      _backgroundMusicEnabled =
          prefs.getBool(_backgroundMusicEnabledKey) ?? true;
    }
    _reduceAnimationsEnabled =
        prefs.getBool(_reduceAnimationsEnabledKey) ?? _reduceAnimationsEnabled;
    _drinkingPromptsEnabled =
        prefs.getBool(_drinkingPromptsEnabledKey) ?? _drinkingPromptsEnabled;
    _extremePromptsEnabled =
        prefs.getBool(_extremePromptsEnabledKey) ?? _extremePromptsEnabled;
    final language = prefs.getString(_promptLanguageKey);
    if (language != null &&
        AppLocalizationService.supportedLanguages.contains(language)) {
      _promptLanguage = language;
    }
    await _syncAudioSettings();
    notifyListeners();
  }

  Future<void> _saveSetting(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _replaceSelectedPlayer(Player updatedPlayer) {
    final updatedPlayers = players
        .map((player) {
          return player.id == updatedPlayer.id ? updatedPlayer : player;
        })
        .toList(growable: false);

    _state = _state.copyWith(
      players: updatedPlayers,
      selectedPlayer: updatedPlayer,
    );
  }

  void _finishRound() {
    _state = _gameLogicService
        .endRound(_state)
        .copyWith(clearCurrentPrompt: true);
    notifyListeners();
  }

  Future<void> _syncAudioSettings() {
    return ChaosAudioService.instance.configure(
      soundEnabled: _soundEnabled,
      hapticsEnabled: _vibrationEnabled,
      backgroundMusicEnabled: _backgroundMusicEnabled,
    );
  }
}
