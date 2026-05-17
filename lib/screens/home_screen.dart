import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/how_to_play_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
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
              final heroGap = (constraints.maxHeight * 0.40).clamp(
                180.0,
                340.0,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 54),
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFFFFF),
                              Color(0xFFEAD8FF),
                              Color(0xFFB985FF),
                              Color(0xFFD64CFF),
                            ],
                            stops: [0.0, 0.38, 0.74, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
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
                                    color: const Color(
                                      0xFFA85BFF,
                                    ).withValues(alpha: 0.42),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'TRUTH  .  DARE  .  DRINK  .  NO ESCAPE',
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
                        icon: Icons.chevron_right_rounded,
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
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              color: Color(0xFFFFC83D),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Premium',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, PremiumScreen.routeName);
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

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton({
    required this.subtitle,
    required this.onTap,
    this.title,
    this.leading,
    this.icon,
  });

  final String subtitle;
  final VoidCallback onTap;
  final String? title;
  final Widget? leading;
  final IconData? icon;

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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leading != null)
                    leading!
                  else
                    Text(
                      title ?? '',
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
              icon ?? Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ],
        ),
      ),
    );
  }
}
