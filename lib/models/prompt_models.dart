enum PromptType {
  truth,
  dare,
  wildcard,
  team,
  sabotage,
  hotseat,
  vote,
  secret,
  duo,
}

enum PromptVibeMode { cozy, spicy, unhinged, evil }

extension PromptTypeLabel on PromptType {
  String get label {
    return switch (this) {
      PromptType.truth => 'Truth',
      PromptType.dare => 'Dare',
      PromptType.wildcard => 'Wildcard',
      PromptType.team => 'Team',
      PromptType.sabotage => 'Sabotage',
      PromptType.hotseat => 'Hotseat',
      PromptType.vote => 'Vote',
      PromptType.secret => 'Secret',
      PromptType.duo => 'Duo',
    };
  }
}

extension PromptVibeModeLabel on PromptVibeMode {
  String get label {
    return switch (this) {
      PromptVibeMode.cozy => 'Cozy',
      PromptVibeMode.spicy => 'Spicy',
      PromptVibeMode.unhinged => 'Unhinged',
      PromptVibeMode.evil => 'Evil',
    };
  }
}

class ContentPrompt {
  const ContentPrompt({
    required this.id,
    required this.type,
    required this.mode,
    required this.level,
    required this.text,
    required this.tags,
    required this.minPlayers,
    required this.isPremium,
    String? intensityLabel,
    this.requiresDrinkingAllowed = false,
    this.requiresExtremeAllowed = false,
  }) : _intensityLabel = intensityLabel;

  final String id;
  final PromptType type;
  final PromptVibeMode mode;
  final int level;
  final String text;
  final List<String> tags;
  final int minPlayers;
  final bool isPremium;
  final bool requiresDrinkingAllowed;
  final bool requiresExtremeAllowed;
  final String? _intensityLabel;

  String get intensityLabel {
    final intensityLabel = _intensityLabel;
    if (intensityLabel != null) {
      return intensityLabel;
    }
    return switch (level) {
      1 => 'SAFE',
      2 => 'RISKY',
      3 => 'HIGH TENSION',
      _ => 'CHAOTIC',
    };
  }
}
