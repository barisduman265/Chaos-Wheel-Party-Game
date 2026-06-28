import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

enum PremiumPurchaseStartResult {
  started,
  storeUnavailable,
  productUnavailable,
  failedToStart,
}

/// Wraps StoreKit / Play billing for the two premium products: a lifetime
/// non-consumable and a weekly auto-renewable subscription. Both unlock the
/// same unified premium entitlement. Works against the StoreKit sandbox
/// (and TestFlight) automatically when signed into a sandbox account.
class PremiumPurchaseService {
  PremiumPurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchaseOverride = inAppPurchase;

  // App Store Connect / Play Console product ids.
  static const lifetimeProductId = 'com.skyroonlabs.chaoswheel.lifetimepremium';
  static const weeklyProductId = 'com.skyroonlabs.chaoswheel.weeklypremium';
  static const Set<String> _productIds = {lifetimeProductId, weeklyProductId};

  final InAppPurchase? _inAppPurchaseOverride;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  InAppPurchase? get _inAppPurchase {
    if (_inAppPurchaseOverride != null) {
      return _inAppPurchaseOverride;
    }

    try {
      return InAppPurchase.instance;
    } catch (_) {
      // The plugin has no registered platform implementation on web/desktop
      // debug targets. Treat the store as unavailable instead of crashing app
      // startup with a LateInitializationError.
      return null;
    }
  }

  void start({
    required Future<void> Function() onEntitlementGranted,
    required void Function(String message) onError,
    required void Function() onCanceled,
  }) {
    final store = _inAppPurchase;
    if (store == null) {
      return;
    }

    try {
      _purchaseSubscription ??= store.purchaseStream.listen((purchases) async {
        for (final purchase in purchases) {
          if (!_productIds.contains(purchase.productID)) {
            continue;
          }

          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            await onEntitlementGranted();
          } else if (purchase.status == PurchaseStatus.error) {
            onError(purchase.error?.message ?? 'Purchase failed.');
          } else if (purchase.status == PurchaseStatus.canceled) {
            onCanceled();
          }

          if (purchase.pendingCompletePurchase) {
            await store.completePurchase(purchase);
          }
        }
      }, onError: (_) => onError('Purchase stream failed.'));
    } catch (_) {
      // Unsupported targets, such as Flutter web debug, do not register an
      // in-app purchase platform. Keep the app alive and let purchase attempts
      // report the store as unavailable.
    }
  }

  Future<ProductDetailsResponse?> _queryProductDetails() async {
    final store = _inAppPurchase;
    if (store == null) {
      return null;
    }
    try {
      return await store.queryProductDetails(_productIds);
    } catch (_) {
      return null;
    }
  }

  /// Returns the [ProductDetails] for the available plans (may be empty when
  /// the store is unavailable or the products aren't configured yet).
  Future<List<ProductDetails>> queryProducts() async {
    final store = _inAppPurchase;
    if (store == null) {
      return const [];
    }
    if (!await _isStoreAvailable(store)) {
      return const [];
    }
    final response = await _queryProductDetails();
    if (response == null || response.error != null) {
      return const [];
    }
    return response.productDetails;
  }

  Future<PremiumPurchaseStartResult> buyLifetime() => _buy(lifetimeProductId);

  Future<PremiumPurchaseStartResult> buyWeekly() => _buy(weeklyProductId);

  Future<PremiumPurchaseStartResult> _buy(String productId) async {
    final store = _inAppPurchase;
    if (store == null) {
      return PremiumPurchaseStartResult.storeUnavailable;
    }
    if (!await _isStoreAvailable(store)) {
      return PremiumPurchaseStartResult.storeUnavailable;
    }

    final response = await _queryProductDetails();
    if (response == null || response.error != null) {
      return PremiumPurchaseStartResult.failedToStart;
    }

    ProductDetails? product;
    for (final details in response.productDetails) {
      if (details.id == productId) {
        product = details;
        break;
      }
    }
    if (product == null) {
      return PremiumPurchaseStartResult.productUnavailable;
    }

    final purchaseParam = PurchaseParam(productDetails: product);
    final started = await _startPurchase(store, purchaseParam);
    return started
        ? PremiumPurchaseStartResult.started
        : PremiumPurchaseStartResult.failedToStart;
  }

  /// Replays the user's past purchases through [start]'s stream as `restored`,
  /// re-granting the entitlement. Used by the "Restore Purchases" button.
  Future<void> restorePurchases() async {
    final store = _inAppPurchase;
    if (store == null) {
      return;
    }
    if (await _isStoreAvailable(store)) {
      try {
        await store.restorePurchases();
      } catch (_) {
        // Restore should never crash the app on unsupported targets.
      }
    }
  }

  /// Restore attempted quietly at start-up (no UI feedback).
  Future<void> restoreSilently() => restorePurchases();

  Future<bool> _isStoreAvailable(InAppPurchase store) async {
    try {
      return await store.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _startPurchase(
    InAppPurchase store,
    PurchaseParam purchaseParam,
  ) async {
    try {
      // buyNonConsumable drives both non-consumables and (auto-renewable)
      // subscriptions through StoreKit / Play billing.
      return await store.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
  }
}
