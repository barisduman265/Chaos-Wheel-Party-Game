import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central place for AdMob ad unit IDs.
///
/// In debug builds we always serve Google's official **test** banner so you
/// never risk clicking your own live ads (which gets the AdMob account banned).
/// Release builds use the real unit IDs below.
class AdHelper {
  AdHelper._();

  // Google's public test units (safe to click during development).
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';

  // Real AdMob banner unit for Android. Only used in release builds; debug
  // always serves the test banner above.
  static const String _androidBanner =
      'ca-app-pub-5960894143182893/3564104393';

  // Real AdMob banner unit for iOS. Only used in release builds; debug always
  // serves the test banner above.
  static const String _iosBanner =
      'ca-app-pub-5960894143182893/5905364101';

  // Real AdMob interstitial unit for Android. Only used in release builds;
  // debug always serves the test interstitial.
  static const String _androidInterstitial =
      'ca-app-pub-5960894143182893/1457951272';

  // Real AdMob interstitial unit for iOS. Only used in release builds; debug
  // always serves the test interstitial.
  static const String _iosInterstitial =
      'ca-app-pub-5960894143182893/9366096960';

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBanner;
    }
    if (Platform.isIOS) {
      return _iosBanner;
    }
    return _androidBanner;
  }

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
