import 'dart:async';

import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ActionFeedbackType { shot, target, revenge, nextTurn, noEscape }

class ActionFeedbackScreen extends StatefulWidget {
  const ActionFeedbackScreen({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.highlight,
    this.nextRound,
    this.totalRounds,
  });

  final ActionFeedbackType type;
  final String title;
  final String subtitle;
  final String? highlight;
  final int? nextRound;
  final int? totalRounds;

  static Future<void> show(
    BuildContext context, {
    required ActionFeedbackType type,
    required String title,
    required String subtitle,
    String? highlight,
    int? nextRound,
    int? totalRounds,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: ActionFeedbackScreen(
              type: type,
              title: title,
              subtitle: subtitle,
              highlight: highlight,
              nextRound: nextRound,
              totalRounds: totalRounds,
            ),
          );
        },
      ),
    );
  }

  @override
  State<ActionFeedbackScreen> createState() => _ActionFeedbackScreenState();
}

class _ActionFeedbackScreenState extends State<ActionFeedbackScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _timer;

  Color get _accent {
    return switch (widget.type) {
      ActionFeedbackType.shot => const Color(0xFF71D2FF),
      ActionFeedbackType.target => const Color(0xFFFF5D98),
      ActionFeedbackType.revenge => const Color(0xFFFF3D6E),
      ActionFeedbackType.nextTurn => const Color(0xFF72E4FF),
      ActionFeedbackType.noEscape => const Color(0xFFFF4E92),
    };
  }

  IconData get _icon {
    return switch (widget.type) {
      ActionFeedbackType.shot => Icons.local_bar_outlined,
      ActionFeedbackType.target => Icons.gps_fixed_rounded,
      ActionFeedbackType.revenge => Icons.crisis_alert_rounded,
      ActionFeedbackType.nextTurn => Icons.double_arrow_rounded,
      ActionFeedbackType.noEscape => Icons.link_off_rounded,
    };
  }

  bool get _waitForTap =>
      widget.type == ActionFeedbackType.nextTurn ||
      widget.type == ActionFeedbackType.noEscape;

  String _buttonLabel(GameProvider provider) {
    final nextRound = widget.nextRound;
    final totalRounds = widget.totalRounds;
    if (nextRound != null && totalRounds != null && nextRound > totalRounds) {
      return provider.l('seeResults');
    }
    return provider.l('nextTurn');
  }

  String? _roundLabel(GameProvider provider) {
    final nextRound = widget.nextRound;
    final totalRounds = widget.totalRounds;
    if (nextRound == null || totalRounds == null) {
      return null;
    }
    if (nextRound > totalRounds) {
      return provider.l('gameComplete');
    }
    return provider.lf('nextUpRound', {
      'round': nextRound,
      'total': totalRounds,
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    if (!_waitForTap) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    // Stop the No Escape sting when leaving this screen (e.g. tapping next
    // turn) so it does not bleed into the following turn.
    if (widget.type == ActionFeedbackType.noEscape) {
      ChaosAudioService.instance.stopSfx();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final roundLabel = _roundLabel(provider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            const ChaosBackground(child: SizedBox.expand()),
            Positioned.fill(
              child: CustomPaint(
                painter: _FeedbackNeonPainter(
                  accent: _accent,
                  isNextTurn:
                      widget.type == ActionFeedbackType.nextTurn ||
                      widget.type == ActionFeedbackType.noEscape,
                  isNoEscape: widget.type == ActionFeedbackType.noEscape,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(34, 0, 34, _waitForTap ? 132 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (roundLabel != null) ...[
                      Text(
                        roundLabel,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _accent,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    ScaleTransition(
                      scale: _scale,
                      child: widget.type == ActionFeedbackType.nextTurn
                          ? _NextTurnBadge(accent: _accent)
                          : _ActionBadge(accent: _accent, icon: _icon),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 0.94,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.highlight != null) ...[
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                _accent.withValues(alpha: 0.24),
                                _accent.withValues(alpha: 0.10),
                              ],
                            ),
                            border: Border.all(
                              color: _accent.withValues(alpha: 0.52),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _accent.withValues(alpha: 0.20),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.highlight!.toUpperCase(),
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: _accent,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    height: 1,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_waitForTap)
              Positioned(
                left: 24,
                right: 24,
                bottom: 18,
                child: SafeArea(
                  top: false,
                  child: _ContinueButton(
                    accent: _accent,
                    isNoEscape: widget.type == ActionFeedbackType.noEscape,
                    label: _buttonLabel(provider),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionBadge extends StatelessWidget {
  const _ActionBadge({required this.accent, required this.icon});

  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.16),
        border: Border.all(color: accent.withValues(alpha: 0.56), width: 2),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Icon(icon, color: accent, size: 54),
    );
  }
}

class _NextTurnBadge extends StatelessWidget {
  const _NextTurnBadge({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF55D8FF).withValues(alpha: 0.28),
            const Color(0xFF806CFF).withValues(alpha: 0.24),
            const Color(0xFFC957FF).withValues(alpha: 0.16),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF58D7FF).withValues(alpha: 0.30),
            blurRadius: 54,
            spreadRadius: 12,
          ),
          BoxShadow(
            color: const Color(0xFFA85BFF).withValues(alpha: 0.20),
            blurRadius: 72,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF20113A), Color(0xFF090415)],
              ),
              border: Border.all(color: accent.withValues(alpha: 0.46)),
            ),
          ),
          CustomPaint(
            size: const Size(54, 54),
            painter: _NextArrowPainter(accent: accent),
          ),
        ],
      ),
    );
  }
}

class _NextArrowPainter extends CustomPainter {
  const _NextArrowPainter({required this.accent});

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = accent.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white.withValues(alpha: 0.98), accent],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path arrow(double left) {
      return Path()
        ..moveTo(size.width * left, size.height * 0.28)
        ..lineTo(size.width * (left + 0.18), size.height * 0.50)
        ..lineTo(size.width * left, size.height * 0.72);
    }

    final first = arrow(0.26);
    final second = arrow(0.50);
    canvas.drawPath(first, glow);
    canvas.drawPath(second, glow);
    canvas.drawPath(first, paint);
    canvas.drawPath(second, paint);
  }

  @override
  bool shouldRepaint(covariant _NextArrowPainter oldDelegate) {
    return oldDelegate.accent != accent;
  }
}

