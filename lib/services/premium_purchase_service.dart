import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

enum PremiumPurchaseStartResult {
  started,
  storeUnavailable,
  productUnavailable,
  failedToStart,
}

class PremiumPurchaseService {
  PremiumPurchaseService({InAppPurchase? inAppPurchase})
    : _inAppPurchaseOverride = inAppPurchase;

  static const lifetimeProductId = 'chaos_premium_lifetime';

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
  }) {
    final store = _inAppPurchase;
    if (store == null) {
      return;
    }

    try {
      _purchaseSubscription ??= store.purchaseStream.listen((purchases) async {
        for (final purchase in purchases) {
          if (purchase.productID != lifetimeProductId) {
            continue;
          }

          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            await onEntitlementGranted();
          }

          if (purchase.status == PurchaseStatus.error) {
            onError(purchase.error?.message ?? 'Purchase failed.');
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

  Future<ProductDetailsResponse?> queryLifetimeProductDetails() async {
    final store = _inAppPurchase;
    if (store == null) {
      return null;
    }
    try {
      return await store.queryProductDetails({lifetimeProductId});
    } catch (_) {
      return null;
    }
  }

  Future<ProductDetails?> queryLifetimeProduct() async {
    final store = _inAppPurchase;
    if (store == null) {
      return null;
    }

    final available = await _isStoreAvailable(store);
    if (!available) {
      return null;
    }

    final response = await queryLifetimeProductDetails();
    if (response == null ||
        response.error != null ||
        response.productDetails.isEmpty) {
      return null;
    }
    return response.productDetails.first;
  }

  Future<PremiumPurchaseStartResult> buyLifetime() async {
    final store = _inAppPurchase;
    if (store == null) {
      return PremiumPurchaseStartResult.storeUnavailable;
    }

    final available = await _isStoreAvailable(store);
    if (!available) {
      return PremiumPurchaseStartResult.storeUnavailable;
    }

    final response = await queryLifetimeProductDetails();
    if (response == null || response.error != null) {
      return PremiumPurchaseStartResult.failedToStart;
    }
    if (response.productDetails.isEmpty) {
      return PremiumPurchaseStartResult.productUnavailable;
    }

    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    final started = await _startNonConsumablePurchase(store, purchaseParam);
    return started
        ? PremiumPurchaseStartResult.started
        : PremiumPurchaseStartResult.failedToStart;
  }

  Future<void> restoreSilently() async {
    final store = _inAppPurchase;
    if (store == null) {
      return;
    }

    final available = await _isStoreAvailable(store);
    if (available) {
      try {
        await store.restorePurchases();
      } catch (_) {
        // Silent restore should never block app startup on unsupported targets.
      }
    }
  }

  Future<bool> _isStoreAvailable(InAppPurchase store) async {
    try {
      return await store.isAvailable();
    } catch (_) {
      return false;
    }
  }

  Future<bool> _startNonConsumablePurchase(
    InAppPurchase store,
    PurchaseParam purchaseParam,
  ) async {
    try {
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
