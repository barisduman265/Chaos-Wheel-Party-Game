class Player {
  const Player({
    required this.id,
    required this.name,
    this.passRights = 0,
    this.targetRights = 0,
    this.truthStreak = 0,
    this.passUsed = 0,
    this.targetUsed = 0,
    this.pickedCount = 0,
    this.truthCount = 0,
    this.dareCount = 0,
    this.targetedCount = 0,
    this.revengeAvailable = false,
    this.revengeTargetPlayerId,
  });

  final String id;
  final String name;
  final int passRights;
  final int targetRights;
  final int truthStreak;
  final int passUsed;
  final int targetUsed;
  final int pickedCount;
  final int truthCount;
  final int dareCount;
  final int targetedCount;
  final bool revengeAvailable;
  final String? revengeTargetPlayerId;

  Player copyWith({
    String? id,
    String? name,
    int? passRights,
    int? targetRights,
    int? truthStreak,
    int? passUsed,
    int? targetUsed,
    int? pickedCount,
    int? truthCount,
    int? dareCount,
    int? targetedCount,
    bool? revengeAvailable,
    String? revengeTargetPlayerId,
    bool clearRevengeTarget = false,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      passRights: passRights ?? this.passRights,
      targetRights: targetRights ?? this.targetRights,
      truthStreak: truthStreak ?? this.truthStreak,
      passUsed: passUsed ?? this.passUsed,
      targetUsed: targetUsed ?? this.targetUsed,
      pickedCount: pickedCount ?? this.pickedCount,
      truthCount: truthCount ?? this.truthCount,
      dareCount: dareCount ?? this.dareCount,
      targetedCount: targetedCount ?? this.targetedCount,
      revengeAvailable: revengeAvailable ?? this.revengeAvailable,
      revengeTargetPlayerId: clearRevengeTarget
          ? null
          : revengeTargetPlayerId ?? this.revengeTargetPlayerId,
    );
  }

  Player resetForGame({required int passRights, required int targetRights}) {
    return Player(
      id: id,
      name: name,
      passRights: passRights,
      targetRights: targetRights,
    );
  }
}
