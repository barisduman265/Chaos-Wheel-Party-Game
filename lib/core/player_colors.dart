import 'package:flutter/material.dart';

class PlayerColorSet {
  const PlayerColorSet({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;
}

const playerColorSets = [
  PlayerColorSet(primary: Color(0xFF3EA7D5), secondary: Color(0xFF2462B8)),
  PlayerColorSet(primary: Color(0xFFD94B86), secondary: Color(0xFFB83263)),
  PlayerColorSet(primary: Color(0xFFD6A83D), secondary: Color(0xFFB67B2C)),
  PlayerColorSet(primary: Color(0xFF58B56B), secondary: Color(0xFF2E8E79)),
  PlayerColorSet(primary: Color(0xFF855CE0), secondary: Color(0xFF5A6DCE)),
  PlayerColorSet(primary: Color(0xFFD86651), secondary: Color(0xFFB8445A)),
  PlayerColorSet(primary: Color(0xFF41BFC5), secondary: Color(0xFF3F70C8)),
  PlayerColorSet(primary: Color(0xFFB86DD6), secondary: Color(0xFF7A4EB8)),
];

PlayerColorSet playerColorsForIndex(int index) {
  return playerColorSets[index % playerColorSets.length];
}
