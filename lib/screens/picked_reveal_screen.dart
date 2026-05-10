import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class PickedRevealScreen extends StatefulWidget {
  const PickedRevealScreen({super.key, required this.playerName});

  final String playerName;

  static Future<void> show(BuildContext context, String playerName) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
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
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _timer = Timer(const Duration(milliseconds: 1850), () {
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
                        child: Text(
                          '💀',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 92, height: 1),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'THE WHEEL HAS SPOKEN',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFFFF4F9A),
                          fontWeight: FontWeight.w900,
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
                        'is picked.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.84),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.6,
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
        const Color(0xD0FF4F9A),
        const Color(0x80FF6A3D),
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