class _FeedbackNeonPainter extends CustomPainter {
  const _FeedbackNeonPainter({
    required this.accent,
    required this.isNextTurn,
    required this.isNoEscape,
  });

  final Color accent;
  final bool isNextTurn;
  final bool isNoEscape;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final wash = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isNextTurn
            ? isNoEscape
                  ? const [
                      Color(0x24FF3D81),
                      Color(0x205A123E),
                      Color(0x22140635),
                      Color(0x2A25051F),
                    ]
                  : const [
                      Color(0x4439D2FF),
                      Color(0x222F1B82),
                      Color(0x22140635),
                      Color(0x334B0A42),
                    ]
            : [
                accent.withValues(alpha: 0.16),
                const Color(0x00100420),
                accent.withValues(alpha: 0.05),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, wash);

    void glow(Offset center, double radius, List<Color> colors) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: colors,
          stops: const [0, 0.42, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    if (isNextTurn) {
      if (isNoEscape) {
        glow(
          Offset(size.width * 0.50, size.height * 0.42),
          size.shortestSide * 0.62,
          const [Color(0x4FFF3D81), Color(0x25C2185B), Color(0x00070312)],
        );
        glow(
          Offset(size.width * 0.72, size.height * 0.32),
          size.shortestSide * 0.46,
          const [Color(0x24A85BFF), Color(0x18FF4E92), Color(0x00070312)],
        );
      } else {
        glow(
          Offset(size.width * 0.34, size.height * 0.40),
          size.shortestSide * 0.58,
          const [Color(0x5549D9FF), Color(0x26385CFF), Color(0x00070312)],
        );
        glow(
          Offset(size.width * 0.66, size.height * 0.35),
          size.shortestSide * 0.48,
          const [Color(0x3F935DFF), Color(0x1CFF4EA3), Color(0x00070312)],
        );
        glow(
          Offset(size.width * 0.50, size.height * 0.92),
          size.shortestSide * 0.62,
          const [Color(0x2C48E1FF), Color(0x225A2BFF), Color(0x00100420)],
        );
      }
    } else {
      glow(
        Offset(size.width * 0.50, size.height * 0.50),
        size.shortestSide * 0.64,
        [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.06),
          const Color(0x00070312),
        ],
      );
    }

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 1.08,
        colors: [
          Colors.transparent,
          const Color(0xFF05020A).withValues(alpha: 0.44),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _FeedbackNeonPainter oldDelegate) {
    return oldDelegate.accent != accent ||
        oldDelegate.isNextTurn != isNextTurn ||
        oldDelegate.isNoEscape != isNoEscape;
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({
    required this.accent,
    required this.isNoEscape,
    required this.label,
    required this.onTap,
  });

  final Color accent;
  final bool isNoEscape;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gradientColors = isNoEscape
        ? const [Color(0xFFFF6ED7), Color(0xFFFF2F9A), Color(0xFFFF5BA8)]
        : const [Color(0xFF62CDF6), Color(0xFF746DFF), Color(0xFFC65DFF)];
    final borderColor = isNoEscape
        ? const Color(0xFFFFC0E8)
        : const Color(0xFFB9ECFF);
    final primaryShadow = isNoEscape
        ? const Color(0xFFFF2F9A)
        : const Color(0xFF62D9FF);
    final secondaryShadow = isNoEscape
        ? const Color(0xFFFF7BE8)
        : const Color(0xFFC65DFF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: gradientColors,
          ),
          border: Border.all(color: borderColor.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: primaryShadow.withValues(alpha: 0.24),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: secondaryShadow.withValues(alpha: 0.14),
              blurRadius: 30,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
              ),
              child: const Icon(
                Icons.keyboard_double_arrow_right_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
