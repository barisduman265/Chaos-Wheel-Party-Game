import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/widgets/neon_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          NeonCard(
            child: Column(
              children: [
                SwitchListTile(
                  value: provider.soundEnabled,
                  onChanged: (value) {
                    // Placeholder: sound effect wiring will be added later.
                    context.read<GameProvider>().setSoundEnabled(value);
                  },
                  title: const Text('Sound'),
                ),
                SwitchListTile(
                  value: provider.vibrationEnabled,
                  onChanged: (value) {
                    // Placeholder: vibration wiring will be added later.
                    context.read<GameProvider>().setVibrationEnabled(value);
                  },
                  title: const Text('Vibration'),
                ),
                SwitchListTile(
                  value: provider.darkModeEnabled,
                  onChanged: (value) {
                    context.read<GameProvider>().setDarkModeEnabled(value);
                  },
                  title: const Text('Dark Mode'),
                ),
                SwitchListTile(
                  value: provider.defaultBalanceRuleEnabled,
                  onChanged: (value) {
                    context.read<GameProvider>().setDefaultBalanceRuleEnabled(
                      value,
                    );
                  },
                  title: const Text('Balance Rule default'),
                ),
                SwitchListTile(
                  value: provider.defaultRandomButtonEnabled,
                  onChanged: (value) {
                    context.read<GameProvider>().setDefaultRandomButtonEnabled(
                      value,
                    );
                  },
                  title: const Text('Random Button default'),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Reset App Data'),
                  subtitle: const Text(
                    'Clears players, game state, and local settings.',
                  ),
                  trailing: const Icon(Icons.delete_forever_rounded),
                  onTap: () {
                    context.read<GameProvider>().resetAppData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('App data reset.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
