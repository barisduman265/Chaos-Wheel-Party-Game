import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  static const routeName = '/setup';

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _roundCount = 10;
  bool _balanceRuleEnabled = true;
  bool _randomButtonEnabled = true;
  bool _didLoadDefaults = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDefaults) {
      return;
    }
    final provider = context.read<GameProvider>();
    _balanceRuleEnabled = provider.defaultBalanceRuleEnabled;
    _randomButtonEnabled = provider.defaultRandomButtonEnabled;
    _didLoadDefaults = true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final passRights = provider.calculatePassRights(_roundCount);
    final targetRights = provider.calculateTargetRights(_roundCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose your chaos level',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ModeChip(
                      label: 'Quick Game',
                      rounds: 5,
                      selected: _roundCount == 5,
                      onTap: () => setState(() => _roundCount = 5),
                    ),
                    _ModeChip(
                      label: 'Party Game',
                      rounds: 10,
                      selected: _roundCount == 10,
                      onTap: () => setState(() => _roundCount = 10),
                    ),
                    _ModeChip(
                      label: 'Long Game',
                      rounds: 15,
                      selected: _roundCount == 15,
                      onTap: () => setState(() => _roundCount = 15),
                    ),
                    _ModeChip(
                      label: 'Custom Game',
                      rounds: _roundCount,
                      selected:
                          _roundCount != 5 &&
                          _roundCount != 10 &&
                          _roundCount != 15,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Custom rounds: $_roundCount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _roundCount.toDouble(),
                  min: 3,
                  max: 30,
                  divisions: 27,
                  label: '$_roundCount',
                  onChanged: (value) {
                    setState(() => _roundCount = value.round());
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Pass rights',
                        value: '$passRights',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        label: 'Target rights',
                        value: '$targetRights',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          NeonCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: _balanceRuleEnabled,
                  onChanged: (value) {
                    setState(() => _balanceRuleEnabled = value);
                  },
                  title: const Text('Balance Rule'),
                  subtitle: const Text('ON by default'),
                ),
                SwitchListTile(
                  value: _randomButtonEnabled,
                  onChanged: (value) {
                    setState(() => _randomButtonEnabled = value);
                  },
                  title: const Text('Random Button'),
                  subtitle: const Text('ON by default'),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Chaos Events'),
                  subtitle: Text('Premium feature'),
                  trailing: Icon(Icons.lock_rounded),
                ),
                const ListTile(
                  title: Text('Remove Ads'),
                  subtitle: Text('Premium feature'),
                  trailing: Icon(Icons.lock_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Continue',
            icon: Icons.play_circle_fill_rounded,
            expanded: true,
            onPressed: () {
              context.read<GameProvider>().initializeGame(
                roundCount: _roundCount,
                balanceRuleEnabled: _balanceRuleEnabled,
                randomButtonEnabled: _randomButtonEnabled,
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                GameScreen.routeName,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.rounds,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int rounds;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: selected
              ? LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                )
              : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Text(
          '$label${label == 'Custom Game' ? '' : ' - $rounds'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
