import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/add_players_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameSummaryScreen extends StatelessWidget {
  const GameSummaryScreen({super.key});

  static const routeName = '/summary';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final players = provider.players;

    final stats = [
      _StatData(
        title: 'MVP',
        subtitle: 'Most picked',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFD66B),
        value: _winner(players, (player) => player.pickedCount),
      ),
      _StatData(
        title: 'Biggest Escaper',
        subtitle: 'Most drinks used',
        icon: Icons.local_bar_rounded,
        color: const Color(0xFF71D2FF),
        value: _winner(players, (player) => player.passUsed),
      ),
      _StatData(
        title: 'Sniper',
        subtitle: 'Most targets used',
        icon: Icons.gps_fixed_rounded,
        color: const Color(0xFFFF5D98),
        value: _winner(players, (player) => player.targetUsed),
      ),
      _StatData(
        title: 'Most Hated',
        subtitle: 'Most targeted',
        icon: Icons.crisis_alert_rounded,
        color: const Color(0xFFFF7B2F),
        value: _winner(players, (player) => player.targetedCount),
      ),
      _StatData(
        title: 'Fearless',
        subtitle: 'Least drinks used',
        icon: Icons.shield_rounded,
        color: const Color(0xFF55F0B0),
        value: _least(players, (player) => player.passUsed),
      ),
      _StatData(
        title: 'Dare Devil',
        subtitle: 'Most dares',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFA85BFF),
        value: _winner(players, (player) => player.dareCount),
      ),
      _StatData(
        title: 'Honest Soul',
        subtitle: 'Most truths',
        icon: Icons.question_answer_rounded,
        color: const Color(0xFF7AB8FF),
        value: _winner(players, (player) => player.truthCount),
      ),
      _StatData(
        title: 'Suspiciously Safe',
        subtitle: 'Truth-heavy',
        icon: Icons.visibility_rounded,
        color: const Color(0xFFFF8BD1),
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
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            children: [
              Text(
                'CHAOS\nREPORT',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 0.9,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The wheel kept receipts.',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.66),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              ...stats.map(
                (stat) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _StatTile(data: stat),
                ),
              ),
              const SizedBox(height: 22),
              _SummaryPrimaryAction(
                label: 'PLAY AGAIN',
                icon: Icons.replay_rounded,
                onTap: () {
                  context.read<GameProvider>().resetGameSamePlayers();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    GameScreen.routeName,
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummarySecondaryAction(
                      label: 'NEW GAME',
                      onTap: () {
                        context.read<GameProvider>().startNewGame();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AddPlayersScreen.routeName,
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummarySecondaryAction(
                      label: 'SHARE',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Share results will be added later.'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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

class _SummaryPrimaryAction extends StatelessWidget {
  const _SummaryPrimaryAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 74,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFA85BFF), Color(0xFFD845D7), Color(0xFFFF3D81)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF3D9A).withValues(alpha: 0.32),
              blurRadius: 28,
              spreadRadius: 1,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: const Color(0xFFA85BFF).withValues(alpha: 0.22),
              blurRadius: 36,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 25),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummarySecondaryAction extends StatelessWidget {
  const _SummarySecondaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.08),
              const Color(0xFF12051E).withValues(alpha: 0.56),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF62D9FF).withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.4,
          ),
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
    required this.value,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final valueParts = data.value.split('|');
    final playerName = valueParts.length == 2 ? valueParts.first : data.value;
    final count = valueParts.length == 2 ? valueParts.last : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.color.withValues(alpha: 0.18),
            const Color(0xFF14051F).withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: data.color.withValues(alpha: 0.36)),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: data.color.withValues(alpha: 0.16),
              border: Border.all(color: data.color.withValues(alpha: 0.34)),
            ),
            child: Icon(data.icon, color: data.color, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.56),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 126),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (count.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'x $count',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: data.color.withValues(alpha: 0.78),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
