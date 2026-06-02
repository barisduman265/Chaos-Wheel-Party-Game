import 'package:chaos_wheel_party_game/models/prompt_models.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
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
  int _customRoundCount = 30;
  int _customShotRights = 2;
  int _customTargetRights = 2;
  PromptVibeMode _vibeMode = PromptVibeMode.spicy;
  bool _balanceRuleEnabled = true;
  bool _randomButtonEnabled = true;
  bool _customModeSelected = false;
  bool _advancedSettingsExpanded = false;
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

  bool get _isQuick => !_customModeSelected && _roundCount == 15;
  bool get _isParty => !_customModeSelected && _roundCount == 25;
  bool get _isTotal => !_customModeSelected && _roundCount == 40;
  int get _effectiveRoundCount =>
      _customModeSelected ? _customRoundCount : _roundCount;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final passRights = _customModeSelected
        ? _customShotRights
        : provider.calculatePassRights(_roundCount);
    final targetRights = _customModeSelected
        ? _customTargetRights
        : provider.calculateTargetRights(_roundCount);
    final playerRange = _playerRangeFor(_effectiveRoundCount);
    final playerCount = provider.players.length;
    final isPremium = provider.isPremiumUser;

    return Scaffold(
      body: Stack(
        children: [
          const ChaosBackground(child: SizedBox.expand()),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.2, -0.7),
                radius: 1.4,
                colors: [
                  _vibeAccent.withValues(alpha: 0.22),
                  _vibeAccent.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundBackButton(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 20),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 400),
                    style:
                        Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 0.96,
                          shadows: [
                            Shadow(
                              color: _vibeAccent.withValues(alpha: 0.55),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                    child: Text(provider.l('chooseYourPoison')),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.l('howChaoticTonight'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 14),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(provider.l('vibe'), accent: _vibeAccent),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.62,
                          children: [
                            _VibeCard(
                              label: provider.l('cozy'),
                              subtitle: provider.l('cozyDesc'),
                              icon: Icons.auto_awesome_rounded,
                              accent: const Color(0xFF61D8FF),
                              secondary: const Color(0xFF806CFF),
                              selected: _vibeMode == PromptVibeMode.cozy,
                              onTap: () => setState(
                                () => _vibeMode = PromptVibeMode.cozy,
                              ),
                            ),
                            _VibeCard(
                              label: provider.l('spicy'),
                              subtitle: provider.l('spicyDesc'),
                              icon: Icons.local_fire_department_rounded,
                              accent: const Color(0xFFFF4E92),
                              secondary: const Color(0xFFFF7B2F),
                              selected: _vibeMode == PromptVibeMode.spicy,
                              onTap: () => setState(
                                () => _vibeMode = PromptVibeMode.spicy,
                              ),
                            ),
                            _VibeCard(
                              label: provider.l('unhinged'),
                              subtitle: provider.l('unhingedDesc'),
                              icon: Icons.bolt_rounded,
                              accent: const Color(0xFFA85BFF),
                              secondary: const Color(0xFF39D2FF),
                              selected: _vibeMode == PromptVibeMode.unhinged,
                              onTap: () => setState(
                                () => _vibeMode = PromptVibeMode.unhinged,
                              ),
                            ),
                            _VibeCard(
                              label: provider.l('evil'),
                              subtitle: provider.l('evilDesc'),
                              icon: Icons.lock_rounded,
                              accent: const Color(0xFFFFC44D),
                              secondary: const Color(0xFFFF3D81),
                              selected:
                                  isPremium && _vibeMode == PromptVibeMode.evil,
                              locked: !isPremium,
                              onTap: () {
                                if (!isPremium) {
                                  context.read<GameProvider>().playSfx(
                                    ChaosSfx.premiumLocked,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    PremiumScreen.routeName,
                                  );
                                  return;
                                }
                                setState(() => _vibeMode = PromptVibeMode.evil);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _CurrentVibeCard(
                          vibe: _localizedVibe(provider, _vibeMode),
                          summary: _localizedChaosSummary(provider),
                          accent: _vibeAccent,
                        ),
                        const SizedBox(height: 18),
                        _SectionLabel(
                          provider.l('gameMode'),
                          accent: const Color(0xFF7AB8FF),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.65,
                          children: [
                            _ModeCard(
                              leading: '15',
                              label: provider.l('quickChaos'),
                              subtitle: provider.lf('playersShotsTargets', {
                                'players': '3-5',
                                'shots': 1,
                                'targets': 1,
                              }),
                              icon: Icons.bolt_rounded,
                              selected: _isQuick,
                              colors: const [
                                Color(0xFF1263B3),
                                Color(0xFF12306C),
                              ],
                              accent: const Color(0xFF39DDFF),
                              onTap: () => setState(() {
                                _customModeSelected = false;
                                _roundCount = 15;
                              }),
                            ),
                            _ModeCard(
                              leading: '25',
                              label: provider.l('partyChaos'),
                              subtitle: provider.lf('playersShotsTargets', {
                                'players': '5-7',
                                'shots': 2,
                                'targets': 1,
                              }),
                              icon: Icons.local_fire_department_rounded,
                              selected: _isParty,
                              colors: const [
                                Color(0xFFC13A66),
                                Color(0xFF77224E),
                              ],
                              accent: const Color(0xFFFF5FA0),
                              onTap: () => setState(() {
                                _customModeSelected = false;
                                _roundCount = 25;
                              }),
                            ),
                            _ModeCard(
                              leading: '40',
                              label: provider.l('totalChaos'),
                              subtitle: provider.lf(
                                'playersShotsTargetsPlural',
                                {'players': '7-10', 'shots': 3, 'targets': 2},
                              ),
                              icon: Icons.workspace_premium_rounded,
                              selected: _isTotal,
                              colors: const [
                                Color(0xFF6737C7),
                                Color(0xFF2A176A),
                              ],
                              accent: const Color(0xFFD580FF),
                              onTap: () => setState(() {
                                _customModeSelected = false;
                                _roundCount = 40;
                              }),
                            ),
                            _ModeCard(
                              leading: '∞',
                              label: provider.l('customGame'),
                              subtitle: isPremium
                                  ? provider.l('customGameDesc')
                                  : provider.l('premiumHouseRules'),
                              icon: Icons.lock_rounded,
                              selected: _customModeSelected,
                              locked: !isPremium,
                              colors: const [
                                Color(0xFFFFC44D),
                                Color(0xFF5B2A12),
                              ],
                              accent: const Color(0xFFFFC44D),
                              onTap: () {
                                if (!isPremium) {
                                  context.read<GameProvider>().playSfx(
                                    ChaosSfx.premiumLocked,
                                  );
                                  Navigator.pushNamed(
                                    context,
                                    PremiumScreen.routeName,
                                  );
                                  return;
                                }
                                setState(() {
                                  _customModeSelected = true;
                                  _roundCount = _customRoundCount;
                                });
                              },
                            ),
                          ],
                        ),
                        if (_customModeSelected && isPremium) ...[
                          const SizedBox(height: 12),
                          _CustomRulesPanel(
                            rounds: _customRoundCount,
                            shots: _customShotRights,
                            targets: _customTargetRights,
                            onRoundsChanged: (value) {
                              setState(() {
                                _customRoundCount = value;
                                _roundCount = value;
                              });
                            },
                            onShotsChanged: (value) {
                              setState(() => _customShotRights = value);
                            },
                            onTargetsChanged: (value) {
                              setState(() => _customTargetRights = value);
                            },
                          ),
                        ],
                        const SizedBox(height: 14),
                        _NoEscapeRuleCard(
                          rounds: provider.noEscapeRoundCountFor(
                            _effectiveRoundCount,
                          ),
                          totalRounds: _effectiveRoundCount,
                        ),
                        const SizedBox(height: 14),
                        _SectionLabel(provider.l('perPlayerRights')),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _RightsCard(
                                icon: Icons.local_bar_outlined,
                                label: provider.l('shots'),
                                subtitle: provider.l('perPlayer'),
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
                                label: provider.l('targets'),
                                subtitle: provider.l('redirectEach'),
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
                        const SizedBox(height: 18),
                        _AdvancedSettingsCard(
                          expanded: _advancedSettingsExpanded,
                          onToggle: () {
                            setState(
                              () => _advancedSettingsExpanded =
                                  !_advancedSettingsExpanded,
                            );
                          },
                          children: [
                            _SettingCard(
                              icon: Icons.balance_rounded,
                              title: provider.l('balanceRule'),
                              subtitle: provider.l('balanceRuleDesc'),
                              value: _balanceRuleEnabled,
                              onChanged: (value) {
                                setState(() => _balanceRuleEnabled = value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _SettingCard(
                              icon: Icons.casino_rounded,
                              title: provider.l('randomButton'),
                              subtitle: provider.l('randomButtonDesc'),
                              value: _randomButtonEnabled,
                              onChanged: (value) {
                                setState(() => _randomButtonEnabled = value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _StartChaosButton(
                  roundCount: _roundCount,
                  customMode: _customModeSelected,
                  playerCount: playerCount,
                  vibeMode: _vibeMode,
                  provider: provider,
                  accent: _startAccent,
                  noEscapeStartRound: provider.noEscapeStartRoundFor(
                    _effectiveRoundCount,
                  ),
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
                      roundCount: _effectiveRoundCount,
                      balanceRuleEnabled: _balanceRuleEnabled,
                      randomButtonEnabled: _randomButtonEnabled,
                      revengeModeEnabled: _vibeMode == PromptVibeMode.evil,
                      vibeMode: _vibeMode,
                      customPassRights: _customModeSelected
                          ? _customShotRights
                          : null,
                      customTargetRights: _customModeSelected
                          ? _customTargetRights
                          : null,
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
      ],
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

  Color get _vibeAccent {
    return switch (_vibeMode) {
      PromptVibeMode.cozy => const Color(0xFF61D8FF),
      PromptVibeMode.spicy => const Color(0xFFFF4E92),
      PromptVibeMode.unhinged => const Color(0xFFA85BFF),
      PromptVibeMode.evil => const Color(0xFFFFC44D),
    };
  }

  String _localizedVibe(GameProvider provider, PromptVibeMode vibe) {
    return switch (vibe) {
      PromptVibeMode.cozy => provider.l('cozy'),
      PromptVibeMode.spicy => provider.l('spicy'),
      PromptVibeMode.unhinged => provider.l('unhinged'),
      PromptVibeMode.evil => provider.l('evil'),
    };
  }

  String _localizedChaosSummary(GameProvider provider) {
    return switch (_vibeMode) {
      PromptVibeMode.cozy => provider.l('cozySummary'),
      PromptVibeMode.spicy => provider.l('spicySummary'),
      PromptVibeMode.unhinged => provider.l('unhingedSummary'),
      PromptVibeMode.evil => provider.l('evilSummary'),
    };
  }

  Color get _startAccent {
    return switch (_vibeMode) {
      PromptVibeMode.cozy => const Color(0xFF61D8FF),
      PromptVibeMode.spicy => const Color(0xFFFF4E92),
      PromptVibeMode.unhinged => const Color(0xFFA85BFF),
      PromptVibeMode.evil => const Color(0xFFFFC44D),
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
  const _SectionLabel(this.text, {this.accent});

  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (accent != null) ...[
          Container(
            width: 3,
            height: 13,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: accent,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 12,
            letterSpacing: 4.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
    this.locked = false,
  });

  final String leading;
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final List<Color> colors;
  final Color accent;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.03 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      colors.first.withValues(alpha: 0.82),
                      colors.last.withValues(alpha: 0.68),
                    ]
                  : [
                      colors.first.withValues(alpha: 0.38),
                      colors.last.withValues(alpha: 0.28),
                    ],
            ),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.85)
                  : locked
                  ? accent.withValues(alpha: 0.28)
                  : colors.first.withValues(alpha: 0.30),
              width: selected ? 1.6 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.32),
                      blurRadius: 26,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.15),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                            color: selected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.55),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(
                        alpha: selected ? 0.18 : 0.07,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(
                          alpha: selected ? 0.22 : 0.10,
                        ),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: selected
                          ? Colors.white
                          : locked
                          ? accent
                          : Colors.white.withValues(alpha: 0.50),
                      size: 17,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (locked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: accent.withValues(alpha: 0.14),
                    border: Border.all(color: accent.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.70),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VibeCard extends StatelessWidget {
  const _VibeCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.secondary,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color secondary;
  final bool selected;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      scale: selected ? 1.03 : 1.0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? [
                      accent.withValues(alpha: 0.50),
                      secondary.withValues(alpha: 0.38),
                      const Color(0xFF0D0118).withValues(alpha: 0.42),
                    ]
                  : [
                      accent.withValues(alpha: 0.10),
                      secondary.withValues(alpha: 0.06),
                      const Color(0xFF0D0118).withValues(alpha: 0.68),
                    ],
            ),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.92)
                  : locked
                  ? accent.withValues(alpha: 0.30)
                  : Colors.white.withValues(alpha: 0.14),
              width: selected ? 1.8 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.38),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 60,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(
                            alpha: selected ? 1.0 : 0.72,
                          ),
                          secondary.withValues(
                            alpha: selected ? 0.88 : 0.55,
                          ),
                        ],
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.55),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(icon, color: Colors.white, size: 19),
                  ),
                  const Spacer(),
                  if (selected)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.22),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.85),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: accent,
                        size: 13,
                      ),
                    )
                  else if (locked)
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: Color(0xFFFFC44D),
                      size: 20,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: selected
                      ? Colors.white
                      : locked
                      ? accent
                      : const Color(0xFFF3EEFF),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.82)
                      : Colors.white.withValues(alpha: 0.52),
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentVibeCard extends StatelessWidget {
  const _CurrentVibeCard({
    required this.vibe,
    required this.summary,
    required this.accent,
  });

  final String vibe;
  final String summary;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.035),
        border: Border.all(color: accent.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.22)),
            ),
            child: Icon(Icons.nightlife_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.watch<GameProvider>().l('currentVibe'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            vibe,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomRulesPanel extends StatelessWidget {
  const _CustomRulesPanel({
    required this.rounds,
    required this.shots,
    required this.targets,
    required this.onRoundsChanged,
    required this.onShotsChanged,
    required this.onTargetsChanged,
  });

  final int rounds;
  final int shots;
  final int targets;
  final ValueChanged<int> onRoundsChanged;
  final ValueChanged<int> onShotsChanged;
  final ValueChanged<int> onTargetsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFC44D).withValues(alpha: 0.08),
            const Color(0xFFFF3D81).withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.025),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFC44D).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          _CustomStepper(
            label: 'ROUNDS',
            value: rounds,
            min: 10,
            max: 50,
            step: 5,
            onChanged: onRoundsChanged,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _CustomStepper(
                  label: 'SHOTS',
                  value: shots,
                  min: 0,
                  max: 5,
                  onChanged: onShotsChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CustomStepper(
                  label: 'TARGETS',
                  value: targets,
                  min: 0,
                  max: 4,
                  onChanged: onTargetsChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomStepper extends StatelessWidget {
  const _CustomStepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.045),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFF3EEFF),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          _StepButton(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged((value - step).clamp(min, max)),
          ),
          const SizedBox(width: 8),
          _StepButton(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? const Color(0xFFFFC44D).withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: enabled
                ? const Color(0xFFFFC44D).withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          icon,
          color: enabled
              ? const Color(0xFFFFD875)
              : Colors.white.withValues(alpha: 0.28),
          size: 18,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFFF3D81).withValues(alpha: 0.075),
            const Color(0xFF8A55FF).withValues(alpha: 0.055),
            const Color(0xFF39D2FF).withValues(alpha: 0.025),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFF5D98).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF3D81).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFFF5D98).withValues(alpha: 0.34),
              ),
            ),
            child: const Icon(
              Icons.link_off_rounded,
              color: Color(0xFFFF5D98),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.watch<GameProvider>().l('noEscapeActivates'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF3EEFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.watch<GameProvider>().lf('inRound', {
                    'round': totalRounds - rounds + 1,
                  }),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFFF6A9B),
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.watch<GameProvider>().l('shotsTargetsLocked'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w400,
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
    required this.label,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String value;
  final Color accent;
  final List<Color> background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            background.first.withValues(alpha: 0.78),
            background.last.withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.58),
                  accent.withValues(alpha: 0.24),
                ],
              ),
            ),
            child: Icon(icon, color: const Color(0xFFF3EEFF), size: 22),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: accent,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  height: 0.92,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdvancedSettingsCard extends StatelessWidget {
  const _AdvancedSettingsCard({
    required this.expanded,
    required this.onToggle,
    required this.children,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFA85BFF).withValues(alpha: 0.12),
                      border: Border.all(
                        color: const Color(0xFFA85BFF).withValues(alpha: 0.22),
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFFD8C5F2),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.watch<GameProvider>().l(
                            'advancedChaosSettings',
                          ),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFFF3EEFF),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.watch<GameProvider>().l(
                            'modifiersLocksPremiumChaos',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.50),
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: expanded ? 0.5 : 0,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFA85BFF).withValues(alpha: 0.10),
              border: Border.all(
                color: const Color(0xFFA85BFF).withValues(alpha: 0.18),
              ),
            ),
            child: Icon(icon, color: const Color(0xFFD8C5F2), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF3EEFF),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.54),
                    fontWeight: FontWeight.w400,
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

