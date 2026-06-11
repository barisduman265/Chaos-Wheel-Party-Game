import 'dart:math';

import 'package:chaos_wheel/core/player_colors.dart';
import 'package:chaos_wheel/models/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpinningWheelController {
  _SpinningWheelState? _state;

  Future<void> spin() async {
    await _state?._spin();
  }

  void _attach(_SpinningWheelState state) {
    _state = state;
  }

  void _detach(_SpinningWheelState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({
    super.key,
    required this.players,
    required this.onSpinRequested,
    required this.onSpinCompleted,
    required this.isSpinning,
    required this.soundEnabled,
    this.suspenseSpin = false,
    this.dangerMode = false,
    this.controller,
  });

  final List<Player> players;
  final Future<Player?> Function() onSpinRequested;
  final ValueChanged<Player> onSpinCompleted;
  final bool isSpinning;
  final bool soundEnabled;
  final bool suspenseSpin;
  final bool dangerMode;
  final SpinningWheelController? controller;

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _rotation = 0;
  int _lastSoundTick = -1;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
    _rotationAnimation = AlwaysStoppedAnimation(_rotation);
    _controller.addListener(_playSpinTick);
  }

  @override
  void didUpdateWidget(covariant SpinningWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    _controller.removeListener(_playSpinTick);
    _controller.dispose();
    super.dispose();
  }

  void _playSpinTick() {
    if (!widget.soundEnabled || !_controller.isAnimating) {
      return;
    }

    final soundTick = (_controller.value * 16).floor();
    if (soundTick == _lastSoundTick) {
      return;
    }
    _lastSoundTick = soundTick;
    SystemSound.play(SystemSoundType.click);
  }

  Future<void> _spin() async {
    if (widget.players.length < 2 || widget.isSpinning) {
      return;
    }

    _lastSoundTick = -1;
    if (widget.soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }

    final selectedPlayer = await widget.onSpinRequested();
    if (!mounted || selectedPlayer == null) {
      return;
    }

    final selectedIndex = widget.players.indexWhere(
      (player) => player.id == selectedPlayer.id,
    );
    if (selectedIndex == -1) {
      return;
    }

    final segmentAngle = (2 * pi) / widget.players.length;
    final desiredMod =
        (2 * pi - ((selectedIndex * segmentAngle) + (segmentAngle / 2))) %
        (2 * pi);
    final currentMod = _rotation % (2 * pi);
    final delta = (desiredMod - currentMod + (2 * pi)) % (2 * pi);
    _controller.duration = Duration(
      milliseconds: widget.suspenseSpin ? 5600 : 3600,
    );
    final targetRotation =
        _rotation + (2 * pi * (widget.suspenseSpin ? 6 : 5)) + delta;

    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    await _controller.forward(from: 0);
    _rotation = targetRotation;
    if (!mounted) {
      return;
    }

    if (widget.soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }

    widget.onSpinCompleted(selectedPlayer);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - 6
            : 360.0;
        final wheelSize = min(min(constraints.maxWidth, maxHeight), 390.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: wheelSize,
              height: wheelSize + 6,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: wheelSize * 0.96,
                    height: wheelSize * 0.96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (widget.dangerMode
                                      ? const Color(0xFFFF3D81)
                                      : const Color(0xFFA85BFF))
                                  .withValues(
                                    alpha: widget.dangerMode ? 0.10 : 0.14,
                                  ),
                          blurRadius: widget.dangerMode ? 18 : 26,
                          spreadRadius: widget.dangerMode ? 1 : 2,
                        ),
                      ],
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      if (!_controller.isAnimating) {
                        return const SizedBox.shrink();
                      }
                      return Transform.rotate(
                        angle: _controller.value * pi * 4,
                        child: CustomPaint(
                          size: Size.square(wheelSize * 0.94),
                          painter: const _SpinEffectPainter(),
                        ),
                      );
                    },
                  ),
                  CustomPaint(
                    size: Size.square(wheelSize * 0.94),
                    painter: _WheelFramePainter(dangerMode: widget.dangerMode),
                  ),
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: CustomPaint(
                          size: Size.square(wheelSize * 0.9),
                          painter: _WheelPainter(
                            players: widget.players,
                            labelStyle: Theme.of(context).textTheme.labelLarge,
                            dangerMode: widget.dangerMode,
                          ),
                        ),
                      );
                    },
                  ),
                  const _WheelHub(),
                  Positioned(
                    top: wheelSize * 0.008,
                    child: CustomPaint(
                      size: Size(wheelSize * 0.18, wheelSize * 0.12),
                      painter: const _PointerTrianglePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PointerTrianglePainter extends CustomPainter {
  const _PointerTrianglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width * 0.06, 0)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.22,
        size.width * 0.94,
        0,
      )
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFB3D1), Color(0xFFA85BFF)],
      ).createShader(Offset.zero & size);

    canvas.drawShadow(path, const Color(0x88FF3D81), 8, false);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.22),
      2.4,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelHub extends StatelessWidget {
  const _WheelHub();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.32, -0.36),
          radius: 0.92,
          colors: [Color(0xFF3A1C52), Color(0xFF160821), Color(0xFF08030E)],
        ),
        border: Border.all(color: const Color(0xFFFF5D98), width: 2.4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D81).withValues(alpha: 0.18),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFF39D2FF).withValues(alpha: 0.08),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFA8D2), Color(0xFF7AB8FF)],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
          ),
        ),
      ),
    );
  }
}

