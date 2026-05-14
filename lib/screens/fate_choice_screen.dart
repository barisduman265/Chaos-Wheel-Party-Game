import 'dart:math';

import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/choice_reveal_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _FateChoice { truth, dare, random }

class FateChoiceScreen extends StatelessWidget {
  const FateChoiceScreen({super.key, required this.player});

  final Player player;

  static Future<void> show(BuildContext context, {required Player player}) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: FateChoiceScreen(player: player),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final truthLocked = provider.truthLocked;
    final randomEnabled = provider.state.randomButtonEnabled;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            const ChaosBackground(child: SizedBox.expand()),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.28),
                    radius: 0.92,
                    colors: [
                      const Color(0xFF4E1360).withValues(alpha: 0.42),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 26, 28, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'STEP 1 / 2',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFFF4E92),
                        letterSpacing: 4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFA85BFF).withValues(alpha: 0.10),
                        border: Border.all(
                          color: const Color(
                            0xFFA85BFF,
                          ).withValues(alpha: 0.36),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFA85BFF,
                            ).withValues(alpha: 0.22),
                            blurRadius: 26,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFFA85BFF),
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'CHOOSE\nYOUR FATE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.88,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${player.name}, your choice. Your chaos.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    _ChoiceTile(
                      label: 'TRUTH',
                      subtitle: truthLocked
                          ? 'Locked this turn.'
                          : 'Confess. Or get caught.',
                      accent: const Color(0xFF42C7FF),
                      icon: Icons.question_answer_rounded,
                      enabled: !truthLocked,
                      onTap: () => _choose(context, _FateChoice.truth),
                    ),
                    const SizedBox(height: 16),
                    _ChoiceTile(
                      label: 'DARE',
                      subtitle: 'Do something stupid.',
                      accent: const Color(0xFFFF3D81),
                      icon: Icons.bolt_rounded,
                      onTap: () => _choose(context, _FateChoice.dare),
                    ),
                    if (randomEnabled) ...[
                      const SizedBox(height: 16),
                      _ChoiceTile(
                        label: 'RANDOM',
                        subtitle: 'Let chaos choose.',
                        accent: const Color(0xFF8A55FF),
                        icon: Icons.casino_rounded,
                        onTap: () => _choose(context, _FateChoice.random),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _choose(BuildContext context, _FateChoice choice) async {
    final provider = context.read<GameProvider>();
    final resolvedChoice = switch (choice) {
      _FateChoice.truth => ChoiceRevealType.truth,
      _FateChoice.dare => ChoiceRevealType.dare,
      _FateChoice.random =>
        provider.truthLocked || !Random().nextBool()
            ? ChoiceRevealType.dare
            : ChoiceRevealType.truth,
    };

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ChoiceRevealScreen(player: player, choice: resolvedChoice),
          );
        },
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.38);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: enabled
                ? [
                    accent.withValues(alpha: 0.26),
                    accent.withValues(alpha: 0.12),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.03),
                  ],
          ),
          border: Border.all(
            color: enabled
                ? accent.withValues(alpha: 0.46)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.14),
                border: Border.all(color: accent.withValues(alpha: 0.58)),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: enabled ? 0.24 : 0.08),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: enabled ? accent : foreground, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              enabled ? Icons.chevron_right_rounded : Icons.lock_rounded,
              color: enabled ? accent : foreground,
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}
