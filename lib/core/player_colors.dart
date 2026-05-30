import 'package:flutter/material.dart';

class PlayerColorSet {
  const PlayerColorSet({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;
}

const playerColorSets = [
  PlayerColorSet(primary: Color(0xFF39BDEB), secondary: Color(0xFF4F6FE6)),
  PlayerColorSet(primary: Color(0xFFE04D8A), secondary: Color(0xFFB73578)),
  PlayerColorSet(primary: Color(0xFF9C69F4), secondary: Color(0xFF6D55D8)),
  PlayerColorSet(primary: Color(0xFF55C7B5), secondary: Color(0xFF3F8FC2)),
  PlayerColorSet(primary: Color(0xFF7D6BFF), secondary: Color(0xFFB157FF)),
  PlayerColorSet(primary: Color(0xFFFF5D98), secondary: Color(0xFFB84472)),
  PlayerColorSet(primary: Color(0xFF45D1E0), secondary: Color(0xFF446FE2)),
  PlayerColorSet(primary: Color(0xFFC26CFF), secondary: Color(0xFF7A4EB8)),
];

PlayerColorSet playerColorsForIndex(int index) {
  return playerColorSets[index % playerColorSets.length];
}
