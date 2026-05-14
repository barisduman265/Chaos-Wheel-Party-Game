import 'dart:async';

import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';

enum ActionFeedbackType { shot, target, nextTurn }

class ActionFeedbackScreen extends StatefulWidget {
  const ActionFeedbackScreen({
    super.key,
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final ActionFeedbackType type;
  final String title;
  final String subtitle;

  static Future<void> show(
    BuildContext context, {
    required ActionFeedbackType type,
    required String title,
    required String subtitle,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: ActionFeedbackScreen(
              type: type,
              title: title,
              subtitle: subtitle,
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
      ActionFeedbackType.nextTurn => const Color(0xFFFFC44D),
    };
  }

  IconData get _icon {
    return switch (widget.type) {
      ActionFeedbackType.shot => Icons.local_bar_outlined,
      ActionFeedbackType.target => Icons.gps_fixed_rounded,
      ActionFeedbackType.nextTurn => Icons.arrow_forward_rounded,
    };
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
        body: Stack(
          children: [
            const ChaosBackground(child: SizedBox.expand()),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.92,
                    colors: [
                      _accent.withValues(alpha: 0.30),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scale,
                      child: Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _accent.withValues(alpha: 0.16),
                          border: Border.all(
                            color: _accent.withValues(alpha: 0.56),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withValues(alpha: 0.34),
                              blurRadius: 42,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(_icon, color: _accent, size: 54),
                      ),
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
          ],
        ),
      ),
    );
  }
}
