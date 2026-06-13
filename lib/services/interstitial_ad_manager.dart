import 'package:chaos_wheel/core/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Loads and shows full-screen interstitial ads.
///
/// Interstitials take a few seconds to load, so one is always kept preloaded
/// and the next is requested as soon as the current one is dismissed. [show]
/// is a no-op (it just preloads) when no ad is ready, so it never blocks the
/// game. Premium gating is handled by the caller (GameProvider.showInterstitial).
class InterstitialAdManager {
  InterstitialAdManager._();

  static final InterstitialAdManager instance = InterstitialAdManager._();

  InterstitialAd? _ad;
  bool _loading = false;

  /// Requests an interstitial if one isn't already loaded or loading.
  void preload() {
    if (_ad != null || _loading) {
      return;
    }
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  /// Shows the preloaded interstitial if there is one, then preloads the next.
  /// If none is ready it simply triggers a load for next time.
  void show() {
    final ad = _ad;
    if (ad == null) {
      preload();
      return;
    }
    _ad = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preload();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        preload();
      },
    );
    ad.show();
  }
}
