import 'dart:io';

import 'package:flutter/foundation.dart';

/// Central place for AdMob ad unit IDs.
///
/// In debug builds we always serve Google's official **test** banner so you
/// never risk clicking your own live ads (which gets the AdMob account banned).
/// Release builds use the real unit IDs below.
class AdHelper {
  AdHelper._();

  // Google's public test banner unit (safe to click during development).
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';

  // TODO: Replace these with your real AdMob *banner* ad unit IDs (the ones
  // that look like ca-app-pub-5960894143182893/XXXXXXXXXX) before publishing.
  // Until then they fall back to the test banner so release still shows ads.
  static const String _androidBanner = _testBanner;
  static const String _iosBanner = _testBanner;

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return _testBanner;
    }
    if (Platform.isIOS) {
      return _iosBanner;
    }
    return _androidBanner;
  }
}
