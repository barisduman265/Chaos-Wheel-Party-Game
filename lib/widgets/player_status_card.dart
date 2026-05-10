import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class PlayerStatusCard extends StatelessWidget {
  const PlayerStatusCard({
    super.key,
    required this.player,
    this.isActive = false,
  });

  final Player player;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 176,
      child: NeonCard(
        borderColor: isActive ? theme.colorScheme.tertiary : null,
        glowColor: isActive ? theme.colorScheme.tertiary : null,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatTile(label: 'Pass', value: player.passRights),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(label: 'Target', value: player.targetRights),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _StatTile(label: 'Truth', value: player.truthStreak),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatTile(label: 'Picks', value: player.pickedCount),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
