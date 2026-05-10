import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameSummaryScreen extends StatelessWidget {
  const GameSummaryScreen({super.key});

  static const routeName = '/summary';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final players = provider.players;

    return Scaffold(
      appBar: AppBar(title: const Text('Game Over')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Over',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chaos has ended.',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                _SummaryRow(
                  label: 'Most picked player',
                  value: _winner(players, (player) => player.pickedCount),
                ),
                _SummaryRow(
                  label: 'Most passes used',
                  value: _winner(players, (player) => player.passUsed),
                ),
                _SummaryRow(
                  label: 'Most targets used',
                  value: _winner(players, (player) => player.targetUsed),
                ),
                _SummaryRow(
                  label: 'Most Truth choices',
                  value: _winner(players, (player) => player.truthCount),
                ),
                _SummaryRow(
                  label: 'Most Dare choices',
                  value: _winner(players, (player) => player.dareCount),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Play Again',
            icon: Icons.replay_rounded,
            expanded: true,
            onPressed: () {
              context.read<GameProvider>().resetGameSamePlayers();
              Navigator.pushNamedAndRemoveUntil(
                context,
                GameScreen.routeName,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'New Game',
            icon: Icons.refresh_rounded,
            expanded: true,
            isSecondary: true,
            onPressed: () {
              context.read<GameProvider>().startNewGame();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AddPlayersScreen.routeName,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Share Results',
            icon: Icons.ios_share_rounded,
            expanded: true,
            isSecondary: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share results will be added later.'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _winner(List<Player> players, int Function(Player player) metric) {
    if (players.isEmpty) {
      return '-';
    }
    final top = players.reduce((a, b) => metric(a) >= metric(b) ? a : b);
    final value = metric(top);
    return value == 0 ? '-' : '${top.name} ($value)';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
