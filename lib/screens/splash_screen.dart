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

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
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
    final skullPaint = Paint()..color = const Color(0xFFEFEAF2);
    final shadowPaint = Paint()
      ..color = const Color(0x5539D2FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final darkPaint = Paint()..color = const Color(0xFF2A2930);
    final toothPaint = Paint()
      ..color = const Color(0xFF8FDFFF)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final head = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.56,
        size.height * 0.52,
      ),
      Radius.circular(size.width * 0.22),
    );
    final jaw = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.56,
        size.width * 0.40,
        size.height * 0.24,
      ),
      Radius.circular(size.width * 0.10),
    );

    canvas.drawRRect(head.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawRRect(jaw.shift(const Offset(0, 3)), shadowPaint);
    canvas.drawRRect(head, skullPaint);
    canvas.drawRRect(jaw, skullPaint);

    canvas.drawCircle(
      Offset(size.width * 0.39, size.height * 0.43),
      size.width * 0.095,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.43),
      size.width * 0.095,
      darkPaint,
    );

    final nose = Path()
      ..moveTo(size.width * 0.50, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.68,
        size.width * 0.58,
        size.height * 0.68,
      )
      ..quadraticBezierTo(
        size.width * 0.57,
        size.height * 0.56,
        size.width * 0.50,
        size.height * 0.52,
      )
      ..close();
    canvas.drawPath(nose, darkPaint);

    for (final x in [0.39, 0.50, 0.61]) {
      canvas.drawLine(
        Offset(size.width * x, size.height * 0.70),
        Offset(size.width * x, size.height * 0.80),
        toothPaint,
      );
    }
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
