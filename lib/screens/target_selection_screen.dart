import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TargetSelectionScreen extends StatelessWidget {
  const TargetSelectionScreen({super.key});

  static const routeName = '/target-selection';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final selected = provider.selectedPlayer;
    final options = provider.players
        .where((player) => player.id != selected?.id)
        .toList(growable: false);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose your target 🎯'),
          automaticallyImplyLeading: false,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            NeonCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected == null
                        ? 'No active player selected.'
                        : '${selected.name} is redirecting the round.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final player in options)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        tileColor: Colors.white.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        title: Text(player.name),
                        trailing: const Icon(Icons.arrow_forward_rounded),
                        onTap: () {
                          final result = context
                              .read<GameProvider>()
                              .selectTarget(player.id);
                          Navigator.pop(context, result);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
