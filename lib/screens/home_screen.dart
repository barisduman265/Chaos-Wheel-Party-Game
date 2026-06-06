import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/how_to_play_screen.dart';
import 'package:chaos_wheel_party_game/screens/premium_screen.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/services/app_localization_service.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _musicTriggered = false;

  void _tryStartMusic() {
    if (_musicTriggered) return;
    _musicTriggered = true;
    context.read<GameProvider>().playHomeMusic();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _tryStartMusic,
        child: ChaosBackground(
          child: Stack(
            children: [
              const _HomeAmbientPulse(),
              SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final heroGap = (constraints.maxHeight * 0.28).clamp(
                    124.0,
                    240.0,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 46,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 72),
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
                            provider.l('homeTagline'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.56),
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3.2,
                                ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(height: heroGap),
                          PrimaryButton(
                            label: provider.l('startGame'),
                            subtitle: provider.l('startGameSubtitle'),
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
                            title: provider.l('howToPlay'),
                            subtitle: provider.l('rulesOfChaos'),
                            icon: Icons.chevron_right_rounded,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                HowToPlayScreen.routeName,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _HomeMenuButton(
                            title: provider.l('premium'),
                            subtitle: provider.l('unlockChaosMode'),
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
                                  provider.l('premium'),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
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
                  );
                },
              ),
            ),
            Positioned(
              top: MediaQuery.paddingOf(context).top + 16,
              right: 18,
              child: _HomeTopIcon(
                icon: Icons.settings_rounded,
                onTap: () => showAppSettingsSheet(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}

/// Opens the full app settings sheet (audio, gameplay, language, privacy,
/// data reset, legal). Shared by the home screen and the game summary screen.
void showAppSettingsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<GameProvider>(
        builder: (context, provider, _) {
          return Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF221034), Color(0xFF12051E)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.42),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.chevron_left_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          provider.l('appSettings'),
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: const Color(0xFF62D8FF),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.l('settingsDescription'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SettingsGroupLabel(provider.l('general')),
                  _SettingsSwitchRow(
                    icon: Icons.volume_up_rounded,
                    title: provider.l('soundEffects'),
                    value: provider.soundEnabled,
                    onChanged: context.read<GameProvider>().setSoundEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.vibration_rounded,
                    title: provider.l('haptics'),
                    value: provider.vibrationEnabled,
                    onChanged: context.read<GameProvider>().setVibrationEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.music_note_rounded,
                    title: provider.l('backgroundMusic'),
                    value: provider.backgroundMusicEnabled,
                    onChanged: context
                        .read<GameProvider>()
                        .setBackgroundMusicEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.motion_photos_off_rounded,
                    title: provider.l('reduceAnimations'),
                    value: provider.reduceAnimationsEnabled,
                    onChanged: context
                        .read<GameProvider>()
                        .setReduceAnimationsEnabled,
                  ),
                  const SizedBox(height: 8),
                  _SettingsGroupLabel(provider.l('gameplay')),
                  _SettingsSwitchRow(
                    icon: Icons.local_bar_outlined,
                    title: provider.l('enableDrinkingPrompts'),
                    value: provider.drinkingPromptsEnabled,
                    onChanged: context
                        .read<GameProvider>()
                        .setDrinkingPromptsEnabled,
                  ),
                  _SettingsSwitchRow(
                    icon: Icons.warning_amber_rounded,
                    title: provider.l('allowExtremePrompts'),
                    value: provider.extremePromptsEnabled,
                    onChanged: context
                        .read<GameProvider>()
                        .setExtremePromptsEnabled,
                  ),
                  _SettingsActionRow(
                    icon: Icons.language_rounded,
                    title: provider.l('language'),
                    subtitle: provider.promptLanguage,
                    onTap: () => _showLanguageSheet(context),
                  ),
                  const SizedBox(height: 8),
                  _SettingsGroupLabel(provider.l('account')),
                  _SettingsActionRow(
                    icon: Icons.workspace_premium_rounded,
                    title: provider.l('premiumStatus'),
                    subtitle: provider.isPremiumUser
                        ? provider.l('lifetimeUnlocked')
                        : provider.l('freePlan'),
                    accent: const Color(0xFFFFC44D),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, PremiumScreen.routeName);
                    },
                  ),
                  _SettingsActionRow(
                    icon: Icons.star_rate_rounded,
                    title: provider.l('rateApp'),
                    onTap: () => _openRateApp(context),
                  ),
                  _SettingsActionRow(
                    icon: Icons.bug_report_outlined,
                    title: provider.l('reportProblem'),
                    subtitle: provider.l('reportProblemDesc'),
                    accent: const Color(0xFF55F0B0),
                    onTap: () => _openReportProblem(context),
                  ),
                  const SizedBox(height: 8),
                  _SettingsGroupLabel(provider.l('legal')),
                  _SettingsActionRow(
                    icon: Icons.delete_sweep_rounded,
                    title: provider.l('resetStatistics'),
                    subtitle: provider.l('clearsLocalGameData'),
                    accent: const Color(0xFFFF5D98),
                    onTap: () {
                      context.read<GameProvider>().resetAppData();
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.l('appDataReset'))),
                      );
                    },
                  ),
                  _SettingsActionRow(
                    icon: Icons.privacy_tip_outlined,
                    title: provider.l('privacyPolicy'),
                    onTap: () => _showInfoDialog(
                      context,
                      title: provider.l('privacyPolicyTitle'),
                      body: provider.l('privacyPolicyBody'),
                    ),
                  ),
                  _SettingsActionRow(
                    icon: Icons.article_outlined,
                    title: provider.l('terms'),
                    onTap: () => _showInfoDialog(
                      context,
                      title: provider.l('terms'),
                      body: provider.l('termsBody'),
                    ),
                  ),
                  _SettingsActionRow(
                    icon: Icons.info_outline_rounded,
                    title: provider.l('version'),
                    subtitle: '0.1.0',
                    onTap: () => _showInfoDialog(
                      context,
                      title: provider.l('version'),
                      body: provider.l('versionBody'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void _showLanguageSheet(BuildContext context) {
  const languages = AppLocalizationService.supportedLanguages;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<GameProvider>(
        builder: (context, provider, _) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(18),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.72,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF221034), Color(0xFF12051E)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.l('appLanguage'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF62D8FF),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  provider.l('appLanguageDescription'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      final selected = provider.promptLanguage == language;
                      return _SettingsActionRow(
                        icon: selected
                            ? Icons.check_circle_rounded
                            : Icons.language_rounded,
                        title: language,
                        subtitle: selected
                            ? provider.l('activeLanguage')
                            : null,
                        accent: selected
                            ? const Color(0xFF62D8FF)
                            : const Color(0xFFB985FF),
                        onTap: () {
                          context.read<GameProvider>().setPromptLanguage(
                            language,
                          );
                          Navigator.pop(sheetContext);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showInfoDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: const Color(0xFF160A24),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(
          body,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.read<GameProvider>().l('ok')),
          ),
        ],
      );
    },
  );
}

Future<void> _openRateApp(BuildContext context) async {
  final uri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.example.chaos_wheel_party_game',
  );
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.read<GameProvider>().l('storeOpenFailed')),
      ),
    );
  }
}

