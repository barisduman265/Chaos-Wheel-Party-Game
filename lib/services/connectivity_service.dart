import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Reports whether the device actually has working internet — needed because
/// ads (our revenue) only load online. A network interface being "up" isn't
/// enough (e.g. Wi‑Fi with no internet / captive portal), so a real
/// reachability lookup confirms it.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// True only when there's a network interface AND a host is actually
  /// reachable.
  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface = results.any(
        (r) => r != ConnectivityResult.none,
      );
      if (!hasInterface) {
        return false;
      }
    } catch (_) {
      // If the plugin fails, fall through to the reachability probe.
    }
    return _canReachInternet();
  }

  Future<bool> _canReachInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Emits the online/offline status whenever connectivity changes. Used to
  /// block gameplay the moment the connection drops mid‑game.
  Stream<bool> get onStatusChange =>
      _connectivity.onConnectivityChanged.asyncMap((_) => isOnline());
}
