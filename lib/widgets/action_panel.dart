import 'package:chaos_wheel_party_game/models/player.dart';
import 'package:chaos_wheel_party_game/widgets/neon_card.dart';
import 'package:chaos_wheel_party_game/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ActionPanel extends StatelessWidget {
  const ActionPanel({
    super.key,
    required this.player,
    required this.randomEnabled,
    required this.truthLocked,
    required this.passAvailable,
    required this.targetAvailable,
    required this.passMessage,
    required this.targetMessage,
    required this.onTruth,
    required this.onDare,
    required this.onRandom,
    required this.onPass,
    required this.onTarget,
  });

  final Player player;
  final bool randomEnabled;
  final bool truthLocked;
  final bool passAvailable;
  final bool targetAvailable;
  final String? passMessage;
  final String? targetMessage;
  final VoidCallback onTruth;
  final VoidCallback onDare;
  final VoidCallback onRandom;
  final VoidCallback onPass;
  final VoidCallback onTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return NeonCard(
      padding: const EdgeInsets.all(18),
      borderColor: theme.colorScheme.primary,
      glowColor: theme.colorScheme.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${player.name}, choose your fate.',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          if (truthLocked)
            Text(
              'Truth locked. Dare is mandatory 😈',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            Text(
              'The group decides the actual challenge. The app records the chaos.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 150,
                child: PrimaryButton(
                  label: 'Truth',
                  icon: Icons.question_answer_rounded,
                  enabled: !truthLocked,
                  onPressed: onTruth,
                ),
              ),
              SizedBox(
                width: 150,
                child: PrimaryButton(
                  label: 'Dare',
                  icon: Icons.bolt_rounded,
                  onPressed: onDare,
                ),
              ),
              if (randomEnabled)
                SizedBox(
                  width: 150,
                  child: PrimaryButton(
                    label: 'Random',
                    icon: Icons.casino_rounded,
                    isSecondary: true,
                    onPressed: onRandom,
                  ),
                ),
              SizedBox(
                width: 150,
                child: PrimaryButton(
                  label: 'Pass',
                  icon: Icons.fast_forward_rounded,
                  enabled: passAvailable,
                  isSecondary: true,
                  onPressed: onPass,
                ),
              ),
              SizedBox(
                width: 150,
                child: PrimaryButton(
                  label: 'Target',
                  icon: Icons.gps_fixed_rounded,
                  enabled: targetAvailable,
                  isSecondary: true,
                  onPressed: onTarget,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            passAvailable
                ? 'Pass used keeps the truth streak alive.'
                : (passMessage ?? 'No passes left.'),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            targetAvailable
                ? 'Target can redirect the round without ending it.'
                : (targetMessage ?? 'No targets left.'),
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
