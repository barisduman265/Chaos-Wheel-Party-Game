import 'dart:async';
import 'dart:math';

import 'package:chaos_wheel_party_game/screens/home_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (!mounted) {
          return;
        }
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      });
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
    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.10),
                      radius: 0.72,
                      colors: [
                        const Color(0xFFFF3D81).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AnimatedSkullMark(controller: _controller),
                      const SizedBox(height: 34),
                      Text(
                        'CHAOS\nWHEEL',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: const Color(0xFFBD78FF),
                              fontWeight: FontWeight.w900,
                              height: 0.86,
                              letterSpacing: 0,
                              shadows: [
                                Shadow(
                                  color: const Color(
                                    0xFFFF3D81,
                                  ).withValues(alpha: 0.42),
                                  blurRadius: 26,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'TRUTH  .  DARE  .  DRINK  .  NO ESCAPE',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.64),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 58),
                      Text(
                        'LOADING CHAOS...',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.34),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedSkullMark extends StatelessWidget {
  const _AnimatedSkullMark({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 142,
      height: 142,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: controller.value * 2 * pi,
                child: child,
              );
            },
            child: CustomPaint(
              size: const Size.square(132),
              painter: const _RingPainter(),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -controller.value * 2 * pi,
                child: child,
              );
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10081D),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA85BFF).withValues(alpha: 0.22),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(painter: const _SkullPainter()),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkullPainter extends CustomPainter {
  const _SkullPainter();

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

class _RingPainter extends CustomPainter {
  const _RingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF39D2FF),
          Color(0xFF8A55FF),
          Color(0xFFFF3D81),
          Color(0xFF39D2FF),
        ],
      ).createShader(rect);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
      ..shader = const SweepGradient(
        colors: [
          Color(0x6639D2FF),
          Color(0x668A55FF),
          Color(0x66FF3D81),
          Color(0x6639D2FF),
        ],
      ).createShader(rect);

    final arcRect = rect.deflate(18);
    canvas.drawArc(arcRect, -pi / 2, pi * 1.78, false, glowPaint);
    canvas.drawArc(arcRect, -pi / 2, pi * 1.78, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
