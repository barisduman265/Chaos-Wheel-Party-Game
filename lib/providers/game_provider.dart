import 'package:chaos_wheel_party_game/models/game_state.dart';
import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/services/game_logic_service.dart';
import 'package:flutter/material.dart';

class GameProvider extends ChangeNotifier {
  GameProvider({GameLogicService? gameLogicService})
    : _gameLogicService = gameLogicService ?? GameLogicService();

  final GameLogicService _gameLogicService;

  GameStateModel _state = const GameStateModel();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _darkModeEnabled = true;
  bool _defaultBalanceRuleEnabled = true;
  bool _defaultRandomButtonEnabled = true;
  String? _pendingSpinPlayerId;

  GameStateModel get state => _state;
  List<Player> get players => _state.players;
  Player? get selectedPlayer => _state.selectedPlayer;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get defaultBalanceRuleEnabled => _defaultBalanceRuleEnabled;
  bool get defaultRandomButtonEnabled => _defaultRandomButtonEnabled;

  int calculatePassRights(int roundCount) {
    return _gameLogicService.calculatePassRights(roundCount);
  }

  int calculateTargetRights(int roundCount) {
    return _gameLogicService.calculateTargetRights(roundCount);
  }

  int noEscapeRoundCountFor(int totalRounds) {
    return switch (totalRounds) {
      15 => 5,
      25 => 7,
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

  bool get isNoEscapeActive {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return false;
    }
    return _state.currentRound >= noEscapeStartRoundFor(_state.totalRounds);
  }

  bool get isNoEscapeStartRound {
    if (!_state.hasActiveGame || _state.isGameOver) {
      return false;
    }
    return _state.currentRound == noEscapeStartRoundFor(_state.totalRounds);
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
      return 'Enter a player name.';
    }

    final duplicate = players.any(
      (player) => player.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      return 'Player names must be unique.';
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
    _state = _state.copyWith(
      players: players
          .where((player) => player.id != id)
          .toList(growable: false),
    );
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void setVibrationEnabled(bool value) {
    _vibrationEnabled = value;
    notifyListeners();
  }

  void setDarkModeEnabled(bool value) {
    _darkModeEnabled = value;
    notifyListeners();
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
  }) {
    final initializedPlayers = _gameLogicService.initializeGame(
      players,
      roundCount,
    );
    _state = GameStateModel(
      players: initializedPlayers,
      totalRounds: roundCount,
      currentRound: 1,
      balanceRuleEnabled: balanceRuleEnabled,
      randomButtonEnabled: randomButtonEnabled,
    );
    _pendingSpinPlayerId = null;
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

    return '${selected.name} is picked 💀';
  }

  bool get truthLocked {
    final player = selectedPlayer;
    if (player == null) {
      return false;
    }
    return isTruthLockedFor(player);
  }

  bool isTruthLockedFor(Player player) {
    return player.truthStreak >= 2;
  }

  String chooseTruth() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }
    if (truthLocked) {
      return 'Truth locked. Dare is mandatory.';
    }

    final updated = _gameLogicService.chooseTruth(player);
    final message = updated.truthStreak == 2
        ? 'Careful... next time Truth is locked.'
        : '${updated.name} chose Truth.';
    _replaceSelectedPlayer(updated);
    _finishRound();
    return message;
  }

  String chooseDare() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }

    final updated = _gameLogicService.chooseDare(player);
    _replaceSelectedPlayer(updated);
    _finishRound();
    return '${updated.name} chose Dare.';
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
    _replaceSelectedPlayer(result.player);
    _finishRound();
    return 'Random chose: ${result.choice}';
  }

  String usePass() {
    final player = selectedPlayer;
    if (player == null) {
      return '';
    }
    if (isNoEscapeActive) {
      return 'No Escape is active. Drinks are locked.';
    }
    if (player.passRights <= 0) {
      return 'No drinks left.';
    }

    final updated = _gameLogicService.usePass(player);
    _replaceSelectedPlayer(updated);
    _finishRound();
    return 'Drink used. No escape forever.';
  }

  String? canUseTarget() {
    final player = selectedPlayer;
    if (player == null) {
      return 'Spin the wheel first.';
    }
    if (isNoEscapeActive) {
      return 'No Escape is active. Target is locked.';
    }
    if (player.targetRights <= 0) {
      return 'No targets left.';
    }
    if (_state.targetChainCount >= _state.maxTargetChainsPerRound) {
      return 'Target chain limit reached.';
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
            return _gameLogicService
                .receiveTarget(player)
                .copyWith(pickedCount: player.pickedCount + 1);
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

    return '${current.name} targeted ${newSelected.name} 🎯\n${newSelected.name} is now picked 💀';
  }

  void resetGameSamePlayers() {
    _state = _gameLogicService.resetGameSamePlayers(_state);
    _pendingSpinPlayerId = null;
    notifyListeners();
  }

  void startNewGame() {
    _state = _gameLogicService
        .startNewGame(_state)
        .copyWith(
          balanceRuleEnabled: _defaultBalanceRuleEnabled,
          randomButtonEnabled: _defaultRandomButtonEnabled,
        );
    _pendingSpinPlayerId = null;
    notifyListeners();
  }

  void resetAppData() {
    _state = const GameStateModel();
    _soundEnabled = true;
    _vibrationEnabled = true;
    _darkModeEnabled = true;
    _defaultBalanceRuleEnabled = true;
    _defaultRandomButtonEnabled = true;
    _pendingSpinPlayerId = null;
    notifyListeners();
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
    _state = _gameLogicService.endRound(_state);
    notifyListeners();
  }
}
