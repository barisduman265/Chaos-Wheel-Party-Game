import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central place for AdMob ad unit IDs.
///
/// In debug builds we always serve Google's official **test** interstitial so
/// you never risk clicking your own live ads (which gets the AdMob account
/// banned). Release builds use the real unit IDs below.
class AdHelper {
  AdHelper._();

  // Google's public test unit (safe to click during development).
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  // Real AdMob interstitial unit for Android. Only used in release builds;
  // debug always serves the test interstitial.
  static const String _androidInterstitial =
      'ca-app-pub-5960894143182893/1457951272';

  // Real AdMob interstitial unit for iOS. Only used in release builds; debug
  // always serves the test interstitial.
  static const String _iosInterstitial =
      'ca-app-pub-5960894143182893/9366096960';

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return _testInterstitial;
    }
    if (Platform.isIOS) {
      return _iosInterstitial;
    }
    return _androidInterstitial;
  }
}
