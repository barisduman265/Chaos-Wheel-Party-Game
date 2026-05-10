import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subtitle,
    this.icon,
    this.trailingIcon,
    this.expanded = false,
    this.enabled = true,
    this.isSecondary = false,
    this.large = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? subtitle;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool expanded;
  final bool enabled;
  final bool isSecondary;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 30 : 18,
        vertical: large ? 24 : 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(large ? 28 : 18),
        gradient: enabled
            ? LinearGradient(
                colors: isSecondary
                    ? [
                        Colors.white.withValues(alpha: 0.09),
                        Colors.white.withValues(alpha: 0.045),
                      ]
                    : [theme.colorScheme.primary, theme.colorScheme.secondary],
              )
            : LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
        border: Border.all(
          color: enabled
              ? Colors.white.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color:
                      (isSecondary
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary)
                          .withValues(alpha: 0.24),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: expanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: large ? 28 : 24),
            const SizedBox(width: 10),
          ],
          if (expanded)
            Expanded(
              child: _ButtonLabel(label: label, subtitle: subtitle),
            )
          else
            _ButtonLabel(label: label, subtitle: subtitle),
          if (trailingIcon != null) ...[
            const SizedBox(width: 12),
            Icon(
              trailingIcon,
              color: Colors.white.withValues(alpha: 0.86),
              size: large ? 30 : 24,
            ),
          ],
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(large ? 28 : 18),
        child: expanded
            ? SizedBox(width: double.infinity, child: child)
            : child,
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({required this.label, required this.subtitle});

  final String label;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final large = subtitle != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: TextAlign.left,
          style:
              (large
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                    height: 1,
                  ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.78),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
