import 'package:chaos_wheel_party_game/core/player_colors.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TargetSelectionScreen extends StatelessWidget {
  const TargetSelectionScreen({super.key});

  static const routeName = '/target-selection';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final selected = provider.selectedPlayer;
    final options = provider.players
        .where((player) => player.id != selected?.id)
        .toList(growable: false);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: ChaosBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Choose\na target.',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 0.92,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selected == null
                        ? 'No active player selected.'
                        : '${selected.name} is redirecting the round.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.64),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final player = options[index];
                        final playerIndex = provider.players.indexWhere(
                          (candidate) => candidate.id == player.id,
                        );
                        final colors = playerColorsForIndex(
                          playerIndex < 0 ? index : playerIndex,
                        );
                        return InkWell(
                          onTap: () {
                            final result = context
                                .read<GameProvider>()
                                .selectTarget(player.id);
                            Navigator.pop(context, result);
                          },
                          borderRadius: BorderRadius.circular(24),
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white.withValues(alpha: 0.05),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.34),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: colors.primary,
                                  child: Text(
                                    player.name.isEmpty
                                        ? '?'
                                        : player.name[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colors.primary,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
