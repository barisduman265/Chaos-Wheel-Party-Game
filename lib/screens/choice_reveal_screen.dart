import 'dart:async';
import 'dart:ui';

import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/models/prompt_models.dart';
import 'package:chaos_wheel_party_game/providers/game_provider.dart';
import 'package:chaos_wheel_party_game/screens/action_feedback_screen.dart';
import 'package:chaos_wheel_party_game/screens/game_summary_screen.dart';
import 'package:chaos_wheel_party_game/screens/target_selection_screen.dart';
import 'package:chaos_wheel_party_game/services/chaos_audio_service.dart';
import 'package:chaos_wheel_party_game/widgets/chaos_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum ChoiceRevealType { truth, dare }

class ChoiceRevealScreen extends StatefulWidget {
  const ChoiceRevealScreen({
    super.key,
    required this.player,
    required this.choice,
    this.isTargeted = false,
  });

  final Player player;
  final ChoiceRevealType choice;
  final bool isTargeted;

  static Future<void> show(
    BuildContext context, {
    required Player player,
    required ChoiceRevealType choice,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, _) {
          return FadeTransition(
            opacity: animation,
            child: ChoiceRevealScreen(player: player, choice: choice),
          );
        },
      ),
    );
  }

  @override
  State<ChoiceRevealScreen> createState() => _ChoiceRevealScreenState();
}

class _ChoiceRevealScreenState extends State<ChoiceRevealScreen> {
  ContentPrompt? _visiblePrompt;
  Timer? _revealTimer;
  int _promptVersion = 0;
  bool _isRevealing = true;
  late int _rerollsLeft;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GameProvider>();
    _rerollsLeft = widget.isTargeted
        ? 0
        : provider.isNoEscapeActive && provider.isEvilModeActive
        ? 0
        : provider.isPremiumUser
        ? 2
        : 1;
    _startPromptReveal(provider.currentPrompt);
    if (provider.currentPrompt?.mode == PromptVibeMode.evil) {
      provider.playSfx(ChaosSfx.evilReveal);
    }
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  bool get _isTruth => widget.choice == ChoiceRevealType.truth;

  String _label(GameProvider provider) =>
      _isTruth ? provider.l('truth') : provider.l('dare');

  List<Color> get _heroColors => _isTruth
      ? _isEvilPrompt
            ? const [Color(0xFF2B0712), Color(0xFFFF2D6F)]
            : const [Color(0xFF6D8BFF), Color(0xFFB157FF)]
      : _isEvilPrompt
      ? const [Color(0xFF3A0717), Color(0xFFFF184F)]
      : const [Color(0xFFFF7B4D), Color(0xFFFF3D81)];

  Color get _accent => _isEvilPrompt
      ? const Color(0xFFFF3D6E)
      : _isTruth
      ? const Color(0xFF7AB8FF)
      : const Color(0xFFFF5D98);

  bool get _isEvilPrompt => _visiblePrompt?.mode == PromptVibeMode.evil;

