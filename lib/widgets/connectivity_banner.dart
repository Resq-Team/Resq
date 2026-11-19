
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class ConnectivityBanner extends StatefulWidget {
  final Widget child;

  const ConnectivityBanner({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityBanner> createState() =>
      _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  final ConnectivityService _connectivityService =
      ConnectivityService();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Timer? _syncTimer;

  bool _isOnline = true;
  bool _isCheckingConnection = false;

  @override
  void initState() {
    super.initState();

    debugPrint('CONNECTIVITY BANNER INITIALIZED');

    _checkInitialConnection();

    _subscription =
        _connectivityService.connectivityStream.listen(
      (results) async {
        debugPrint('CONNECTIVITY EVENT: $results');

        await _checkConnectionAndSync();
      },
      onError: (error) {
        debugPrint('CONNECTIVITY STREAM ERROR: $error');
      },
    );

    // Retry pending data every 15 seconds.
    _syncTimer = Timer.periodic(
      const Duration(seconds: 15),
      (timer) async {
        debugPrint('PERIODIC SYNC RETRY');

        await _checkConnectionAndSync();
      },
    );
  }

  Future<void> _checkInitialConnection() async {
    debugPrint('CHECKING INITIAL INTERNET CONNECTION');

    await _checkConnectionAndSync();
  }

  Future<void> _checkConnectionAndSync() async {
    // Prevent overlapping connection checks.
    if (_isCheckingConnection) return;

    _isCheckingConnection = true;

    try {
      final actuallyOnline =
          await _connectivityService.isOnline();

      debugPrint('INTERNET STATUS: $actuallyOnline');

      if (!mounted) return;

      if (_isOnline != actuallyOnline) {
        setState(() {
          _isOnline = actuallyOnline;
        });
      }

      if (actuallyOnline) {
        debugPrint('INTERNET AVAILABLE: Checking pending SOS');

        await SyncService.syncPendingData();

        debugPrint('SYNC ATTEMPT COMPLETED');

        final remaining =
            SyncService.getPendingData().length;

        debugPrint('PENDING RECORDS REMAINING: $remaining');
      } else {
        debugPrint('DEVICE IS OFFLINE');
      }
    } catch (e) {
      debugPrint('CONNECTION CHECK OR SYNC FAILED: $e');
    } finally {
      _isCheckingConnection = false;
    }
  }

  @override
  void dispose() {
    debugPrint('CONNECTIVITY BANNER DISPOSED');

    _subscription?.cancel();
    _syncTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_isOnline)
          Material(
            color: Colors.red,
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: const Text(
                  'You are offline. Changes will be saved locally.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.2,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        Expanded(
          child: widget.child,
        ),
      ],
    );
  }
}
