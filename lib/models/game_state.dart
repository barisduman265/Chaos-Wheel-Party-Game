import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/models/prompt_models.dart';

class GameStateModel {
  const GameStateModel({
    this.players = const [],
    this.totalRounds = 0,
    this.currentRound = 0,
    this.selectedPlayer,
    this.balanceRuleEnabled = true,
    this.randomButtonEnabled = true,
    this.revengeModeEnabled = false,
    this.revengeUsedThisRound = false,
    this.targetChainCount = 0,
    this.maxTargetChainsPerRound = 2,
    this.isSpinning = false,
    this.vibeMode = PromptVibeMode.spicy,
    this.usedPromptIds = const {},
    this.currentPrompt,
    this.noEscapeStartRound = 0,
    this.changeRightsPerTurn = 1,
  });

  final List<Player> players;
  final int totalRounds;
  final int currentRound;
  final Player? selectedPlayer;
  final bool balanceRuleEnabled;
  final bool randomButtonEnabled;
  final bool revengeModeEnabled;
  final bool revengeUsedThisRound;
  final int targetChainCount;
  final int maxTargetChainsPerRound;
  final bool isSpinning;
  final PromptVibeMode vibeMode;
  final Set<String> usedPromptIds;
  final ContentPrompt? currentPrompt;

  /// Round at which No Escape begins. 0 means "use the automatic formula".
  final int noEscapeStartRound;

  /// How many times a player may change their drawn prompt each turn.
  final int changeRightsPerTurn;

  bool get hasActiveGame => totalRounds > 0;
  bool get isGameOver => hasActiveGame && currentRound > totalRounds;

  GameStateModel copyWith({
    List<Player>? players,
    int? totalRounds,
    int? currentRound,
    Player? selectedPlayer,
    bool clearSelectedPlayer = false,
    bool? balanceRuleEnabled,
    bool? randomButtonEnabled,
    bool? revengeModeEnabled,
    bool? revengeUsedThisRound,
    int? targetChainCount,
    int? maxTargetChainsPerRound,
    bool? isSpinning,
    PromptVibeMode? vibeMode,
    Set<String>? usedPromptIds,
    ContentPrompt? currentPrompt,
    bool clearCurrentPrompt = false,
    int? noEscapeStartRound,
    int? changeRightsPerTurn,
  }) {
    return GameStateModel(
      players: players ?? this.players,
      totalRounds: totalRounds ?? this.totalRounds,
      currentRound: currentRound ?? this.currentRound,
      selectedPlayer: clearSelectedPlayer
          ? null
          : selectedPlayer ?? this.selectedPlayer,
      balanceRuleEnabled: balanceRuleEnabled ?? this.balanceRuleEnabled,
      randomButtonEnabled: randomButtonEnabled ?? this.randomButtonEnabled,
      revengeModeEnabled: revengeModeEnabled ?? this.revengeModeEnabled,
      revengeUsedThisRound: revengeUsedThisRound ?? this.revengeUsedThisRound,
      targetChainCount: targetChainCount ?? this.targetChainCount,
      maxTargetChainsPerRound:
          maxTargetChainsPerRound ?? this.maxTargetChainsPerRound,
      isSpinning: isSpinning ?? this.isSpinning,
      vibeMode: vibeMode ?? this.vibeMode,
      usedPromptIds: usedPromptIds ?? this.usedPromptIds,
      currentPrompt: clearCurrentPrompt
          ? null
          : currentPrompt ?? this.currentPrompt,
      noEscapeStartRound: noEscapeStartRound ?? this.noEscapeStartRound,
      changeRightsPerTurn: changeRightsPerTurn ?? this.changeRightsPerTurn,
    );
  }
}
