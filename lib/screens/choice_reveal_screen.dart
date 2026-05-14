import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/action_feedback_screen.dart';
import 'package:chaos_wheel_party_game/screens/target_selection_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ChoiceRevealType { truth, dare }

class ChoiceRevealScreen extends StatelessWidget {
  const ChoiceRevealScreen({
    super.key,
    required this.player,
    required this.choice,
    this.isTargeted = false,
  });

  final Player player;
  final ChoiceRevealType choice;
  final bool isTargeted;

  static Future<void> show(
    BuildContext context, {
    required Player player,
    required ChoiceRevealType choice,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ChoiceRevealScreen(player: player, choice: choice),
          );
        },
      ),
    );
  }

  bool get _isTruth => choice == ChoiceRevealType.truth;

  String get _label => _isTruth ? 'Truth' : 'Dare';
  String get _subtitle => _isTruth ? 'Will you tell it?' : 'Will you do it?';
  String get _cardMessage => _isTruth
      ? 'THE GROUP DECIDES THE QUESTION'
      : 'THE GROUP DECIDES THE DARE';
  String get _buttonLabel => 'DO IT - SEND IT';

  List<Color> get _heroColors => _isTruth
      ? const [Color(0xFF6D8BFF), Color(0xFFB157FF)]
      : const [Color(0xFFFF7B4D), Color(0xFFFF3D81)];

  Color get _accent =>
      _isTruth ? const Color(0xFF7AB8FF) : const Color(0xFFFF5D98);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final activePlayer = provider.selectedPlayer ?? player;
    final canPass = activePlayer.passRights > 0;
    final targetMessage = provider.canUseTarget();
    final canTarget = targetMessage == null;

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
                    center: const Alignment(0, -0.25),
                    radius: 0.9,
                    colors: [
                      _heroColors.last.withValues(alpha: 0.24),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'STEP 2 / 2',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _accent,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                            ),
                        children: [
                          TextSpan(
                            text: _label,
                            style: TextStyle(color: _accent),
                          ),
                          const TextSpan(
                            text: '\nselected.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isTargeted
                          ? '${activePlayer.name}, you got targeted.'
                          : '${activePlayer.name}, $_subtitle',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 34,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _heroColors.first.withValues(alpha: 0.16),
                            _heroColors.last.withValues(alpha: 0.12),
                          ],
                        ),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _label.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  color: _accent,
                                  fontWeight: FontWeight.w900,
                                  height: 0.95,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _cardMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.76),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 4,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => _completeChoice(context, activePlayer),
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 22,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF7B2F), Color(0xFFFF3D81)],
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFFFF4D78,
                              ).withValues(alpha: 0.34),
                              blurRadius: 22,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          _buttonLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                    ),
                    if (!isTargeted) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStatusCard(
                              icon: Icons.local_bar_outlined,
                              title: 'Take Shot',
                              value: '${activePlayer.passRights}',
                              accent: const Color(0xFF71D2FF),
                              subtitle: canPass
                                  ? '${activePlayer.passRights} left'
                                  : 'No shots left',
                              enabled: canPass,
                              onTap: () => _usePass(context, activePlayer),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _MiniStatusCard(
                              icon: Icons.gps_fixed_rounded,
                              title: 'Target',
                              value: '${activePlayer.targetRights}',
                              accent: const Color(0xFFFF5D98),
                              subtitle: canTarget
                                  ? '${activePlayer.targetRights} left'
                                  : targetMessage ?? 'Unavailable',
                              enabled: canTarget,
                              onTap: () => _useTarget(context),
                            ),
                          ),
                        ],
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

  Future<void> _completeChoice(
    BuildContext context,
    Player activePlayer,
  ) async {
    final provider = context.read<GameProvider>();
    final message = _isTruth ? provider.chooseTruth() : provider.chooseDare();
    if (message.isEmpty || !context.mounted) {
      return;
    }

    await ActionFeedbackScreen.show(
      context,
      type: ActionFeedbackType.nextTurn,
      title: 'NEXT TURN',
      subtitle: '${activePlayer.name} locked in ${_label.toLowerCase()}.',
    );
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _usePass(BuildContext context, Player activePlayer) async {
    final message = context.read<GameProvider>().usePass();
    if (message.isEmpty || !context.mounted) {
      return;
    }

    await ActionFeedbackScreen.show(
      context,
      type: ActionFeedbackType.shot,
      title: 'SHOT TAKEN',
      subtitle: '${activePlayer.name} spends one shot token.',
    );
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _useTarget(BuildContext context) async {
    final provider = context.read<GameProvider>();
    final blockMessage = provider.canUseTarget();
    if (blockMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF23142D),
          behavior: SnackBarBehavior.floating,
          content: Text(blockMessage),
        ),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      TargetSelectionScreen.routeName,
    );
    if (result is String && context.mounted) {
      final selected = context.read<GameProvider>().selectedPlayer;
      if (selected != null) {
        await ActionFeedbackScreen.show(
          context,
          type: ActionFeedbackType.target,
          title: 'TARGET LOCKED',
          subtitle:
              '${selected.name} must handle this ${_label.toLowerCase()}.',
        );
        if (!context.mounted) {
          return;
        }
        if (context.mounted) {
          await Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              opaque: true,
              transitionDuration: const Duration(milliseconds: 260),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (_, animation, __) {
                return FadeTransition(
                  opacity: animation,
                  child: ChoiceRevealScreen(
                    player: selected,
                    choice: choice,
                    isTargeted: true,
                  ),
                );
              },
            ),
          );
        }
      }
    }
  }
}

class _MiniStatusCard extends StatelessWidget {
  const _MiniStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.44);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: enabled ? 0.05 : 0.03),
          border: Border.all(
            color: accent.withValues(alpha: enabled ? 0.35 : 0.14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: enabled ? 0.35 : 0.12),
                    accent.withValues(alpha: enabled ? 0.14 : 0.05),
                  ],
                ),
              ),
              child: Icon(icon, color: enabled ? accent : foreground, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
