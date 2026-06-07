import 'dart:math' as math;

import 'package:chaos_wheel_party_game/core/player_colors.dart';
import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/game_setup_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlayersScreen extends StatefulWidget {
  const AddPlayersScreen({super.key});

  static const routeName = '/players';

  @override
  State<AddPlayersScreen> createState() => _AddPlayersScreenState();
}

class _AddPlayersScreenState extends State<AddPlayersScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addPlayer(BuildContext context) {
    final message = context.read<GameProvider>().addPlayer(_controller.text);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final playerCount = provider.players.length;
    final canStart = playerCount >= 2;
    final playersNeeded = math.max(0, 2 - playerCount);

    return Scaffold(
      body: ChaosBackground(
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundBackButton(
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    provider.l('whoIsPlaying'),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.l('addPlayersHelper'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.62),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: SingleChildScrollView(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: provider.players.isEmpty
                            ? const _EmptyPlayersState()
                            : _PlayersList(players: provider.players),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StartPlayersButton(
                    playerCount: playerCount,
                    playersNeeded: playersNeeded,
                    enabled: canStart,
                    onPressed: () {
                      if (!canStart) {
                        return;
                      }
                      Navigator.pushNamed(context, GameSetupScreen.routeName);
                    },
                  ),
                  const SizedBox(height: 12),
                  _AddPlayerBar(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addPlayer(context),
                    onAddPressed: () => _addPlayer(context),
                    addEnabled: _controller.text.trim().isNotEmpty,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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

class _EmptyPlayersState extends StatelessWidget {
  const _EmptyPlayersState();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRoundedRectPainter(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.025),
        ),
        child: Text(
          context.watch<GameProvider>().l('noPlayersYet'),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.42),
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _PlayersList extends StatelessWidget {
  const _PlayersList({required this.players});

  final List<Player> players;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < players.length; index++) ...[
          _PlayerCard(
            player: players[index],
            colors: playerColorsForIndex(index),
          ),
          if (index != players.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player, required this.colors});

  final Player player;
  final PlayerColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.055),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Text(
              player.name.isEmpty ? '?' : player.name[0].toUpperCase(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: () => context.read<GameProvider>().removePlayer(player.id),
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3D81).withValues(alpha: 0.10),
                border: Border.all(
                  color: const Color(0xFFFF3D81).withValues(alpha: 0.34),
                ),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFFF3D81),
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartPlayersButton extends StatelessWidget {
  const _StartPlayersButton({
    required this.playerCount,
    required this.playersNeeded,
    required this.enabled,
    required this.onPressed,
  });

  final int playerCount;
  final int playersNeeded;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final label = enabled
        ? provider.lf('startPlayers', {'count': playerCount})
        : playersNeeded == 1
        ? provider.l('addOneMorePlayer')
        : provider.lf('addMorePlayers', {'count': playersNeeded});

    if (!enabled) {
      return Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 58),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.045),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    final gradientColors = enabled
        ? const [Color(0xFFA85BFF), Color(0xFFFF3D81)]
        : [
            const Color(0xFFA85BFF).withValues(alpha: 0.34),
            const Color(0xFFFF3D81).withValues(alpha: 0.30),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(28),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 66),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF3D81).withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: const Color(0xFFA85BFF).withValues(alpha: 0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPlayerBar extends StatelessWidget {
  const _AddPlayerBar({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onAddPressed,
    required this.addEnabled,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onAddPressed;
  final bool addEnabled;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.white.withValues(alpha: 0.075),
        border: Border.all(
          color: const Color(0xFF39D2FF).withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.done,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: provider.l('addPlayerName'),
                hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.34),
                  fontWeight: FontWeight.w500,
                ),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              ),
            ),
          ),
          InkWell(
            onTap: addEnabled ? onAddPressed : null,
            borderRadius: BorderRadius.circular(24),
            child: Ink(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: addEnabled
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF39D2FF), Color(0xFFA85BFF)],
                          )
                        : null,
                    color: addEnabled
                        ? null
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: addEnabled
                          ? Colors.white.withValues(alpha: 0.24)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                    boxShadow: addEnabled
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFFF4B76,
                              ).withValues(alpha: 0.34),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white.withValues(
                      alpha: addEnabled ? 1 : 0.36,
                    ),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRoundedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(24),
    );
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const dashWidth = 6.0;
    const dashSpace = 6.0;
    final path = Path()..addRRect(rect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
