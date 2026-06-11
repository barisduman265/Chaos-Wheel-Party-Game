import 'dart:math';

import 'package:chaos_wheel/models/prompt_models.dart';
import 'package:chaos_wheel/services/prompt_repository.dart';

class PromptEngine {
  PromptEngine({PromptRepository? repository, Random? random})
    : _repository = repository ?? PromptRepository(),
      _random = random ?? Random();

  final PromptRepository _repository;
  final Random _random;

  ContentPrompt generate({
    required PromptType type,
    required PromptVibeMode mode,
    required int currentRound,
    required int totalRounds,
    required int playerCount,
    required bool noEscape,
    required bool premiumUnlocked,
    required bool drinkingPromptsEnabled,
    required bool extremePromptsEnabled,
    required Set<String> usedPromptIds,
  }) {
    var effectiveMode = mode;
    if (!extremePromptsEnabled && effectiveMode == PromptVibeMode.evil) {
      effectiveMode = PromptVibeMode.unhinged;
    }

    var pool = _repository.find(
      type: type,
      mode: effectiveMode,
      playerCount: playerCount,
      premiumUnlocked: premiumUnlocked,
    );

    if (pool.isEmpty && effectiveMode == PromptVibeMode.evil) {
      pool = _repository.find(
        type: type,
        mode: PromptVibeMode.unhinged,
        playerCount: playerCount,
        premiumUnlocked: premiumUnlocked,
      );
    }

    if (pool.isEmpty) {
      return ContentPrompt(
        id: 'fallback_${type.name}',
        type: type,
        mode: effectiveMode,
        level: noEscape ? 3 : 1,
        text: type == PromptType.truth
            ? 'Tell the group something you have been avoiding.'
            : 'Do the most dramatic safe dare the group can agree on.',
        tags: const ['fallback'],
        minPlayers: 2,
        isPremium: false,
        intensityLabel: noEscape ? 'HIGH TENSION' : 'RISKY',
      );
    }

    final targetLevel = _targetLevel(mode: mode, noEscape: noEscape);
    final minimumLevel = _minimumLevel(mode: mode, noEscape: noEscape);

    var candidates = pool
        .where((prompt) => prompt.level >= minimumLevel)
        .where((prompt) {
          if (!extremePromptsEnabled && _isExtremePrompt(prompt)) {
            return false;
          }
          if (!drinkingPromptsEnabled && _isDrinkingPrompt(prompt)) {
            return false;
          }
          return true;
        })
        .toList(growable: false);

    if (candidates.isEmpty) {
      candidates = pool
          .where((prompt) {
            if (!extremePromptsEnabled && _isExtremePrompt(prompt)) {
              return false;
            }
            if (!drinkingPromptsEnabled && _isDrinkingPrompt(prompt)) {
              return false;
            }
            return true;
          })
          .toList(growable: false);
    }

    if (candidates.isEmpty) {
      return ContentPrompt(
        id: 'filtered_fallback_${type.name}_${DateTime.now().microsecondsSinceEpoch}',
        type: type,
        mode: effectiveMode,
        level: noEscape ? 3 : 2,
        text: type == PromptType.truth
            ? 'Reveal something the room would not expect from you.'
            : 'Let the group choose one safe dare you must do now.',
        tags: const ['filtered', 'safe'],
        minPlayers: 2,
        isPremium: false,
        intensityLabel: noEscape ? 'HIGH TENSION' : 'RISKY',
      );
    }

    final effectiveCandidates = candidates
        .where(_isSociallyEffectivePrompt)
        .toList(growable: false);
    if (effectiveCandidates.isNotEmpty) {
      candidates = effectiveCandidates;
    }

    final unseen = candidates
        .where((prompt) => !usedPromptIds.contains(prompt.id))
        .toList(growable: false);
    final finalPool = unseen.isNotEmpty ? unseen : candidates;
    final weighted = _weightedByIntensity(finalPool, targetLevel, noEscape);

    return weighted[_random.nextInt(weighted.length)];
  }

  bool _isSociallyEffectivePrompt(ContentPrompt prompt) {
    final text = prompt.text.toLowerCase();
    const weakPhrases = [
      'fake breakup song',
      'theme song',
      'movie title',
      'dating slogan',
      'fake horoscope',
      'weather report',
      'commercial',
      'cereal box',
      'shoe like',
      'phone case',
      'cooking show',
      'slogan',
      'caption idea',
      'emoji that represents',
      'hand gesture',
      'silent commercial',
      'relationship theme song',
      'rom-com',
      'fake celebrity crush',
      'villain catchphrase',
      'tabloid headline',
      'as a joke',
      'fake breakup',
      'quirky',
      'random animal',
      'imaginary product',
      'superhero name',
    ];

    return !weakPhrases.any(text.contains);
  }

  bool _isExtremePrompt(ContentPrompt prompt) {
    return prompt.requiresExtremeAllowed ||
        prompt.mode == PromptVibeMode.evil ||
        prompt.isPremium ||
        prompt.tags.contains('cursed');
  }

  bool _isDrinkingPrompt(ContentPrompt prompt) {
    final text = prompt.text.toLowerCase();
    return prompt.requiresDrinkingAllowed ||
        text.contains('shot') ||
        text.contains('drink') ||
        text.contains('drinking') ||
        text.contains('alcohol');
  }

  int _targetLevel({required PromptVibeMode mode, required bool noEscape}) {
    if (noEscape) {
      return 3;
    }
    return switch (mode) {
      PromptVibeMode.cozy => 2,
      PromptVibeMode.spicy => 3,
      PromptVibeMode.unhinged => 3,
      PromptVibeMode.evil => 3,
    };
  }

  int _minimumLevel({required PromptVibeMode mode, required bool noEscape}) {
    if (noEscape) {
      return 3;
    }
    return switch (mode) {
      PromptVibeMode.cozy => 2,
      PromptVibeMode.spicy => 2,
      PromptVibeMode.unhinged => 2,
      PromptVibeMode.evil => 3,
    };
  }

  List<ContentPrompt> _weightedByIntensity(
    List<ContentPrompt> prompts,
    int targetLevel,
    bool noEscape,
  ) {
    final weighted = <ContentPrompt>[];
    for (final prompt in prompts) {
      final levelDistance = (prompt.level - targetLevel).abs();
      final weight = noEscape
          ? (prompt.level >= 3 ? 6 : 1)
          : prompt.level >= targetLevel
          ? 4
          : max(1, 3 - levelDistance);
      for (var index = 0; index < weight; index++) {
        weighted.add(prompt);
      }
    }
    return weighted;
  }
}
