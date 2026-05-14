import 'dart:math';

import 'package:chaos_wheel_party_game/models/player.dart';
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
    this.controller,
  });

  final List<Player> players;
  final Future<Player?> Function() onSpinRequested;
  final ValueChanged<Player> onSpinCompleted;
  final bool isSpinning;
  final bool soundEnabled;
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

  final List<Color> _segmentColors = const [
    Color(0xFF2B87F0),
    Color(0xFF8757E8),
    Color(0xFFE44B92),
    Color(0xFFF1C340),
    Color(0xFF55B76A),
    Color(0xFFE76E3C),
  ];

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
    final targetRotation = _rotation + (2 * pi * 5) + delta;

    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

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
                          color: const Color(
                            0x66FFB347,
                          ).withValues(alpha: 0.22),
                          blurRadius: 34,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: wheelSize * 0.04,
                    child: CustomPaint(
                      size: Size(wheelSize * 0.10, wheelSize * 0.08),
                      painter: const _PointerTrianglePainter(),
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
                  AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value,
                        child: CustomPaint(
                          size: Size.square(wheelSize * 0.9),
                          painter: _WheelPainter(
                            players: widget.players,
                            segmentColors: _segmentColors,
                          ),
                        ),
                      );
                    },
                  ),
                  const _WheelHub(),
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
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF0A0), Color(0xFFFF8A34)],
      ).createShader(Offset.zero & size);

    canvas.drawShadow(path, const Color(0xAAFF8A34), 8, false);
    canvas.drawPath(path, paint);
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD64A), Color(0xFFFFA23C)],
        ),
        border: Border.all(color: const Color(0xFFFFF2A8), width: 3),
        boxShadow: [
          BoxShadow(
            color: const Color(0x66FFC44D).withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
    );
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
          const Color(0xFFFFD85A).withValues(alpha: 0.65),
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
  const _WheelPainter({required this.players, required this.segmentColors});

  final List<Player> players;
  final List<Color> segmentColors;

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

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD85A), Color(0xFFFF9A3C)],
      ).createShader(rect);

    final innerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = const Color(0xFF130D1D);

    final wheelShadowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = const Color(0x66251335);

    canvas.drawCircle(center, radius - (radius * 0.07), wheelShadowPaint);

    canvas.drawCircle(center, radius - (radius * 0.05), outerRingPaint);

    for (var index = 0; index < players.length; index++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = segmentColors[index % segmentColors.length];

      final sectorRect = Rect.fromCircle(
        center: center,
        radius: radius - (radius * 0.05),
      );

      canvas.drawArc(sectorRect, startAngle, segmentAngle, true, paint);

      canvas.drawArc(
        sectorRect,
        startAngle,
        segmentAngle,
        true,
        innerBorderPaint,
      );

      _paintLabel(
        canvas,
        center,
        radius,
        startAngle + (segmentAngle / 2),
        players[index].name,
      );

      startAngle += segmentAngle;
    }

    _paintBulbs(canvas, center, radius - (radius * 0.03), players.length * 2);
  }

  void _paintBulbs(Canvas canvas, Offset center, double radius, int count) {
    final bulbPaint = Paint()..color = const Color(0xFFFFF0A0);
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = const Color(0x99FFD85A);

    for (var index = 0; index < count; index++) {
      final angle = (-pi / 2) + ((2 * pi / count) * index);
      final offset = Offset(
        center.dx + cos(angle) * radius,
        center.dy + sin(angle) * radius,
      );
      canvas.drawCircle(offset, 4, glowPaint);
      canvas.drawCircle(offset, 2.4, bulbPaint);
    }
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
    canvas.translate(radius * 0.52, 0);
    canvas.rotate(pi / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
      maxLines: 1,
      ellipsis: '...',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.38);

    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.players != players;
  }
}
