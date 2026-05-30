import 'dart:async';
import 'dart:math';

import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PickedRevealScreen extends StatefulWidget {
  const PickedRevealScreen({super.key, required this.playerName});

  final String playerName;

  static Future<void> show(BuildContext context, String playerName) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: PickedRevealScreen(playerName: playerName),
          );
        },
      ),
    );
  }

  @override
  State<PickedRevealScreen> createState() => _PickedRevealScreenState();
}

class _PickedRevealScreenState extends State<PickedRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: CustomPaint(
          painter: const _RevealBackgroundPainter(),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: const SizedBox(
                          width: 112,
                          height: 112,
                          child: CustomPaint(painter: _PickedSkullPainter()),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        context.watch<GameProvider>().l('wheelHasSpoken'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFFFF4F9A),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.playerName.toUpperCase(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                color: const Color(0xFFFF5D98),
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                                letterSpacing: 0,
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        context.watch<GameProvider>().l('isPicked'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickedSkullPainter extends CustomPainter {
  const _PickedSkullPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final skullPaint = Paint()..color = const Color(0xFFF3EDF5);
    final shadowPaint = Paint()
      ..color = const Color(0x70FF6AA8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    final darkPaint = Paint()..color = const Color(0xFF231826);

    final w = size.width;
    final h = size.height;
    final skull = Path()
      ..moveTo(w * 0.50, h * 0.12)
      ..cubicTo(w * 0.28, h * 0.12, w * 0.16, h * 0.28, w * 0.16, h * 0.43)
      ..cubicTo(w * 0.16, h * 0.58, w * 0.27, h * 0.67, w * 0.39, h * 0.69)
      ..lineTo(w * 0.61, h * 0.69)
      ..cubicTo(w * 0.73, h * 0.67, w * 0.84, h * 0.58, w * 0.84, h * 0.43)
      ..cubicTo(w * 0.84, h * 0.28, w * 0.72, h * 0.12, w * 0.50, h * 0.12)
      ..close();

    canvas.drawPath(skull.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawPath(skull, skullPaint);

    for (final x in [0.38, 0.50, 0.62]) {
      final tooth = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(w * x, h * 0.74),
          width: w * 0.11,
          height: h * 0.22,
        ),
        Radius.circular(w * 0.045),
      );
      canvas.drawRRect(tooth.shift(const Offset(0, 3)), shadowPaint);
      canvas.drawRRect(tooth, skullPaint);
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.38, h * 0.42),
        width: w * 0.23,
        height: h * 0.21,
      ),
      darkPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.62, h * 0.42),
        width: w * 0.23,
        height: h * 0.21,
      ),
      darkPaint,
    );

    final nose = Path()
      ..moveTo(w * 0.50, h * 0.53)
      ..lineTo(w * 0.43, h * 0.66)
      ..quadraticBezierTo(w * 0.50, h * 0.70, w * 0.57, h * 0.66)
      ..close();
    canvas.drawPath(nose, darkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RevealBackgroundPainter extends CustomPainter {
  const _RevealBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF08020F), Color(0xFF1A0626), Color(0xFF07010C)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    _drawGlow(
      canvas,
      size,
      center: Offset(size.width * 0.48, size.height * 0.50),
      radius: min(size.width, size.height) * 0.48,
      colors: [
        const Color(0x98FF4F9A),
        const Color(0x5639D2FF),
        const Color(0x0039D2FF),
      ],
    );
    _drawGlow(
      canvas,
      size,
      center: Offset(size.width * 0.70, size.height * 0.54),
      radius: min(size.width, size.height) * 0.34,
      colors: [
        const Color(0x8039D2FF),
        const Color(0x40272FFF),
        const Color(0x0007030E),
      ],
    );
  }

  void _drawGlow(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required List<Color> colors,
  }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: const [0, 0.42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