class _StartChaosButton extends StatelessWidget {
  const _StartChaosButton({
    required this.roundCount,
    required this.customMode,
    required this.playerCount,
    required this.vibeMode,
    required this.provider,
    required this.accent,
    required this.noEscapeStartRound,
    required this.onPressed,
  });

  final int roundCount;
  final bool customMode;
  final int playerCount;
  final PromptVibeMode vibeMode;
  final GameProvider provider;
  final Color accent;
  final int noEscapeStartRound;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final vibeLabel = switch (vibeMode) {
      PromptVibeMode.cozy => '${provider.l('cozy')} CHAOS',
      PromptVibeMode.spicy => '${provider.l('spicy')} CHAOS',
      PromptVibeMode.unhinged => provider.l('unhinged'),
      PromptVibeMode.evil => '${provider.l('evil')} CHAOS',
    };
    final title = customMode
        ? provider.l('startCustomGame')
        : provider.lf('startChaos', {'vibe': vibeLabel});

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              accent.withValues(alpha: 0.58),
              const Color(0xFFFF3D81).withValues(alpha: 0.62),
              const Color(0xFFA85BFF).withValues(alpha: 0.54),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3D81).withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFF3EEFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$roundCount ${provider.l('rounds').toLowerCase()} · $playerCount ${provider.l('players').toLowerCase()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.66),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
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