Future<void> _openReportProblem(BuildContext context) async {
  const email = 'barisduman265@gmail.com';
  final provider = context.read<GameProvider>();
  final subject = 'Chaos Wheel - ${provider.l('reportProblem')}';
  final body =
      '\n\n\n---\nChaos Wheel 0.1.0\n${provider.promptLanguage}';
  final uri = Uri(
    scheme: 'mailto',
    path: email,
    query:
        'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.lf('reportProblemFailed', {'email': email})),
      ),
    );
  }
}

class _SettingsGroupLabel extends StatelessWidget {
  const _SettingsGroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.40),
          fontWeight: FontWeight.w900,
          letterSpacing: 2.4,
        ),
      ),
    );
  }
}

class _HomeTopIcon extends StatelessWidget {
  const _HomeTopIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return _SettingsShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF62D8FF),
        activeTrackColor: const Color(0xFF62D8FF).withValues(alpha: 0.28),
        inactiveThumbColor: Colors.white.withValues(alpha: 0.45),
        inactiveTrackColor: Colors.white.withValues(alpha: 0.10),
      ),
    );
  }
}

class _SettingsActionRow extends StatelessWidget {
  const _SettingsActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.accent = const Color(0xFF62D8FF),
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _SettingsShell(
      icon: icon,
      title: title,
      subtitle: subtitle,
      accent: accent,
      onTap: onTap,
      child: Icon(
        Icons.chevron_right_rounded,
        color: Colors.white.withValues(alpha: 0.52),
      ),
    );
  }
}

class _SettingsShell extends StatelessWidget {
  const _SettingsShell({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.accent = const Color(0xFF62D8FF),
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.055),
            border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.14),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Icon(icon, color: accent, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAmbientPulse extends StatefulWidget {
  const _HomeAmbientPulse();

  @override
  State<_HomeAmbientPulse> createState() => _HomeAmbientPulseState();
}

class _HomeAmbientPulseState extends State<_HomeAmbientPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.18),
                  radius: 0.72 + (_controller.value * 0.08),
                  colors: [
                    const Color(
                      0xFFA85BFF,
                    ).withValues(alpha: 0.06 + (_controller.value * 0.025)),
                    const Color(0xFFFF3D81).withValues(alpha: 0.025),
                    Colors.transparent,
                  ],
                ),
              ),
            );
          },
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
