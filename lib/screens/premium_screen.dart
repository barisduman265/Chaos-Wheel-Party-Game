import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const routeName = '/premium';

  @override
  Widget build(BuildContext context) {
    const benefits = [
      'Remove ads',
      'Neon themes',
      'Custom wheel styles',
      'Chaos Mode',
      'Advanced game controls',
      'Extra sound effects',
      'Lifetime unlock',
    ];

    const chaosModes = [
      'Double Pick',
      'Revenge Mode',
      'Sudden Death',
      'No Pass Round',
      'Forced Dare Round',
    ];

    const themes = ['Neon Purple', 'Fire', 'Casino', 'Ice', 'Toxic Green'];

    return Scaffold(
      appBar: AppBar(title: const Text('Chaos Wheel Premium')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chaos Wheel Premium',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                for (final benefit in benefits)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt_rounded),
                    title: Text(benefit),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chaos Mode examples',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: chaosModes
                      .map((mode) => _LockedChip(label: mode))
                      .toList(growable: false),
                ),
                const SizedBox(height: 18),
                Text(
                  'Locked themes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: themes
                      .map((theme) => _LockedChip(label: theme))
                      .toList(growable: false),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Unlock Premium',
            icon: Icons.lock_open_rounded,
            expanded: true,
            onPressed: () {
              // Placeholder: in-app purchase flow will be added later.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Premium purchase is not enabled yet.'),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Restore Purchase',
            icon: Icons.restore_rounded,
            expanded: true,
            isSecondary: true,
            onPressed: () {
              // Placeholder: restore purchase flow will be added later.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Restore purchase is a placeholder for now.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LockedChip extends StatelessWidget {
  const _LockedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_rounded, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
