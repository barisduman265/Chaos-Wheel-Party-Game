import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/models/prompt_models.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/choice_reveal_screen.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
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
        pageBuilder: (_, animation, _) {
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
    final activePlayer = provider.selectedPlayer ?? player;
    final truthLocked = provider.isTruthLockedFor(activePlayer);
    final randomEnabled = provider.state.randomButtonEnabled;
    final noEscape = provider.isNoEscapeActive;

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
                      if (noEscape)
                        const Color(0xFFFF3D81).withValues(alpha: 0.20),
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
                      noEscape
                          ? provider.l('noEscapeMode')
                          : provider.l('step1of2'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: noEscape
                            ? const Color(0xFFFF6A7F)
                            : const Color(0xFFFF4E92),
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
                      provider.l('chooseYourFate'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.88,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      provider.lf('yourChoiceYourChaos', {
                        'player': activePlayer.name,
                      }),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (noEscape) ...[
                      const SizedBox(height: 16),
                      const _NoEscapePill(),
                    ],
                    const Spacer(),
                    _ChoiceTile(
                      label: provider.l('truth'),
                      subtitle: truthLocked
                          ? provider.l('lockedThisTurn')
                          : provider.l('tellTheTruth'),
                      accent: const Color(0xFF42C7FF),
                      icon: Icons.question_answer_rounded,
                      enabled: !truthLocked,
                      onTap: () => _choose(context, _FateChoice.truth),
                    ),
                    const SizedBox(height: 16),
                    _ChoiceTile(
                      label: provider.l('dare'),
                      subtitle: provider.l('takeTheRisk'),
                      accent: const Color(0xFFFF3D81),
                      icon: Icons.bolt_rounded,
                      onTap: () => _choose(context, _FateChoice.dare),
                    ),
                    if (randomEnabled) ...[
                      const SizedBox(height: 16),
                      _ChoiceTile(
                        label: provider.l('random'),
                        subtitle: provider.l('letChaosDecide'),
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
    final activePlayer = provider.selectedPlayer ?? player;
    final resolvedChoice = switch (choice) {
      _FateChoice.truth => ChoiceRevealType.truth,
      _FateChoice.dare => ChoiceRevealType.dare,
      _FateChoice.random =>
        provider.randomShouldChooseDare()
            ? ChoiceRevealType.dare
            : ChoiceRevealType.truth,
    };
    await provider.playSfx(
      resolvedChoice == ChoiceRevealType.truth
          ? ChaosSfx.truthSelected
          : ChaosSfx.dareSelected,
    );
    provider.generatePrompt(
      resolvedChoice == ChoiceRevealType.truth
          ? PromptType.truth
          : PromptType.dare,
    );
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: ChoiceRevealScreen(
              player: activePlayer,
              choice: resolvedChoice,
            ),
          );
        },
      ),
    );
  }
}

class _NoEscapePill extends StatelessWidget {
  const _NoEscapePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF3D81).withValues(alpha: 0.22),
            const Color(0xFFA85BFF).withValues(alpha: 0.12),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFF5D98).withValues(alpha: 0.42),
        ),
      ),
      child: Text(
        context.watch<GameProvider>().l('shotTargetLockedRandomLeansDare'),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFFFFA0BC).withValues(alpha: 0.82),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
        ),
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
    final secondary = switch (accent) {
      const Color(0xFF42C7FF) => const Color(0xFF806CFF),
      const Color(0xFFFF3D81) => const Color(0xFFFF7B2F),
      const Color(0xFF8A55FF) => const Color(0xFFFF4E92),
      _ => accent,
    };

    final radius = BorderRadius.circular(26);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: radius,
        splashColor: accent.withValues(alpha: 0.14),
        highlightColor: accent.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          height: 104,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          foregroundDecoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: enabled
                  ? accent.withValues(alpha: 0.98)
                  : Colors.white.withValues(alpha: 0.10),
              width: enabled ? 2.4 : 1,
            ),
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: enabled
                  ? [
                      accent.withValues(alpha: 0.055),
                      const Color(0xFF1A0B25).withValues(alpha: 0.30),
                      const Color(0xFF1A0B25).withValues(alpha: 0.28),
                      secondary.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.035),
                      Colors.white.withValues(alpha: 0.02),
                    ],
              stops: enabled ? const [0, 0.46, 0.64, 1] : null,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.10),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: secondary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.38),
                      accent.withValues(alpha: 0.13),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.82),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.30),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 29),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: foreground.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_rounded,
                color: enabled ? accent : foreground,
                size: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