  void _startPromptReveal(ContentPrompt? prompt) {
    _revealTimer?.cancel();
    _isRevealing = true;
    _visiblePrompt ??= prompt;
    if (context.read<GameProvider>().reduceAnimationsEnabled) {
      _visiblePrompt = prompt;
      _isRevealing = false;
      _promptVersion++;
      return;
    }

    _revealTimer = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _visiblePrompt = prompt;
        _isRevealing = false;
        _promptVersion++;
      });
    });
  }

  void _changePrompt() {
    if (_rerollsLeft <= 0 || widget.isTargeted) {
      return;
    }
    final provider = context.read<GameProvider>();
    final nextPrompt = provider.generatePrompt(
      _isTruth ? PromptType.truth : PromptType.dare,
    );
    setState(() {
      _rerollsLeft--;
      _startPromptReveal(nextPrompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final activePlayer = provider.selectedPlayer ?? widget.player;
    final noEscape = provider.isNoEscapeActive;
    final canPass = !noEscape && activePlayer.passRights > 0;
    final targetMessage = provider.canUseTarget();
    final canTarget = !noEscape && targetMessage == null;
    final header = widget.isTargeted
        ? provider.l('youGotTargeted')
        : _isTruth
        ? provider.l('truthSelected')
        : provider.l('dareSelected');
    final buttonLabel = _isTruth ? provider.l('tellIt') : provider.l('sendIt');

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            const ChaosBackground(child: SizedBox.expand()),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.25),
                    radius: 0.9,
                    colors: [
                      _heroColors.last.withValues(alpha: 0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      provider.l('step1of2').replaceFirst('1', '2'),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _accent,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      header,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: widget.isTargeted ? Colors.white : _accent,
                        fontWeight: FontWeight.w900,
                        height: 0.96,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.isTargeted
                          ? provider.l(
                              _isTruth ? 'handleThisTruth' : 'handleThisDare',
                            )
                          : provider.lf(
                              _isTruth ? 'willYouTellIt' : 'willYouDoIt',
                              {'player': activePlayer.name},
                            ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 26),
                    _PromptRevealCard(
                      key: ValueKey('prompt_$_promptVersion'),
                      prompt: _visiblePrompt,
                      label: _label(provider),
                      isTruth: _isTruth,
                      accent: _accent,
                      heroColors: _heroColors,
                      isRevealing: _isRevealing,
                      rerollsLeft: _rerollsLeft,
                      changeLabel: provider.l(
                        _isTruth ? 'changeQuestion' : 'changeDare',
                      ),
                      leftLabel: provider.l('left'),
                      onChangePrompt: _changePrompt,
                    ),
                    const Spacer(),
                    _MainActionButton(
                      label: buttonLabel,
                      onTap: () => _completeChoice(context, activePlayer),
                    ),
                    if (!widget.isTargeted && !noEscape) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStatusCard(
                              icon: Icons.local_bar_outlined,
                              title: provider.l('shot'),
                              value: '${activePlayer.passRights}',
                              subtitle: canPass
                                  ? '${activePlayer.passRights} ${provider.l('left')}'
                                  : provider.l('noShotsLeft'),
                              accent: const Color(0xFF71D2FF),
                              enabled: canPass,
                              onTap: () => _usePass(context, activePlayer),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _MiniStatusCard(
                              icon: Icons.gps_fixed_rounded,
                              title: provider.l('target'),
                              value: '${activePlayer.targetRights}',
                              subtitle: canTarget
                                  ? '${activePlayer.targetRights} ${provider.l('left')}'
                                  : targetMessage ?? 'Unavailable',
                              accent: const Color(0xFFFF5D98),
                              enabled: canTarget,
                              onTap: () => _useTarget(context, activePlayer),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeChoice(
    BuildContext context,
    Player activePlayer,
  ) async {
    final provider = context.read<GameProvider>();
    final wasNoEscapeActive = provider.isNoEscapeActive;
    final revengeTarget = provider.revengeTargetForSelectedPlayer();
    final message = provider.completeSelectedChallenge(
      type: _isTruth ? PromptType.truth : PromptType.dare,
    );
    if (message.isEmpty || !context.mounted) {
      return;
    }

    if (revengeTarget != null && context.mounted) {
      await provider.playSfx(ChaosSfx.revengeAvailable);
      final activate = await _showRevengeChoice(context, revengeTarget);
      if (!context.mounted) {
        return;
      }
      if (activate) {
        final revengeMessage = provider.activateRevenge();
        await provider.playSfx(ChaosSfx.revengeActivated);
        await ActionFeedbackScreen.show(
          context,
          type: ActionFeedbackType.revenge,
          title: provider.l('revengeActivated'),
          highlight: revengeTarget.name,
          subtitle: revengeMessage,
        );
        if (!context.mounted) {
          return;
        }
        await Navigator.of(context).pushReplacement(
          PageRouteBuilder<void>(
            opaque: true,
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (_, animation, _) {
              return FadeTransition(
                opacity: animation,
                child: ChoiceRevealScreen(
                  player: revengeTarget,
                  choice: widget.choice,
                  isTargeted: true,
                ),
              );
            },
          ),
        );
        return;
      }
    }

    provider.finishCompletedChallenge();

    final label = _label(provider);
    final actionSummary = provider.lf('playerChose', {
      'player': activePlayer.name,
      'choice': label,
    });
    final shortActionSummary = provider.lf('choseLabel', {'choice': label});
    final nextTurnMessage = message == actionSummary
        ? shortActionSummary
        : '$shortActionSummary $message';

    final nextRound = provider.state.currentRound;
    final totalRounds = provider.state.totalRounds;
    final enteredNoEscape = await _showNoEscapeIntroIfNeeded(
      context,
      provider,
      wasNoEscapeActive: wasNoEscapeActive,
    );
    if (!context.mounted) {
      return;
    }
    if (enteredNoEscape) {
      Navigator.of(context).pop();
      return;
    }

    await ActionFeedbackScreen.show(
      context,
      type: ActionFeedbackType.nextTurn,
      title: nextRound > totalRounds
          ? provider.l('gameComplete')
          : provider.l('nextTurn'),
      highlight: activePlayer.name,
      subtitle: nextTurnMessage,
      nextRound: nextRound,
      totalRounds: totalRounds,
    );
    if (!context.mounted) {
      return;
    }

    if (nextRound > totalRounds) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        GameSummaryScreen.routeName,
        (route) => false,
      );
      return;
    }

    Navigator.of(context).pop();
  }

  Future<void> _usePass(BuildContext context, Player activePlayer) async {
    final provider = context.read<GameProvider>();
    final wasNoEscapeActive = provider.isNoEscapeActive;
    final message = provider.usePass();
    if (message.isEmpty || !context.mounted) {
      return;
    }
    await provider.playSfx(ChaosSfx.shotTaken);

    await ActionFeedbackScreen.show(
      context,
      type: ActionFeedbackType.shot,
      title: provider.l('shotTaken'),
      subtitle: provider.lf('spendsOneShotToken', {
        'player': activePlayer.name,
      }),
    );
    if (!context.mounted) {
      return;
    }

    final enteredNoEscape = await _showNoEscapeIntroIfNeeded(
      context,
      provider,
      wasNoEscapeActive: wasNoEscapeActive,
    );
    if (!context.mounted) {
      return;
    }
    if (enteredNoEscape) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
  }

  Future<bool> _showNoEscapeIntroIfNeeded(
    BuildContext context,
    GameProvider provider, {
    required bool wasNoEscapeActive,
  }) async {
    final enteredNoEscape = !wasNoEscapeActive && provider.isNoEscapeActive;
    if (!enteredNoEscape || !context.mounted) {
      return false;
    }

    await provider.playSfx(ChaosSfx.noEscape);
    await ActionFeedbackScreen.show(
      context,
      type: ActionFeedbackType.noEscape,
      title: provider.l('noEscape'),
      subtitle: provider.l('noEscapeBody'),
      nextRound: provider.state.currentRound,
      totalRounds: provider.state.totalRounds,
    );
    return true;
  }

  Future<void> _useTarget(BuildContext context, Player actingPlayer) async {
    final provider = context.read<GameProvider>();
    final blockMessage = provider.canUseTarget();
    if (blockMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF23142D),
          behavior: SnackBarBehavior.floating,
          content: Text(blockMessage),
        ),
      );
      return;
    }

    final result = await Navigator.pushNamed(
      context,
      TargetSelectionScreen.routeName,
    );
    if (result is String && context.mounted) {
      await provider.playSfx(ChaosSfx.targetedReveal);
      final selected = context.read<GameProvider>().selectedPlayer;
      if (selected != null) {
        await ActionFeedbackScreen.show(
          context,
          type: ActionFeedbackType.target,
          title: provider.l('targeted'),
          highlight: selected.name,
          subtitle: provider.lf('gotTargetedBy', {
            'target': selected.name,
            'source': actingPlayer.name,
          }),
        );
        if (!context.mounted) {
          return;
        }
        if (context.mounted) {
          await Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              opaque: true,
              transitionDuration: const Duration(milliseconds: 260),
              reverseTransitionDuration: const Duration(milliseconds: 220),
              pageBuilder: (_, animation, _) {
                return FadeTransition(
                  opacity: animation,
                  child: ChoiceRevealScreen(
                    player: selected,
                    choice: widget.choice,
                    isTargeted: true,
                  ),
                );
              },
            ),
          );
        }
      }
    }
  }

  Future<bool> _showRevengeChoice(
    BuildContext context,
    Player revengeTarget,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A0715), Color(0xFF12051E)],
            ),
            border: Border.all(
              color: const Color(0xFFFF3D6E).withValues(alpha: 0.42),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF184F).withValues(alpha: 0.22),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.crisis_alert_rounded,
                color: Color(0xFFFF3D6E),
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                'REVENGE AVAILABLE',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take the chaos back to ${revengeTarget.name}?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _RevengeButton(
                      label: 'LET IT GO',
                      color: const Color(0xFF7A6A93),
                      onTap: () => Navigator.pop(sheetContext, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _RevengeButton(
                      label: 'REVENGE TARGET',
                      color: const Color(0xFFFF3D6E),
                      onTap: () => Navigator.pop(sheetContext, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }
}

class _RevengeButton extends StatelessWidget {
  const _RevengeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.16),
          border: Border.all(color: color.withValues(alpha: 0.46)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _PromptRevealCard extends StatelessWidget {
  const _PromptRevealCard({
    super.key,
    required this.prompt,
    required this.label,
    required this.isTruth,
    required this.accent,
    required this.heroColors,
    required this.isRevealing,
    required this.rerollsLeft,
    required this.changeLabel,
    required this.leftLabel,
    required this.onChangePrompt,
  });

  final ContentPrompt? prompt;
  final String label;
  final bool isTruth;
  final Color accent;
  final List<Color> heroColors;
  final bool isRevealing;
  final int rerollsLeft;
  final String changeLabel;
  final String leftLabel;
  final VoidCallback onChangePrompt;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final contentName = isTruth ? provider.l('question') : provider.l('dare');
    final modeLabel = prompt == null
        ? label
        : switch (prompt!.mode) {
            PromptVibeMode.cozy => provider.l('cozy'),
            PromptVibeMode.spicy => provider.l('spicy'),
            PromptVibeMode.unhinged => provider.l('unhinged'),
            PromptVibeMode.evil => provider.l('evil'),
          };
    final promptLabel = prompt == null
        ? '$label $contentName'.toUpperCase()
        : '$modeLabel $contentName'.toUpperCase();
    final intensity = prompt == null ? 'HIGH TENSION' : prompt!.intensityLabel;
    final promptText = prompt != null
        ? provider.localizedPromptText(prompt!)
        : (isTruth ? provider.l('tellTheTruth') : provider.l('takeTheRisk'));
    final footer = prompt?.level == 3
        ? provider.l('chaosDemandsSacrifice')
        : provider.l('theRoomIsWatching');
    final typeIcon = isTruth
        ? Icons.question_answer_rounded
        : Icons.bolt_rounded;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0.92, end: 1),
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 238),
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              heroColors.first.withValues(alpha: isRevealing ? 0.25 : 0.20),
              const Color(0xFF1B0C2A).withValues(alpha: 0.72),
              heroColors.last.withValues(alpha: isRevealing ? 0.18 : 0.14),
            ],
          ),
          border: Border.all(color: accent.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.13),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.38),
                        accent.withValues(alpha: 0.14),
                      ],
                    ),
                    border: Border.all(color: accent.withValues(alpha: 0.42)),
                  ),
                  child: Icon(typeIcon, color: accent, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        promptLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.78),
                          letterSpacing: 1.8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intensity,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: accent,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                boxShadow: isRevealing
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.14),
                          blurRadius: 18,
                        ),
                      ]
                    : null,
              ),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: isRevealing ? 1.8 : 0,
                  sigmaY: isRevealing ? 1.8 : 0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    promptText,
                    key: ValueKey(prompt?.id ?? promptText),
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    footer,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _ChangePromptButton(
                  accent: accent,
                  isTruth: isTruth,
                  enabled: !isRevealing && rerollsLeft > 0,
                  rerollsLeft: rerollsLeft,
                  changeLabel: changeLabel,
                  leftLabel: leftLabel,
                  onTap: onChangePrompt,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePromptButton extends StatelessWidget {
  const _ChangePromptButton({
    required this.accent,
    required this.isTruth,
    required this.enabled,
    required this.rerollsLeft,
    required this.changeLabel,
    required this.leftLabel,
    required this.onTap,
  });

  final Color accent;
  final bool isTruth;
  final bool enabled;
  final int rerollsLeft;
  final String changeLabel;
  final String leftLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: accent.withValues(alpha: enabled ? 0.12 : 0.05),
          border: Border.all(
            color: accent.withValues(alpha: enabled ? 0.34 : 0.12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? accent : Colors.white.withValues(alpha: 0.24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              enabled
                  ? '$changeLabel • $rerollsLeft $leftLabel'
                  : context.watch<GameProvider>().l('noChangesLeft'),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: enabled ? accent : Colors.white.withValues(alpha: 0.30),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              color: const Color(0xFFFF3D81).withValues(alpha: 0.22),
              blurRadius: 18,
            ),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _MiniStatusCard extends StatelessWidget {
  const _MiniStatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color accent;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final foreground = enabled
        ? Colors.white
        : Colors.white.withValues(alpha: 0.44);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: enabled ? 0.05 : 0.03),
          border: Border.all(
            color: accent.withValues(alpha: enabled ? 0.35 : 0.14),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: enabled ? 0.35 : 0.12),
                    accent.withValues(alpha: enabled ? 0.14 : 0.05),
                  ],
                ),
              ),
              child: Icon(icon, color: enabled ? accent : foreground, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: foreground.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
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
