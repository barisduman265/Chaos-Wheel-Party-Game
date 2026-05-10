import 'package:flutter/material.dart';

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.glowColor,
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = borderColor ?? theme.colorScheme.secondary;
    final glow = glowColor ?? theme.colorScheme.primary;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            theme.cardColor.withValues(alpha: 0.96),
            theme.cardColor.withValues(alpha: 0.76),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: border.withValues(alpha: 0.48)),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.16),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
