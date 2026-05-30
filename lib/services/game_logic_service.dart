import 'dart:math';

import 'package:chaos_wheel_party_game/models/game_state.dart';
import 'package:chaos_wheel_party_game/models/player.dart';

class GameLogicService {
  GameLogicService({Random? random}) : _random = random ?? Random();

  final Random _random;

  int calculatePassRights(int roundCount) {
    switch (roundCount) {
      case 15:
        return 1;
      case 25:
        return 2;
      case 40:
        return 3;
      default:
        return 1;
    }
  }

  int calculateTargetRights(int roundCount) {
    switch (roundCount) {
      case 15:
      case 25:
        return 1;
      case 40:
        return 2;
      default:
        return max(1, (roundCount * 0.08).ceil());
    }
  }

  List<Player> initializeGame(List<Player> players, int roundCount) {
    final passRights = calculatePassRights(roundCount);
    final targetRights = calculateTargetRights(roundCount);

    return players
        .map(
          (player) => player.resetForGame(
            passRights: passRights,
            targetRights: targetRights,
          ),
        )
        .toList(growable: false);
  }

  Player selectWeightedRandomPlayer(List<Player> players) {
    final weights = players
        .map((player) => 1.0 + (player.passUsed * 0.25))
        .toList(growable: false);
    final totalWeight = weights.fold<double>(0, (sum, weight) => sum + weight);
    var roll = _random.nextDouble() * totalWeight;

    for (var index = 0; index < players.length; index++) {
      roll -= weights[index];
      if (roll <= 0) {
        return players[index];
      }
    }

    return players.last;
  }

  bool rollChance(double probability) {
    return _random.nextDouble() < probability;
  }

  Player chooseTruth(Player player) {
    return player.copyWith(
      truthStreak: player.truthStreak + 1,
      truthCount: player.truthCount + 1,
    );
  }

  Player chooseDare(Player player) {
    return player.copyWith(truthStreak: 0, dareCount: player.dareCount + 1);
  }

  ({Player player, String choice}) chooseRandom(
    Player player, {
    required bool truthLocked,
    double dareChance = 0.50,
  }) {
    final chooseTruthAction =
        !truthLocked && _random.nextDouble() >= dareChance;
    return chooseTruthAction
        ? (player: chooseTruth(player), choice: 'Truth')
        : (player: chooseDare(player), choice: 'Dare');
  }

  Player usePass(Player player) {
    return player.copyWith(
      passRights: player.passRights - 1,
      passUsed: player.passUsed + 1,
      truthStreak: 0,
    );
  }

  Player useTarget(Player player) {
    return player.copyWith(
      targetRights: player.targetRights - 1,
      targetUsed: player.targetUsed + 1,
      truthStreak: 0,
    );
  }

  Player receiveTarget(Player player) {
    return player.copyWith(targetedCount: player.targetedCount + 1);
  }

  GameStateModel endRound(GameStateModel state) {
    return state.copyWith(
      currentRound: state.currentRound + 1,
      targetChainCount: 0,
      revengeUsedThisRound: false,
      clearSelectedPlayer: true,
      isSpinning: false,
    );
  }

  GameStateModel resetGameSamePlayers(GameStateModel state) {
    final players = initializeGame(state.players, state.totalRounds);
    return GameStateModel(
      players: players,
      totalRounds: state.totalRounds,
      currentRound: 1,
      balanceRuleEnabled: state.balanceRuleEnabled,
      randomButtonEnabled: state.randomButtonEnabled,
      revengeModeEnabled: state.revengeModeEnabled,
    );
  }

  GameStateModel startNewGame(GameStateModel state) {
    return GameStateModel(
      balanceRuleEnabled: state.balanceRuleEnabled,
      randomButtonEnabled: state.randomButtonEnabled,
      revengeModeEnabled: state.revengeModeEnabled,
    );
  }
}
