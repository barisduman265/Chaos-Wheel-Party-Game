import 'dart:math';

import 'package:flutter/material.dart';

class ChaosBackground extends StatelessWidget {
  const ChaosBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF120229),
            Color(0xFF250A46),
            Color(0xFF14051F),
            Color(0xFF07030E),
          ],
          stops: [0, 0.28, 0.68, 1],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: CustomPaint(
        painter: const _ChaosBackgroundPainter(),
        child: child,
      ),
    );
  }
}

class _ChaosBackgroundPainter extends CustomPainter {
  const _ChaosBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintDottedField(canvas, size);
    _paintTopStage(canvas, size);
    _paintBottomHeat(canvas, size);
  }

  void _paintDottedField(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.fill;

    const step = 24.0;
    for (var y = 24.0; y < size.height; y += step) {
      for (var x = 18.0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), 1.1, paint);
      }
    }
  }

  void _paintTopStage(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.76,
        size.height * 0.10,
        size.width * 0.55,
        size.height * 0.13,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.17,
        0,
        size.height * 0.11,
      )
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x6639D2FF), Color(0x552A005D), Color(0x33FF3D81)],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  void _paintBottomHeat(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, size.height * 0.62, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0x00FF3D81),
          const Color(0x24FF3D81),
          const Color(0x2039D2FF).withValues(alpha: 0.10),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        transform: const GradientRotation(pi / 10),
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
