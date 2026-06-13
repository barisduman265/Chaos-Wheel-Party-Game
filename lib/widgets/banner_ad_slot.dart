import 'package:chaos_wheel/core/ad_helper.dart';
import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

/// Where a [BannerAdSlot] sits, so its safe-area inset is applied on the
/// correct edge (below the status bar for a top banner, above the system
/// navigation bar for a bottom banner).
enum BannerPosition { top, bottom }

/// An AdMob banner used either as a Scaffold `bottomNavigationBar` (bottom) or
/// as the first child of the body `Column` (top).
///
/// - Loads nothing and takes no space for premium users.
/// - Stays invisible until the ad actually loads, so there's never an empty
///   grey strip.
/// - Disposes the ad when the screen is torn down.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key, this.position = BannerPosition.bottom});

  final BannerPosition position;

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Premium users never see ads, so don't even request one. The adaptive
    // size needs the screen width from MediaQuery, so defer to the first frame.
    if (!context.read<GameProvider>().isPremiumUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadAd();
        }
      });
    }
  }

  Future<void> _loadAd() async {
    // Use a full-width anchored adaptive banner so it spans the screen instead
    // of leaving black bars beside a fixed 320px banner.
    final width = MediaQuery.of(context).size.width.truncate();
    final adaptiveSize =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width) ??
        AdSize.banner;
    if (!mounted) {
      return;
    }
    final banner = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: adaptiveSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _loaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _ad = banner;
    banner.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<GameProvider>().isPremiumUser;
    final ad = _ad;
    if (isPremium || !_loaded || ad == null) {
      return const SizedBox.shrink();
    }
    final isTop = widget.position == BannerPosition.top;
    return SafeArea(
      top: isTop,
      bottom: !isTop,
      child: SizedBox(
        width: double.infinity,
        height: ad.size.height.toDouble(),
        child: Center(
          child: SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ),
      ),
    );
  }
}
