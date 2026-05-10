import 'package:chaos_wheel_party_game/models/player.dart';

class GameStateModel {
  const GameStateModel({
    this.players = const [],
    this.totalRounds = 0,
    this.currentRound = 0,
    this.selectedPlayer,
    this.balanceRuleEnabled = true,
    this.randomButtonEnabled = true,
    this.targetChainCount = 0,
    this.maxTargetChainsPerRound = 2,
    this.isSpinning = false,
  });

  final List<Player> players;
  final int totalRounds;
  final int currentRound;
  final Player? selectedPlayer;
  final bool balanceRuleEnabled;
  final bool randomButtonEnabled;
  final int targetChainCount;
  final int maxTargetChainsPerRound;
  final bool isSpinning;

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
    int? targetChainCount,
    int? maxTargetChainsPerRound,
    bool? isSpinning,
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
      targetChainCount: targetChainCount ?? this.targetChainCount,
      maxTargetChainsPerRound:
          maxTargetChainsPerRound ?? this.maxTargetChainsPerRound,
      isSpinning: isSpinning ?? this.isSpinning,
    );
  }
}
