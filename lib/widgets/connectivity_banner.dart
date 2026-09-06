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
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
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
    _connectivityService.connectivityStream.listen((results) async {
      final online = results.any(
        (connection) =>
            connection == ConnectivityResult.wifi ||
            connection == ConnectivityResult.mobile ||
            connection == ConnectivityResult.ethernet,
      );

      if (mounted) {
  setState(() {
    _isOnline = online;
  });
}

if (online) {
  await SyncService.syncPendingData();
}
    });
  }

  Future<void> _checkInitialConnection() async {
    final online = await _connectivityService.isOnline();

    if (mounted) {
      setState(() {
        _isOnline = online;
      });
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 16,
            ),
            color: Colors.red,
            child: const Text(
              'You are offline. Changes will be saved locally.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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