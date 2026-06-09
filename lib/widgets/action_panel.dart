import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/util/turkish_name.dart';
import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.player,
    required this.randomEnabled,
    required this.truthLocked,
    required this.passAvailable,
    required this.targetAvailable,
    required this.passMessage,
    required this.targetMessage,
    required this.onTruth,
    required this.onDare,
    required this.onRandom,
    required this.onPass,
    required this.onTarget,
  });

  final Player player;
  final bool randomEnabled;
  final bool truthLocked;
  final bool passAvailable;
  final bool targetAvailable;
  final String? passMessage;
  final String? targetMessage;
  final VoidCallback onTruth;
  final VoidCallback onDare;
  final VoidCallback onRandom;
  final VoidCallback onPass;
  final VoidCallback onTarget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF221328), Color(0xFF140E1A)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x55FF4E92).withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF8A34), Color(0xFFFF4E92)],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
                  style:
                      turkishName(
                        Theme.of(context).textTheme.titleLarge,
                      ).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${player.name}, choose your fate',
                      style:
                          turkishName(
                            Theme.of(context).textTheme.headlineSmall,
                          ).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      truthLocked
                          ? 'Truth is locked for this turn. Dare is mandatory.'
                          : 'The room picks the prompt. The app keeps the pressure on.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: truthLocked
                            ? const Color(0xFFFFC44D)
                            : Colors.white.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ResourcePill(
                  icon: Icons.local_bar_outlined,
                  label: 'Pass left',
                  value: '${player.passRights}',
                  accent: const Color(0xFF72D5FF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ResourcePill(
                  icon: Icons.gps_fixed_rounded,
                  label: 'Target left',
                  value: '${player.targetRights}',
                  accent: const Color(0xFFFF7D5C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionButton(
                label: 'Truth',
                subtitle: truthLocked ? 'Locked now' : 'Own the answer',
                icon: Icons.question_answer_rounded,
                colors: const [Color(0xFF4B8DFF), Color(0xFF7B5BFF)],
                enabled: !truthLocked,
                width: 154,
                onTap: onTruth,
              ),
              _ActionButton(
                label: 'Dare',
                subtitle: 'Go all in',
                icon: Icons.bolt_rounded,
                colors: const [Color(0xFFFF8A34), Color(0xFFFF4E92)],
                width: 154,
                onTap: onDare,
              ),
              if (randomEnabled)
                _ActionButton(
                  label: 'Random',
                  subtitle: 'Let fate choose',
                  icon: Icons.casino_rounded,
                  colors: const [Color(0xFF2ED3B7), Color(0xFF2593FF)],
                  width: 154,
                  onTap: onRandom,
                ),
              _ActionButton(
                label: 'Pass',
                subtitle: passAvailable
                    ? 'Skip this turn'
                    : (passMessage ?? 'Unavailable'),
                icon: Icons.fast_forward_rounded,
                colors: const [Color(0xFF26202B), Color(0xFF1A141F)],
                accent: const Color(0xFF72D5FF),
                enabled: passAvailable,
                width: 154,
                onTap: onPass,
              ),
              _ActionButton(
                label: 'Target',
                subtitle: targetAvailable
                    ? 'Redirect the pick'
                    : (targetMessage ?? 'Unavailable'),
                icon: Icons.gps_fixed_rounded,
                colors: const [Color(0xFF26202B), Color(0xFF1A141F)],
                accent: const Color(0xFFFF7D5C),
                enabled: targetAvailable,
                width: 154,
                onTap: onTarget,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResourcePill extends StatelessWidget {
  const _ResourcePill({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.width,
    required this.onTap,
    this.enabled = true,
    this.accent,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final double width;
  final VoidCallback onTap;
  final bool enabled;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.38);
    final iconAccent = accent ?? Colors.white;

    return SizedBox(
      width: width,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: enabled
                  ? colors
                  : [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.05),
                    ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white.withValues(alpha: enabled ? 0.18 : 0.10),
                ),
                child: Icon(icon, color: iconAccent, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: foreground.withValues(alpha: enabled ? 0.80 : 0.60),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
