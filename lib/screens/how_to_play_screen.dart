import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  static const routeName = '/how-to-play';

  @override
  Widget build(BuildContext context) {
    const tips = [
      'Add your friends.',
      'Choose number of rounds.',
      'Spin the wheel.',
      'Pick Truth or Dare.',
      'Use Pass to skip.',
      'Use Target to choose someone else.',
      'If you choose Truth twice in a row, next time Truth is locked and Dare is mandatory.',
      'The app does not create questions or dares. Your group decides.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('How to Play')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How chaos works',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                for (final tip in tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.flash_on_rounded, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
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
