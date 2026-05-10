import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_summary_screen.dart';
import 'package:chaos_wheel_party_game/screens/picked_reveal_screen.dart';
import 'package:chaos_wheel_party_game/screens/target_selection_screen.dart';
import 'package:chaos_wheel_party_game/widgets/action_panel.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/player_status_card.dart';
import 'package:chaos_wheel_party_game/widgets/spinning_wheel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      if (state.isGameOver) {
        Navigator.pushReplacementNamed(context, GameSummaryScreen.routeName);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Chaos Wheel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Round ${state.currentRound} / ${state.totalRounds}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                Text(
                  state.selectedPlayer == null ? 'Spin to pick' : 'Fate chosen',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.players.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final player = state.players[index];
                return PlayerStatusCard(
                  player: player,
                  isActive: player.id == state.selectedPlayer?.id,
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          NeonCard(
            child: Column(
              children: [
                SpinningWheel(
                  players: state.players,
                  isSpinning: state.isSpinning,
                  onSpinRequested: () async {
                    return context.read<GameProvider>().prepareSpinSelection();
                  },
                  onSpinCompleted: (_) async {
                    final message = context
                        .read<GameProvider>()
                        .completeSpinSelection();
                    if (message.isNotEmpty && context.mounted) {
                      final player = context
                          .read<GameProvider>()
                          .selectedPlayer;
                      if (player != null) {
                        await PickedRevealScreen.show(context, player.name);
                      }
                    }
                  },
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    state.selectedPlayer == null
                        ? 'Spin the wheel to pick the next victim.'
                        : '${state.selectedPlayer!.name} is picked 💀',
                    key: ValueKey(state.selectedPlayer?.id ?? 'none'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (state.selectedPlayer != null)
            ActionPanel(
              player: state.selectedPlayer!,
              randomEnabled: state.randomButtonEnabled,
              truthLocked: provider.truthLocked,
              passAvailable: state.selectedPlayer!.passRights > 0,
              targetAvailable: provider.canUseTarget() == null,
              passMessage: state.selectedPlayer!.passRights > 0
                  ? null
                  : 'No passes left.',
              targetMessage: provider.canUseTarget(),
              onTruth: () => _handleAction(
                context,
                context.read<GameProvider>().chooseTruth(),
              ),
              onDare: () => _handleAction(
                context,
                context.read<GameProvider>().chooseDare(),
              ),
              onRandom: () => _handleAction(
                context,
                context.read<GameProvider>().chooseRandom(),
              ),
              onPass: () => _handleAction(
                context,
                context.read<GameProvider>().usePass(),
              ),
              onTarget: () async {
                final blockMessage = context
                    .read<GameProvider>()
                    .canUseTarget();
                if (blockMessage != null) {
                  _handleAction(context, blockMessage);
                  return;
                }
                final result = await Navigator.pushNamed(
                  context,
                  TargetSelectionScreen.routeName,
                );
                if (result is String && context.mounted) {
                  _handleAction(context, result);
                  final player = context.read<GameProvider>().selectedPlayer;
                  if (player != null) {
                    await PickedRevealScreen.show(context, player.name);
                  }
                }
              },
            ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String message) {
    if (message.isEmpty) {
      return;
    }
    // Placeholder: trigger haptic + action sound effect here.
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
