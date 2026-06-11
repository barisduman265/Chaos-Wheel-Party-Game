import 'package:chaos_wheel/models/player.dart';
import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/screens/add_players_screen.dart';
import 'package:chaos_wheel/screens/game_screen.dart';
import 'package:chaos_wheel/screens/home_screen.dart';
import 'package:chaos_wheel/services/share_service.dart';
import 'package:chaos_wheel/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class GameSummaryScreen extends StatefulWidget {
  const GameSummaryScreen({super.key});

  static const routeName = '/summary';

  @override
  State<GameSummaryScreen> createState() => _GameSummaryScreenState();
}

class _GameSummaryScreenState extends State<GameSummaryScreen> {
  final ScreenshotController _reportController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GameProvider>().playHomeMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final players = provider.players;

    final stats = [
      _StatData(
        title: provider.l('mvp'),
        subtitle: provider.l('mostPicked'),
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFD66B),
        surface: const Color(0xFF6B4220),
        value: _winner(players, (player) => player.pickedCount),
      ),
      _StatData(
        title: provider.l('biggestEscaper'),
        subtitle: provider.l('mostShotsUsed'),
        icon: Icons.local_bar_rounded,
        color: const Color(0xFF71D2FF),
        surface: const Color(0xFF153A6B),
        value: _winner(players, (player) => player.passUsed),
      ),
      _StatData(
        title: provider.l('sniper'),
        subtitle: provider.l('mostTargetsUsed'),
        icon: Icons.gps_fixed_rounded,
        color: const Color(0xFFFF5D98),
        surface: const Color(0xFF6A173F),
        value: _winner(players, (player) => player.targetUsed),
      ),
      _StatData(
        title: provider.l('mostHated'),
        subtitle: provider.l('mostTargeted'),
        icon: Icons.crisis_alert_rounded,
        color: const Color(0xFFFF8A3D),
        surface: const Color(0xFF6B2818),
        value: _winner(players, (player) => player.targetedCount),
      ),
      _StatData(
        title: provider.l('fearless'),
        subtitle: provider.l('leastShotsUsed'),
        icon: Icons.shield_rounded,
        color: const Color(0xFF55F0B0),
        surface: const Color(0xFF164E3C),
        value: _least(players, (player) => player.passUsed),
      ),
      _StatData(
        title: provider.l('dareDevil'),
        subtitle: provider.l('mostDares'),
        icon: Icons.bolt_rounded,
        color: const Color(0xFFA85BFF),
        surface: const Color(0xFF351A6D),
        value: _winner(players, (player) => player.dareCount),
      ),
      _StatData(
        title: provider.l('honestSoul'),
        subtitle: provider.l('mostTruths'),
        icon: Icons.question_answer_rounded,
        color: const Color(0xFF7AB8FF),
        surface: const Color(0xFF1A2B68),
        value: _winner(players, (player) => player.truthCount),
      ),
      _StatData(
        title: provider.l('suspiciouslySafe'),
        subtitle: provider.l('truthHeavy'),
        icon: Icons.visibility_rounded,
        color: const Color(0xFFFF8BD1),
        surface: const Color(0xFF5A1849),
        value: _winner(
          players,
          (player) => player.truthCount - player.dareCount,
        ),
      ),
    ];

    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: _SummaryIconButton(
                  icon: Icons.settings_rounded,
                  onTap: () => showAppSettingsSheet(context),
                ),
              ),
              const SizedBox(height: 8),
              Screenshot(
                controller: _reportController,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.l('chaosReport'),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 0.9,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        provider.l('wheelKeptReceipts'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.66),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ...stats.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(
                              milliseconds: 240 + (entry.key * 38),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 12 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: _StatTile(
                              data: entry.value,
                              prominent: false,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _SummaryActionButton(
                label: provider.l('shareTheChaos'),
                icon: Icons.ios_share_rounded,
                gradientColors: const [
                  Color(0xFFA85BFF),
                  Color(0xFFD845D7),
                  Color(0xFFFF3D81),
                ],
                glowColor: const Color(0xFFFF3D9A),
                onTap: () {
                  const ChaosShareService().shareChaosReport(
                    players: players,
                    totalRounds: provider.state.totalRounds,
                    screenshotController: _reportController,
                  );
                },
              ),
              const SizedBox(height: 10),
              _SummaryActionButton(
                label: provider.l('playAgain'),
                icon: Icons.replay_rounded,
                gradientColors: const [
                  Color(0xFF1A6BDB),
                  Color(0xFF2A9DFF),
                  Color(0xFF39D2FF),
                ],
                glowColor: const Color(0xFF39D2FF),
                onTap: () {
                  context.read<GameProvider>().resetGameSamePlayers();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    GameScreen.routeName,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
              _SummaryActionButton(
                label: provider.l('newGame'),
                icon: Icons.add_rounded,
                gradientColors: const [
                  Color(0xFF12A878),
                  Color(0xFF1FC98A),
                  Color(0xFF55F0B0),
                ],
                glowColor: const Color(0xFF1FC98A),
                onTap: () {
                  context.read<GameProvider>().startNewGame();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AddPlayersScreen.routeName,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _winner(
    List<Player> players,
    int Function(Player player) metric,
  ) {
    if (players.isEmpty) {
      return '-';
    }
    final top = players.reduce((a, b) => metric(a) >= metric(b) ? a : b);
    final value = metric(top);
    return value <= 0 ? '-' : '${top.name}|$value';
  }

  static String _least(
    List<Player> players,
    int Function(Player player) metric,
  ) {
    if (players.isEmpty) {
      return '-';
    }
    final top = players.reduce((a, b) => metric(a) <= metric(b) ? a : b);
    return '${top.name}|${metric(top)}';
  }
}

class _SummaryIconButton extends StatelessWidget {
  const _SummaryIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

class _SummaryActionButton extends StatelessWidget {
  const _SummaryActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.gradientColors,
    required this.glowColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final Color? glowColor;

  bool get _isGradient => gradientColors != null;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _isGradient
              ? LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: gradientColors!,
                )
              : null,
          color: _isGradient ? null : Colors.white.withValues(alpha: 0.12),
          border: Border.all(
            color: _isGradient
                ? Colors.white.withValues(alpha: 0.22)
                : Colors.white.withValues(alpha: 0.26),
            width: 1.4,
          ),
          boxShadow: _isGradient
              ? [
                  BoxShadow(
                    color: glowColor!.withValues(alpha: 0.36),
                    blurRadius: 24,
                    offset: const Offset(0, 9),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(
                  alpha: _isGradient ? 0.20 : 0.16,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _StatData {
  const _StatData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.surface,
    required this.value,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color surface;
  final String value;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data, required this.prominent});

  final _StatData data;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final valueParts = data.value.split('|');
    final playerName = valueParts.length == 2 ? valueParts.first : data.value;
    final count = valueParts.length == 2 ? valueParts.last : '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.surface.withValues(alpha: 0.34),
            data.color.withValues(alpha: 0.08),
            const Color(0xFF12051E).withValues(alpha: 0.68),
          ],
        ),
        border: Border.all(color: data.color.withValues(alpha: 0.26)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withValues(alpha: 0.12),
              border: Border.all(color: data.color.withValues(alpha: 0.34)),
            ),
            child: Icon(data.icon, color: data.color, size: 27),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (count.isNotEmpty)
                  Text(
                    'x $count',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: data.color.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w900,
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
