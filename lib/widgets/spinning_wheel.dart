import 'dart:math';

import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class SpinningWheel extends StatefulWidget {
  const SpinningWheel({
    super.key,
    required this.players,
    required this.onSpinRequested,
    required this.onSpinCompleted,
    required this.isSpinning,
  });

  final List<Player> players;
  final Future<Player?> Function() onSpinRequested;
  final ValueChanged<Player> onSpinCompleted;
  final bool isSpinning;

  @override
  State<SpinningWheel> createState() => _SpinningWheelState();
}

class _SpinningWheelState extends State<SpinningWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _rotationAnimation;
  double _rotation = 0;

  final List<Color> _segmentColors = const [
    Color(0xFFBB29FF),
    Color(0xFFFF3D81),
    Color(0xFF39D2FF),
    Color(0xFFFF6B4A),
    Color(0xFF7CFF6B),
    Color(0xFFFFC83D),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rotationAnimation = AlwaysStoppedAnimation(_rotation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _spin() async {
    if (widget.players.length < 2 || widget.isSpinning) {
      return;
    }

    // Placeholder: trigger haptic + spin sound effect here.
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
    final targetRotation = _rotation + (2 * pi * 4) + delta;

    _rotationAnimation = Tween<double>(
      begin: _rotation,
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    await _controller.forward(from: 0);
    _rotation = targetRotation;
    if (!mounted) {
      return;
    }

    widget.onSpinCompleted(selectedPlayer);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 0,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 52,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: CustomPaint(
                      size: const Size.square(280),
                      painter: _WheelPainter(
                        players: widget.players,
                        segmentColors: _segmentColors,
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF140D1F),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.18),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'SPIN',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: widget.isSpinning ? 'Spinning...' : 'Spin',
          icon: Icons.casino_rounded,
          expanded: true,
          enabled: widget.players.length >= 2 && !widget.isSpinning,
          onPressed: _spin,
        ),
      ],
    );
  }
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

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withValues(alpha: 0.12);

    for (var index = 0; index < players.length; index++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = LinearGradient(
          colors: [
            segmentColors[index % segmentColors.length],
            segmentColors[(index + 1) % segmentColors.length].withValues(
              alpha: 0.82,
            ),
          ],
        ).createShader(rect);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        segmentAngle,
        true,
        borderPaint,
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
    canvas.translate(radius * 0.56, 0);
    canvas.rotate(pi / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      maxLines: 1,
      ellipsis: '...',
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: radius * 0.55);

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
