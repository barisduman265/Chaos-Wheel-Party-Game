import 'package:flutter/material.dart';

/// Central icon choice for the shot / pass action. When Drinking Mode is on we
/// show the cocktail glass; when it's off (default) we show a neutral
/// "skip/pass" icon so the app carries no drinking imagery.
IconData shotIcon(bool drinkingMode) =>
    drinkingMode ? Icons.local_bar_outlined : Icons.fast_forward_rounded;

/// Filled variant of [shotIcon] for prominent / rounded contexts.
IconData shotIconFilled(bool drinkingMode) =>
    drinkingMode ? Icons.local_bar_rounded : Icons.fast_forward_rounded;
