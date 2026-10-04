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

  bool _isOnline = true;

  @override
  void initState() {
    super.initState();

    _checkInitialConnection();

    _subscription =
        _connectivityService.connectivityStream.listen(
      (results) async {
        final actuallyOnline =
            await _connectivityService.isOnline();

        if (!mounted) return;

        setState(() {
          _isOnline = actuallyOnline;
        });

        if (actuallyOnline) {
          try {
            await SyncService.syncPendingData();

            debugPrint(
              'Automatic synchronization completed.',
            );
          } catch (e) {
            debugPrint(
              'Automatic synchronization failed: $e',
            );
          }
        }
      },
    );
  }

  Future<void> _checkInitialConnection() async {
    final online =
        await _connectivityService.isOnline();

    if (!mounted) return;

    setState(() {
      _isOnline = online;
    });

    if (online) {
      try {
        await SyncService.syncPendingData();

        debugPrint(
          'Initial synchronization completed.',
        );
      } catch (e) {
        debugPrint(
          'Initial synchronization failed: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
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