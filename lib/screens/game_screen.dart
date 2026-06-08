import 'dart:async';

import 'package:chaos_wheel_party_game/core/player_colors.dart';
import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/models/prompt_models.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/fate_choice_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_summary_screen.dart';
import 'package:chaos_wheel_party_game/screens/picked_reveal_screen.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:chaos_wheel_party_game/widgets/premium_upsell_dialog.dart';
import 'package:chaos_wheel_party_game/widgets/pressable_scale.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GameProvider>().stopMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final noEscape = provider.isNoEscapeActive;
    final finalSpin = provider.isFinalSpin;
    final paused = provider.gamePaused;

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
                    onMenuTap: () => _showGameControlsSheet(context),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    noEscape
                        ? provider.l('noEscapeMode')
                        : finalSpin
                        ? provider.l('finalSpin')
                        : provider.l('tapSpinToDraw'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    provider.l('whosNext'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                          final provider = context.read<GameProvider>();
                          if (provider.gamePaused) {
                            return null;
                          }
                          await provider.playSfx(ChaosSfx.wheelSpinStart);
                          return provider.prepareSpinSelection();
                        },
                        onSpinCompleted: (_) async {
                          final provider = context.read<GameProvider>();
                          await provider.playSfx(ChaosSfx.wheelStop);
                          final message = provider.completeSpinSelection();
                          if (message.isEmpty || !context.mounted) {
                            return;
                          }

                          final player = provider.selectedPlayer;
                          if (player == null) {
                            return;
                          }

                          await PickedRevealScreen.show(context, player.name);
                          if (!context.mounted) {
                            return;
                          }

                          if (provider.consumeUpsellTrigger()) {
                            await showPremiumUpsell(context);
                            if (!context.mounted) {
                              return;
                            }
                          }
                          await FateChoiceScreen.show(context, player: player);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AutoRosterStrip(
                    players: state.players,
                    selectedPlayerId: state.selectedPlayer?.id,
                    noEscape: noEscape,
                    isSpinning: state.isSpinning,
                  ),
                  const SizedBox(height: 12),
                  _SpinBar(
                    isSpinning: state.isSpinning,
                    hasSelection: state.selectedPlayer != null,
                    enabled: state.players.length >= 2 && !paused,
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

void _showGameControlsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<GameProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          final isSpinning = state.isSpinning;

          return _GameControlsSurface(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.l('gameControls'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(sheetContext),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.07),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    provider.l('gameControlsSubtitle'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ControlSection(
                    title: provider.l('round'),
                    children: [
                      _ControlRow(
                        icon: Icons.skip_next_rounded,
                        title: provider.l('skipRound'),
                        subtitle: provider.l('skipRoundDesc'),
                        enabled: !isSpinning,
                        onTap: () {
                          final message = provider.skipRound();
                          Navigator.pop(sheetContext);
                          _showGameSnack(context, message);
                        },
                      ),
                      _ControlRow(
                        icon: Icons.shuffle_rounded,
                        title: provider.l('respinWheel'),
                        subtitle: provider.l('respinWheelDesc'),
                        enabled: !isSpinning,
                        onTap: () {
                          final message = provider.reshuffleWheel();
                          Navigator.pop(sheetContext);
                          _showGameSnack(context, message);
                        },
                      ),
                      _ControlRow(
                        icon: Icons.casino_rounded,
                        title: provider.l('randomizePicker'),
                        subtitle: provider.l('randomizePickerDesc'),
                        enabled: !isSpinning && state.players.length >= 2,
                        onTap: () async {
                          final player = provider.randomizePicker();
                          Navigator.pop(sheetContext);
                          if (player == null || !context.mounted) {
                            _showGameSnack(context, provider.l('addPlayer'));
                            return;
                          }
                          await PickedRevealScreen.show(context, player.name);
                          if (context.mounted) {
                            await FateChoiceScreen.show(
                              context,
                              player: player,
                            );
                          }
                          if (context.mounted &&
                              context
                                  .read<GameProvider>()
                                  .consumeUpsellTrigger()) {
                            await showPremiumUpsell(context);
                          }
                        },
                      ),
                    ],
                  ),
                  _ControlSection(
                    title: provider.l('players'),
                    children: [
                      _ControlRow(
                        icon: Icons.person_add_alt_1_rounded,
                        title: provider.l('addPlayer'),
                        subtitle: provider.l('addPlayerDesc'),
                        enabled: !isSpinning,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showInGameAddPlayerSheet(context);
                        },
                      ),
                      _ControlRow(
                        icon: Icons.group_remove_rounded,
                        title: provider.l('removePlayer'),
                        subtitle: provider.l('removePlayerDesc'),
                        enabled: !isSpinning && state.players.isNotEmpty,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _showInGameRemovePlayerSheet(context);
                        },
                      ),
                    ],
                  ),
                  _ControlSection(
                    title: provider.l('session'),
                    children: [
                      _ControlRow(
                        icon: provider.gamePaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        title: provider.gamePaused
                            ? provider.l('resumeGame')
                            : provider.l('pauseGame'),
                        subtitle: provider.gamePaused
                            ? provider.l('respinWheelDesc')
                            : provider.l('pauseGameDesc'),
                        onTap: () {
                          provider.setGamePaused(!provider.gamePaused);
                          Navigator.pop(sheetContext);
                          _showGameSnack(
                            context,
                            provider.gamePaused
                                ? provider.l('gamePausedMsg')
                                : provider.l('gameResumedMsg'),
                          );
                        },
                      ),
                      _ControlRow(
                        icon: Icons.flag_rounded,
                        title: provider.l('endGame'),
                        subtitle: provider.l('endGameDesc'),
                        accent: const Color(0xFFFF5D98),
                        onTap: () {
                          provider.endGameNow();
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ),
                  _ControlSection(
                    title: provider.l('audio'),
                    children: [
                      _ControlRow(
                        icon: provider.soundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        title: provider.soundEnabled
                            ? provider.l('soundEffectsOn')
                            : provider.l('soundEffectsOff'),
                        subtitle: provider.l('toggleGameplaySfx'),
                        accent: const Color(0xFFB985FF),
                        trailing: Switch(
                          value: provider.soundEnabled,
                          onChanged: (_) {
                            provider.setSoundEnabled(!provider.soundEnabled);
                          },
                          activeTrackColor: const Color(0xFF7357A8),
                          activeThumbColor: const Color(0xFFD8C5F2),
                          inactiveThumbColor: const Color(0xFF8B7C96),
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.10,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () =>
                            provider.setSoundEnabled(!provider.soundEnabled),
                      ),
                      _ControlRow(
                        icon: provider.vibrationEnabled
                            ? Icons.vibration_rounded
                            : Icons.phonelink_off_rounded,
                        title: provider.vibrationEnabled
                            ? provider.l('hapticsOn')
                            : provider.l('hapticsOff'),
                        subtitle: provider.l('toggleHaptics'),
                        accent: const Color(0xFF62D8FF),
                        trailing: Switch(
                          value: provider.vibrationEnabled,
                          onChanged: (_) {
                            provider.setVibrationEnabled(
                              !provider.vibrationEnabled,
                            );
                          },
                          activeTrackColor: const Color(0xFF2B7A8A),
                          activeThumbColor: const Color(0xFF62D8FF),
                          inactiveThumbColor: const Color(0xFF8B7C96),
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.10,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () => provider.setVibrationEnabled(
                          !provider.vibrationEnabled,
                        ),
                      ),
                    ],
                  ),
                  _ControlSection(
                    title: provider.l('safety'),
                    children: [
                      _ControlRow(
                        icon: Icons.health_and_safety_rounded,
                        title: provider.l('toneDownPrompts'),
                        subtitle: provider.l('toneDownPromptsDesc'),
                        accent: const Color(0xFF62D8FF),
                        prominent: true,
                        onTap: () {
                          final mode = provider.toneDownChaos();
                          provider.setExtremePromptsEnabled(false);
                          Navigator.pop(sheetContext);
                          _showGameSnack(
                            context,
                            provider.lf('promptToneReduced', {
                              'mode': mode.label,
                            }),
                          );
                        },
                      ),
                      _ControlRow(
                        icon: provider.drinkingPromptsEnabled
                            ? Icons.local_bar_rounded
                            : Icons.no_drinks_rounded,
                        title: provider.drinkingPromptsEnabled
                            ? provider.l('enableDrinkingPrompts')
                            : provider.l('disableDrinkingPrompts'),
                        subtitle: provider.l('disableDrinkingPromptsDesc'),
                        accent: const Color(0xFF71D2FF),
                        trailing: Switch(
                          value: provider.drinkingPromptsEnabled,
                          onChanged: (_) {
                            provider.setDrinkingPromptsEnabled(
                              !provider.drinkingPromptsEnabled,
                            );
                          },
                          activeTrackColor: const Color(0xFF1A5070),
                          activeThumbColor: const Color(0xFF71D2FF),
                          inactiveThumbColor: const Color(0xFF8B7C96),
                          inactiveTrackColor: Colors.white.withValues(
                            alpha: 0.10,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap: () => provider.setDrinkingPromptsEnabled(
                          !provider.drinkingPromptsEnabled,
                        ),
                      ),
                    ],
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

void _showPlayerControlsSheet(BuildContext context, Player player) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<GameProvider>(
        builder: (context, provider, _) {
          return _GameControlsSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  provider.l('playerControls'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 18),
                _ControlRow(
                  icon: Icons.local_bar_outlined,
                  title: provider.l('giveExtraShot'),
                  subtitle: provider.l('plusOneShotToken'),
                  onTap: () {
                    provider.giveExtraShot(player.id);
                    Navigator.pop(sheetContext);
                    _showGameSnack(
                      context,
                      provider.lf('gotExtraShot', {'player': player.name}),
                    );
                  },
                ),
                _ControlRow(
                  icon: Icons.person_remove_rounded,
                  title: provider.l('removePlayer'),
                  subtitle: provider.l('takeThemOut'),
                  accent: const Color(0xFFFF5D98),
                  onTap: () {
                    provider.removePlayer(player.id);
                    Navigator.pop(sheetContext);
                    _showGameSnack(
                      context,
                      provider.lf('playerRemovedMsg', {'player': player.name}),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showInGameAddPlayerSheet(BuildContext context) {
  final controller = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _GameControlsSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Text(
                context.read<GameProvider>().l('addPlayerTitle'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: context.read<GameProvider>().l('playerNameHint'),
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Color(0xFF62D8FF)),
                  ),
                ),
                onSubmitted: (_) =>
                    _addPlayerFromSheet(context, sheetContext, controller.text),
              ),
              const SizedBox(height: 14),
              PressableScale(
                onTap: () =>
                    _addPlayerFromSheet(context, sheetContext, controller.text),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFA85BFF), Color(0xFFFF3D81)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      context.read<GameProvider>().l('addToGame'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).whenComplete(controller.dispose);
}

void _addPlayerFromSheet(
  BuildContext context,
  BuildContext sheetContext,
  String name,
) {
  final provider = context.read<GameProvider>();
  final message = provider.addPlayer(name);
  if (message != null) {
    _showGameSnack(context, message);
    return;
  }
  Navigator.pop(sheetContext);
  _showGameSnack(
    context,
    provider.lf('playerJoinedMsg', {'player': name.trim()}),
  );
}

void _showInGameRemovePlayerSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Consumer<GameProvider>(
        builder: (context, provider, _) {
          return _GameControlsSurface(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  provider.l('removePlayerTitle'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 14),
                ...provider.players.map((player) {
                  return _ControlRow(
                    icon: Icons.person_remove_rounded,
                    title: player.name,
                    subtitle: 'Remove from this session',
                    accent: const Color(0xFFFF5D98),
                    onTap: () {
                      provider.removePlayer(player.id);
                      Navigator.pop(sheetContext);
                      _showGameSnack(context, '${player.name} removed.');
                    },
                  );
                }),
              ],
            ),
          );
        },
      );
    },
  );
}

void _showGameSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class _GameControlsSurface extends StatelessWidget {
  const _GameControlsSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF231034), Color(0xFF100419)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withValues(alpha: 0.48),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  const _ControlSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.42),
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
    this.accent = const Color(0xFF62D8FF),
    this.prominent = false,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;
  final Color accent;
  final bool prominent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final alpha = enabled ? 1.0 : 0.42;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PressableScale(
        enabled: enabled,
        onTap: onTap,
        child: Opacity(
          opacity: alpha,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: prominent
                  ? accent.withValues(alpha: 0.13)
                  : Colors.white.withValues(alpha: 0.055),
              border: Border.all(
                color: prominent
                    ? accent.withValues(alpha: 0.26)
                    : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.14),
                    border: Border.all(color: accent.withValues(alpha: 0.30)),
                  ),
                  child: Icon(icon, color: accent, size: 20),
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
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.52),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
              ],
            ),
          ),
        ),
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
    required this.onMenuTap,
  });

  final int currentRound;
  final int totalRounds;
  final double progress;
  final bool noEscape;
  final VoidCallback onMenuTap;

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
            _RoundIconButton(icon: Icons.more_horiz_rounded, onTap: onMenuTap),
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
  const _AutoRosterStrip({
    required this.players,
    required this.selectedPlayerId,
    required this.noEscape,
    required this.isSpinning,
  });

  final List<Player> players;
  final String? selectedPlayerId;
  final bool noEscape;
  final bool isSpinning;

  @override
  State<_AutoRosterStrip> createState() => _AutoRosterStripState();
}

class _AutoRosterStripState extends State<_AutoRosterStrip> {
  // 132 card width + 10 trailing gap. Used as a fixed item extent so the strip
  // can loop seamlessly by jumping back exactly one full set of players.
  static const double _itemExtent = 142;

  final _controller = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_controller.hasClients) {
        return;
      }
      final count = widget.players.length;
      if (count == 0) {
        return;
      }
      // Period = width of one full pass of every player. Wrapping by exactly
      // this keeps the motion continuous because the next set is identical.
      final period = count * _itemExtent;
      var next = _controller.offset + 0.6;
      if (next >= period) {
        next -= period;
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
    final count = widget.players.length;

    return SizedBox(
      height: 76,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0, 0.06, 0.94, 1],
          ).createShader(bounds);
        },
        child: count == 0
            ? const SizedBox.shrink()
            : ListView.builder(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemExtent: _itemExtent,
                // Effectively endless: the timer wraps the offset by one set,
                // so the cards keep flowing sideways no matter the count.
                itemCount: count * 1000,
                itemBuilder: (context, index) {
                  final playerIndex = index % count;
                  final player = widget.players[playerIndex];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _MiniPlayerCard(
                      player: player,
                      colors: playerColorsForIndex(playerIndex),
                      active: widget.selectedPlayerId == player.id,
                      noEscape: widget.noEscape,
                      dimmed:
                          widget.isSpinning ||
                          (widget.selectedPlayerId != null &&
                              widget.selectedPlayerId != player.id),
                      onLongPress: () =>
                          _showPlayerControlsSheet(context, player),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _MiniPlayerCard extends StatelessWidget {
  const _MiniPlayerCard({
    required this.player,
    required this.colors,
    required this.active,
    required this.noEscape,
    required this.dimmed,
    required this.onLongPress,
  });

  final Player player;
  final PlayerColorSet colors;
  final bool active;
  final bool noEscape;
  final bool dimmed;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: dimmed ? 0.42 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 132,
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary.withValues(alpha: active ? 0.18 : 0.08),
                const Color(0xFF12051E).withValues(alpha: active ? 0.72 : 0.62),
              ],
            ),
            border: Border.all(
              color: (noEscape ? const Color(0xFFFF5D98) : colors.primary)
                  .withValues(alpha: active ? 0.62 : 0.16),
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color:
                          (noEscape ? const Color(0xFFFF5D98) : colors.primary)
                              .withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                  if (player.revengeAvailable) ...[
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.crisis_alert_rounded,
                      color: Color(0xFFFF3D6E),
                      size: 14,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
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
        ),
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
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
            height: 1,
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
    final provider = context.watch<GameProvider>();
    final label = hasSelection ? provider.l('chooseFate') : provider.l('spin');

    return PressableScale(
      enabled: canSpin,
      onTap: onTap,
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
                  colors: [Color(0xFFA85BFF), Color(0xFFFF3D81)],
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
                    color: const Color(0xFFFF3D81).withValues(alpha: 0.18),
                    blurRadius: 16,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
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
                const Icon(
                  Icons.autorenew_rounded,
                  color: Colors.white,
                  size: 27,
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