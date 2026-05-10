import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_setup_screen.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({super.key});

  static const routeName = '/players';

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlayer(BuildContext context) {
    final message = context.read<GameProvider>().addPlayer(_controller.text);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Players')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who is entering the wheel?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addPlayer(context),
                  decoration: const InputDecoration(
                    hintText: 'Enter player name',
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: 'Add Player',
                  icon: Icons.person_add_alt_1_rounded,
                  expanded: true,
                  onPressed: () => _addPlayer(context),
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
                  'Players',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                if (provider.players.isEmpty)
                  Text(
                    'Add at least 2 players to start.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  )
                else
                  for (final player in provider.players)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              player.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<GameProvider>().removePlayer(
                                player.id,
                              );
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            expanded: true,
            enabled: provider.players.length >= 2,
            onPressed: () {
              Navigator.pushNamed(context, GameSetupScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
