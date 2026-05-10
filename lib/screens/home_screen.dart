import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/how_to_play_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
import 'package:chaos_wheel_party_game/screens/settings_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final heroGap = (constraints.maxHeight * 0.32).clamp(88.0, 260.0);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: Column(
                    children: [
                      const _EditionPill(),
                      const SizedBox(height: 38),
                      Text(
                        'CHAOS\nWHEEL',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 0.86,
                              letterSpacing: 0,
                              shadows: [
                                Shadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.58),
                                  blurRadius: 32,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TRUTH  ·  DARE  ·  DRINK  ·  NO ESCAPE',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3.2,
                        ),
                      ),
                      const SizedBox(height: 34),
                      SizedBox(height: heroGap),
                      PrimaryButton(
                        label: 'START GAME',
                        subtitle: 'Spin the wheel of fate',
                        trailingIcon: Icons.chevron_right_rounded,
                        expanded: true,
                        large: true,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AddPlayersScreen.routeName,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _HomeMenuButton(
                        title: 'How to Play',
                        subtitle: 'Rules of chaos',
                        icon: Icons.menu_book_rounded,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            HowToPlayScreen.routeName,
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      _HomeMenuButton(
                        title: 'Premium',
                        subtitle: 'Unlock chaos mode',
                        icon: Icons.workspace_premium_rounded,
                        iconColor: const Color(0xFFFFC83D),
                        onTap: () {
                          Navigator.pushNamed(context, PremiumScreen.routeName);
                        },
                      ),
                      const SizedBox(height: 14),
                      _HomeMenuButton(
                        title: 'Settings',
                        subtitle: 'Sound, vibration, defaults',
                        icon: Icons.tune_rounded,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            SettingsScreen.routeName,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditionPill extends StatelessWidget {
  const _EditionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.tertiary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.8),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'V1.0  ·  PARTY EDITION',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 19),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withValues(alpha: 0.055),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.white, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
