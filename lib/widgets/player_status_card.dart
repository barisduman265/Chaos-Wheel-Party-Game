import 'package:chaos_wheel/models/player.dart';
import 'package:chaos_wheel/util/turkish_name.dart';
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
    final accent = isActive ? const Color(0xFFFFC44D) : const Color(0xFFFF4E92);

    return SizedBox(
      width: 214,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? const [Color(0xFF321E20), Color(0xFF23161E)]
                : const [Color(0xFF1D1422), Color(0xFF15101B)],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.55)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: isActive ? 0.22 : 0.12),
              blurRadius: isActive ? 22 : 14,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isActive
                          ? const [Color(0xFFFFA63D), Color(0xFFFF5D57)]
                          : const [Color(0xFF9C46FF), Color(0xFFFF4E92)],
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            turkishName(
                              Theme.of(context).textTheme.titleLarge,
                            ).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: accent.withValues(alpha: 0.18),
                        ),
                        child: Text(
                          isActive ? 'HOT SEAT' : 'READY',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Shot',
                    value: player.passRights,
                    accent: const Color(0xFF72D5FF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(
                    label: 'Target',
                    value: player.targetRights,
                    accent: const Color(0xFFFF7D5C),
                  ),
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
  const _StatTile({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final int value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
