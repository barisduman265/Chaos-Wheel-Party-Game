import 'package:flutter/material.dart';

class PlayerColorSet {
  const PlayerColorSet({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;
}

const playerColorSets = [
  PlayerColorSet(primary: Color(0xFF42C7FF), secondary: Color(0xFF3377FF)),
  PlayerColorSet(primary: Color(0xFFFF5D98), secondary: Color(0xFFFF7B4D)),
  PlayerColorSet(primary: Color(0xFFFFC44D), secondary: Color(0xFFFF8A34)),
  PlayerColorSet(primary: Color(0xFF5EE184), secondary: Color(0xFF2DBE9F)),
  PlayerColorSet(primary: Color(0xFFA85BFF), secondary: Color(0xFF6D8BFF)),
  PlayerColorSet(primary: Color(0xFFFF4E6A), secondary: Color(0xFFE83DFF)),
  PlayerColorSet(primary: Color(0xFF62E6FF), secondary: Color(0xFF8A55FF)),
  PlayerColorSet(primary: Color(0xFFFFD15C), secondary: Color(0xFFFF5D98)),
];

PlayerColorSet playerColorsForIndex(int index) {
  return playerColorSets[index % playerColorSets.length];
}
