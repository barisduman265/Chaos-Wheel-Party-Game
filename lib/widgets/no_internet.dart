import 'dart:async';

import 'package:chaos_wheel/providers/game_provider.dart';
import 'package:chaos_wheel/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Returns true when the device is online. When it's offline it shows a
/// blocking themed dialog (with Retry) and returns true only if the player
/// reconnects, otherwise false. Gate anything that needs ads (i.e. starting a
/// game) behind this so play sessions can always load ads.
Future<bool> ensureOnline(BuildContext context) async {
  if (await ConnectivityService.instance.isOnline()) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.82),
    builder: (_) => const _NoInternetDialog(),
  );
  return result ?? false;
}

class _NoInternetCard extends StatelessWidget {
  const _NoInternetCard({
    required this.message,
    required this.busy,
    required this.onRetry,
  });

  final String message;
  final bool busy;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B0C2A), Color(0xFF0E0416)],
        ),
        border: Border.all(color: const Color(0xFF39D2FF).withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA85BFF).withValues(alpha: 0.28),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF39D2FF).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFF39D2FF).withValues(alpha: 0.45),
              ),
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Color(0xFF62D8FF),
              size: 32,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            provider.l('noInternetTitle'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.66),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: busy ? null : onRetry,
            child: Container(
              width: double.infinity,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFA85BFF), Color(0xFF39D2FF)],
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      provider.l('retry'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoInternetDialog extends StatefulWidget {
  const _NoInternetDialog();

  @override
  State<_NoInternetDialog> createState() => _NoInternetDialogState();
}

class _NoInternetDialogState extends State<_NoInternetDialog> {
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    final online = await ConnectivityService.instance.isOnline();
    if (!mounted) {
      return;
    }
    if (online) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      child: _NoInternetCard(
        message: context.read<GameProvider>().l('noInternetMessage'),
        busy: _checking,
        onRetry: _retry,
      ),
    );
  }
}

/// Full-screen blocker shown over gameplay when the connection drops mid-game,
/// so turns (and their ads) never happen offline. Place as the last child of
/// the game screen's Stack.
class OfflineGuard extends StatefulWidget {
  const OfflineGuard({super.key});

  @override
  State<OfflineGuard> createState() => _OfflineGuardState();
}

class _OfflineGuardState extends State<OfflineGuard> {
  bool _offline = false;
  bool _checking = false;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _refresh();
    _sub = ConnectivityService.instance.onStatusChange.listen((online) {
      if (mounted) {
        setState(() => _offline = !online);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final online = await ConnectivityService.instance.isOnline();
    if (mounted) {
      setState(() {
        _offline = !online;
        _checking = false;
      });
    }
  }

  Future<void> _retry() async {
    setState(() => _checking = true);
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) {
      return const SizedBox.shrink();
    }
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.88),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: _NoInternetCard(
          message: context.read<GameProvider>().l('connectionLost'),
          busy: _checking,
          onRetry: _retry,
        ),
      ),
    );
  }
}
