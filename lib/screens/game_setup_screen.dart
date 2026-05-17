import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  static const routeName = '/setup';

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _roundCount = 15;
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

  bool get _isQuick => _roundCount == 15;
  bool get _isParty => _roundCount == 25;
  bool get _isTotal => _roundCount == 40;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final passRights = provider.calculatePassRights(_roundCount);
    final targetRights = provider.calculateTargetRights(_roundCount);
    final playerRange = _playerRangeFor(_roundCount);
    final playerCount = provider.players.length;

    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RoundBackButton(onPressed: () => Navigator.maybePop(context)),
                const SizedBox(height: 28),
                Text(
                  'Choose your\npoison.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 0.92,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel('ROUNDS'),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.14,
                          children: [
                            _ModeCard(
                              leading: '15',
                              label: 'QUICK CHAOS',
                              subtitle: '3-5 players - 1 shot - 1 target',
                              icon: Icons.bolt_rounded,
                              selected: _isQuick,
                              colors: const [
                                Color(0xFF114C8D),
                                Color(0xFF092A55),
                              ],
                              accent: const Color(0xFF52D6FF),
                              onTap: () => setState(() => _roundCount = 15),
                            ),
                            _ModeCard(
                              leading: '25',
                              label: 'PARTY CHAOS',
                              subtitle: '5-7 players - 2 shots - 1 target',
                              icon: Icons.local_fire_department_rounded,
                              selected: _isParty,
                              colors: const [
                                Color(0xFFB8404E),
                                Color(0xFF742048),
                              ],
                              accent: Colors.white,
                              onTap: () => setState(() => _roundCount = 25),
                            ),
                            _ModeCard(
                              leading: '40',
                              label: 'TOTAL CHAOS',
                              subtitle: '7-10 players - 3 shots - 2 targets',
                              icon: Icons.workspace_premium_rounded,
                              selected: _isTotal,
                              colors: const [
                                Color(0xFF5430A8),
                                Color(0xFF2A176A),
                              ],
                              accent: const Color(0xFFA85BFF),
                              onTap: () => setState(() => _roundCount = 40),
                            ),
                            _LockedModeCard(
                              label: 'CUSTOM',
                              subtitle: 'Your rules',
                              icon: Icons.lock_rounded,
                              colors: const [
                                Color(0xFF5D3A12),
                                Color(0xFF2E2015),
                              ],
                              accent: const Color(0xFFFFC44D),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  PremiumScreen.routeName,
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _NoEscapeRuleCard(
                          rounds: provider.noEscapeRoundCountFor(_roundCount),
                          totalRounds: _roundCount,
                        ),
                        const SizedBox(height: 22),
                        const _SectionLabel('PER-PLAYER RIGHTS'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RightsCard(
                                icon: Icons.local_bar_outlined,
                                value: '$passRights',
                                accent: const Color(0xFF71D2FF),
                                background: const [
                                  Color(0xFF203B67),
                                  Color(0xFF18253E),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _RightsCard(
                                icon: Icons.gps_fixed_rounded,
                                value: '$targetRights',
                                accent: const Color(0xFFFF625D),
                                background: const [
                                  Color(0xFF4A2039),
                                  Color(0xFF35192B),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionLabel('SETTINGS'),
                        const SizedBox(height: 12),
                        _SettingCard(
                          title: 'Balance Rule',
                          subtitle: 'Lock Truth only after 2 Truths in a row',
                          value: _balanceRuleEnabled,
                          onChanged: (value) {
                            setState(() => _balanceRuleEnabled = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _SettingCard(
                          title: 'Random Button',
                          subtitle: 'Let fate decide truth or dare',
                          value: _randomButtonEnabled,
                          onChanged: (value) {
                            setState(() => _randomButtonEnabled = value);
                          },
                        ),
                        const SizedBox(height: 12),
                        _LockedPremiumSettingCard(
                          title: 'Chaos Mode',
                          subtitle: 'Modifiers, dares stacking, double picks',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              PremiumScreen.routeName,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _StartChaosButton(
                  roundCount: _roundCount,
                  onPressed: () {
                    if (playerCount < playerRange.min ||
                        playerCount > playerRange.max) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFF23142D),
                          content: Text(
                            'This mode is built for ${playerRange.min}-${playerRange.max} players.',
                          ),
                        ),
                      );
                      return;
                    }
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
          ),
        ),
      ),
    );
  }

  ({int min, int max}) _playerRangeFor(int roundCount) {
    return switch (roundCount) {
      15 => (min: 3, max: 5),
      25 => (min: 5, max: 7),
      40 => (min: 7, max: 10),
      _ => (min: 2, max: 10),
    };
  }
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.42),
        letterSpacing: 3.2,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.leading,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.colors,
    required this.accent,
    required this.onTap,
  });

  final String leading;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? colors
                : [
                    colors.first.withValues(alpha: 0.34),
                    colors.last.withValues(alpha: 0.22),
                  ],
          ),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: colors.last.withValues(alpha: 0.30),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    leading,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(
                      alpha: selected ? 0.22 : 0.12,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedModeCard extends StatelessWidget {
  const _LockedModeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.first.withValues(alpha: 0.34),
              colors.last.withValues(alpha: 0.22),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Icon(icon, color: accent, size: 20),
                ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _PremiumPill(accent: accent),
          ],
        ),
      ),
    );
  }
}

class _NoEscapeRuleCard extends StatelessWidget {
  const _NoEscapeRuleCard({required this.rounds, required this.totalRounds});

  final int rounds;
  final int totalRounds;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFF3D81).withValues(alpha: 0.18),
            const Color(0xFF8A55FF).withValues(alpha: 0.14),
            const Color(0xFF39D2FF).withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFF5D98).withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3D81).withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF3D81).withValues(alpha: 0.16),
              border: Border.all(
                color: const Color(0xFFFF5D98).withValues(alpha: 0.40),
              ),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFFF5D98),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NO ESCAPE STARTS IN THE FINAL $rounds ROUNDS',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applies to every mode. From round ${totalRounds - rounds + 1}, shots and targets are locked.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontWeight: FontWeight.w700,
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

class _RightsCard extends StatelessWidget {
  const _RightsCard({
    required this.icon,
    required this.value,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final String value;
  final Color accent;
  final List<Color> background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: background,
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.95),
                  accent.withValues(alpha: 0.55),
                ],
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFD8C5F2),
            activeTrackColor: const Color(0xFF7357A8),
            inactiveThumbColor: const Color(0xFF8B7C96),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

class _LockedPremiumSettingCard extends StatelessWidget {
  const _LockedPremiumSettingCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.lock_rounded,
                        size: 16,
                        color: Color(0xFFFFC44D),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.54),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _PremiumPill(accent: Color(0xFFFFC44D)),
          ],
        ),
      ),
    );
  }
}

class _PremiumPill extends StatelessWidget {
  const _PremiumPill({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        'PREMIUM',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: accent,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _StartChaosButton extends StatelessWidget {
  const _StartChaosButton({required this.roundCount, required this.onPressed});

  final int roundCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7B2F), Color(0xFFFF3D81)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF4D78).withValues(alpha: 0.34),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Text(
          'START CHAOS - $roundCount ROUNDS ->',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
