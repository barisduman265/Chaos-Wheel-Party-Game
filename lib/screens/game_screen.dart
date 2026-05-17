import 'dart:async';
import 'dart:math';

import 'package:chaos_wheel_party_game/core/player_colors.dart';
import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/fate_choice_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_summary_screen.dart';
import 'package:chaos_wheel_party_game/screens/picked_reveal_screen.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:chaos_wheel_party_game/widgets/spinning_wheel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const routeName = '/game';

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _wheelController = SpinningWheelController();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final noEscape = provider.isNoEscapeActive;
    final finalSpin = provider.isFinalSpin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      if (state.isGameOver) {
        Navigator.pushReplacementNamed(context, GameSummaryScreen.routeName);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const ChaosBackground(child: SizedBox.expand()),
          if (noEscape)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF3D81).withValues(alpha: 0.08),
                      Colors.transparent,
                      const Color(0xFF09030F).withValues(alpha: 0.18),
                    ],
                    stops: const [0, 0.42, 1],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 18),
              child: Column(
                children: [
                  _TopControls(
                    currentRound: state.currentRound,
                    totalRounds: state.totalRounds,
                    progress: state.totalRounds == 0
                        ? 0
                        : state.currentRound / state.totalRounds,
                    noEscape: noEscape,
                  ),
                  const SizedBox(height: 26),
                  Text(
                    noEscape
                        ? 'NO ESCAPE MODE'
                        : finalSpin
                        ? 'FINAL SPIN'
                        : 'TAP SPIN TO DRAW',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Who's next?",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: SpinningWheel(
                        controller: _wheelController,
                        players: state.players,
                        isSpinning: state.isSpinning,
                        soundEnabled: provider.soundEnabled,
                        suspenseSpin: finalSpin,
                        dangerMode: noEscape,
                        onSpinRequested: () async {
                          return context
                              .read<GameProvider>()
                              .prepareSpinSelection();
                        },
                        onSpinCompleted: (_) async {
                          final message = context
                              .read<GameProvider>()
                              .completeSpinSelection();
                          if (message.isEmpty || !context.mounted) {
                            return;
                          }

                          final player = context
                              .read<GameProvider>()
                              .selectedPlayer;
                          if (player == null) {
                            return;
                          }

                          await PickedRevealScreen.show(context, player.name);
                          if (context.mounted) {
                            await FateChoiceScreen.show(
                              context,
                              player: player,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AutoRosterStrip(players: state.players),
                  const SizedBox(height: 14),
                  _SpinBar(
                    isSpinning: state.isSpinning,
                    hasSelection: state.selectedPlayer != null,
                    enabled: state.players.length >= 2,
                    onTap: () {
                      final selected = context
                          .read<GameProvider>()
                          .selectedPlayer;
                      if (selected != null) {
                        FateChoiceScreen.show(context, player: selected);
                        return;
                      }
                      _wheelController.spin();
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
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.currentRound,
    required this.totalRounds,
    required this.progress,
    required this.noEscape,
  });

  final int currentRound;
  final int totalRounds;
  final double progress;
  final bool noEscape;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _RoundIconButton(
              icon: Icons.chevron_left_rounded,
              onTap: () => Navigator.maybePop(context),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                  children: [
                    TextSpan(
                      text: 'R${currentRound.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: noEscape
                            ? const Color(0xFFFF5D98)
                            : const Color(0xFFA86CFF),
                      ),
                    ),
                    TextSpan(text: ' / $totalRounds'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            _RoundIconButton(icon: Icons.tune_rounded, onTap: () {}),
          ],
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 4,
            value: progress.clamp(0, 1),
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              noEscape ? const Color(0xFFFF5D98) : const Color(0xFFA86CFF),
            ),
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}

class _AutoRosterStrip extends StatefulWidget {
  const _AutoRosterStrip({required this.players});

  final List<Player> players;

  @override
  State<_AutoRosterStrip> createState() => _AutoRosterStripState();
}

class _AutoRosterStripState extends State<_AutoRosterStrip> {
  final _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 36), (_) {
      if (!_controller.hasClients || widget.players.length < 4) {
        return;
      }

      final next = _controller.offset + 0.55;
      if (next >= _controller.position.maxScrollExtent) {
        _controller.jumpTo(0);
        return;
      }
      _controller.jumpTo(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.players.length < 4
        ? widget.players
        : [...widget.players, ...widget.players];

    return SizedBox(
      height: 72,
      child: ListView.separated(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        physics: widget.players.length < 4
            ? const BouncingScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: players.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final player = players[index];
          final playerIndex = widget.players.indexWhere(
            (candidate) => candidate.id == player.id,
          );
          return _MiniPlayerCard(
            player: player,
            colors: playerColorsForIndex(playerIndex < 0 ? index : playerIndex),
          );
        },
      ),
    );
  }
}

class _MiniPlayerCard extends StatelessWidget {
  const _MiniPlayerCard({required this.player, required this.colors});

  final Player player;
  final PlayerColorSet colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 146,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.18),
            colors.secondary.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            player.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              _MiniRight(
                icon: Icons.local_bar_outlined,
                label: '${player.passRights}',
                color: colors.primary,
              ),
              const SizedBox(width: 10),
              _MiniRight(
                icon: Icons.gps_fixed_rounded,
                label: '${player.targetRights}',
                color: colors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniRight extends StatelessWidget {
  const _MiniRight({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _SpinBar extends StatelessWidget {
  const _SpinBar({
    required this.isSpinning,
    required this.hasSelection,
    required this.enabled,
    required this.onTap,
  });

  final bool isSpinning;
  final bool hasSelection;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canSpin = enabled && !isSpinning;
    final label = hasSelection ? 'CHOOSE FATE' : 'SPIN';

    return GestureDetector(
      onTap: canSpin ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: canSpin
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFF7B2F), Color(0xFFFF3D81)],
                )
              : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.white.withValues(alpha: 0.08),
                  ],
                ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          boxShadow: canSpin
              ? [
                  BoxShadow(
                    color: const Color(0x99FF3D81).withValues(alpha: 0.38),
                    blurRadius: 24,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (hasSelection)
                const Icon(Icons.bolt_rounded, color: Colors.white, size: 24)
              else
                const SizedBox(
                  width: 30,
                  height: 30,
                  child: CustomPaint(painter: _SpinGlyphPainter()),
                ),
              const SizedBox(width: 12),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinGlyphPainter extends CustomPainter {
  const _SpinGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width * 0.36;
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.20)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          Colors.white.withValues(alpha: 0.10),
          Colors.white,
          Colors.white.withValues(alpha: 0.65),
          Colors.white.withValues(alpha: 0.10),
        ],
      ).createShader(rect);

    final orbit = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(orbit, -1.25, 4.7, false, glowPaint);
    canvas.drawArc(orbit, -1.25, 4.7, false, arcPaint);

    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final angle = 3.45;
    final arrowCenter = Offset(
      center.dx + cos(angle) * radius,
      center.dy + sin(angle) * radius,
    );
    final arrow = Path()
      ..moveTo(arrowCenter.dx, arrowCenter.dy)
      ..lineTo(arrowCenter.dx + size.width * 0.16, arrowCenter.dy - 1)
      ..lineTo(
        arrowCenter.dx + size.width * 0.06,
        arrowCenter.dy + size.height * 0.13,
      )
      ..close();
    canvas.drawPath(arrow, arrowPaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.92);
    canvas.drawCircle(center, size.width * 0.09, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
