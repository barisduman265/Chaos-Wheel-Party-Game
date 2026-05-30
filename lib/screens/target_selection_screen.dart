import 'package:chaos_wheel_party_game/core/player_colors.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:chaos_wheel_party_game/widgets/pressable_scale.dart';
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
                    provider.l('chooseTarget'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 0.92,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selected == null
                        ? provider.l('noActivePlayer')
                        : provider.lf('redirectingChallenge', {
                            'player': selected.name,
                          }),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xFFFF5D98).withValues(alpha: 0.08),
                      border: Border.all(
                        color: const Color(0xFFFF5D98).withValues(alpha: 0.20),
                      ),
                    ),
                    child: Text(
                      provider.l('sameChallengePassed'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: ListView.separated(
                      itemCount: options.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 22),
                      itemBuilder: (context, index) {
                        final player = options[index];
                        final playerIndex = provider.players.indexWhere(
                          (candidate) => candidate.id == player.id,
                        );
                        final colors = playerColorsForIndex(
                          playerIndex < 0 ? index : playerIndex,
                        );
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 260 + (index * 45)),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 14 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: PressableScale(
                            onTap: () async {
                              await context.read<GameProvider>().playSfx(
                                ChaosSfx.targetUsed,
                              );
                              final result = context
                                  .read<GameProvider>()
                                  .selectTarget(player.id);
                              if (context.mounted) {
                                Navigator.pop(context, result);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    colors.primary.withValues(alpha: 0.13),
                                    const Color(
                                      0xFF160A24,
                                    ).withValues(alpha: 0.70),
                                  ],
                                ),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.36),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
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
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: colors.primary.withValues(
                                      alpha: 0.92,
                                    ),
                                    size: 22,
                                  ),
                                ],
                              ),
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