class _WheelFramePainter extends CustomPainter {
  const _WheelFramePainter({required this.dangerMode});

  final bool dangerMode;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;

    final glowPaint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, dangerMode ? 14 : 22)
      ..color = (dangerMode ? const Color(0xFFFF3D81) : const Color(0xFFA85BFF))
          .withValues(alpha: dangerMode ? 0.12 : 0.12);
    canvas.drawCircle(center, radius * 0.93, glowPaint);

    final outerRimPaint = Paint()
      ..shader = SweepGradient(
        colors: dangerMode
            ? const [
                Color(0xFFFF5D98),
                Color(0xFF7A214D),
                Color(0xFFA85BFF),
                Color(0xFF2A0C3F),
                Color(0xFFFF5D98),
              ]
            : const [
                Color(0xFF39D2FF),
                Color(0xFF4A2B91),
                Color(0xFFFF5D98),
                Color(0xFF7B4DFF),
                Color(0xFF39D2FF),
              ],
      ).createShader(rect);
    canvas.drawCircle(center, radius * 0.935, outerRimPaint);

    final innerCutPaint = Paint()..color = const Color(0xFF12091C);
    canvas.drawCircle(center, radius * 0.875, innerCutPaint);

    final reflectionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: dangerMode ? 0.18 : 0.15);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.907),
      -pi * 0.82,
      pi * 0.54,
      false,
      reflectionPaint,
    );

    final lipPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = dangerMode ? 1.8 : 1.4
      ..color = (dangerMode ? const Color(0xFFFF7AB3) : Colors.white)
          .withValues(alpha: dangerMode ? 0.34 : 0.20);
    canvas.drawCircle(center, radius * 0.93, lipPaint);
    canvas.drawCircle(center, radius * 0.875, lipPaint);

    if (dangerMode) {
      final warningPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFFF4E92).withValues(alpha: 0.36);
      const dashCount = 28;
      const gapRatio = 0.44;
      for (var i = 0; i < dashCount; i++) {
        final start = (2 * pi / dashCount) * i;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.955),
          start,
          (2 * pi / dashCount) * gapRatio,
          false,
          warningPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WheelFramePainter oldDelegate) {
    return oldDelegate.dangerMode != dangerMode;
  }
}

class _SpinEffectPainter extends CustomPainter {
  const _SpinEffectPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          const Color(0xFF7AB8FF).withValues(alpha: 0.58),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(rect);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 8),
      -pi / 2,
      pi * 0.72,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({
    required this.players,
    required this.labelStyle,
    required this.dangerMode,
  });

  final List<Player> players;
  final TextStyle? labelStyle;
  final bool dangerMode;

  @override
  void paint(Canvas canvas, Size size) {
    if (players.isEmpty) {
      return;
    }

    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2;
    final segmentAngle = (2 * pi) / players.length;
    var startAngle = -pi / 2;

    final separatorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = dangerMode ? 4.6 : 3.6
      ..strokeCap = StrokeCap.round
      ..color = (dangerMode ? const Color(0xFF2B0716) : const Color(0xFF12091C))
          .withValues(alpha: 0.84);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.18);

    final wheelShadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..color = const Color(0x66251335);

    canvas.drawCircle(center, radius * 0.82, wheelShadowPaint);

    for (var index = 0; index < players.length; index++) {
      final colors = playerColorsForIndex(index);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dangerMode
              ? [
                  Color.lerp(colors.primary, const Color(0xFFFF3D81), 0.24)!,
                  Color.lerp(colors.secondary, const Color(0xFFA85BFF), 0.20)!,
                ]
              : [colors.primary, colors.secondary],
        ).createShader(rect);

      final sectorRect = Rect.fromCircle(
        center: center,
        radius: radius * 0.835,
      );

      canvas.drawArc(sectorRect, startAngle, segmentAngle, true, paint);
      canvas.drawArc(
        sectorRect,
        startAngle,
        segmentAngle,
        true,
        highlightPaint,
      );

      final separatorAngle = -pi / 2 + (segmentAngle * index);
      final separatorEnd = Offset(
        center.dx + cos(separatorAngle) * (radius * 0.835),
        center.dy + sin(separatorAngle) * (radius * 0.835),
      );
      canvas.drawLine(center, separatorEnd, separatorPaint);

      _paintLabel(
        canvas,
        center,
        radius,
        startAngle + (segmentAngle / 2),
        players[index].name,
      );

      startAngle += segmentAngle;
    }

    final innerLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius * 0.835, innerLinePaint);
  }

  void _paintLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String name,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.translate(radius * 0.49, 0);
    final normalized = (angle + (2 * pi)) % (2 * pi);
    final onLeftSide = normalized > pi / 2 && normalized < 3 * pi / 2;
    canvas.rotate(onLeftSide ? -pi / 2 : pi / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: labelStyle?.copyWith(
          color: Colors.white.withValues(alpha: 0.92),
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
          shadows: const [Shadow(color: Color(0xAA08020F), blurRadius: 6)],
        ),
      ),
      maxLines: 1,
      ellipsis: '...',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.42);

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.players != players ||
        oldDelegate.labelStyle != labelStyle ||
        oldDelegate.dangerMode != dangerMode;
  }
}
