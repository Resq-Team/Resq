import 'dart:async';

import '../models/offline_data.dart';
import 'local_storage_service.dart';
import 'sos_service.dart';
import 'connectivity_service.dart';

class SyncService {
  static final ConnectivityService _connectivityService = ConnectivityService();

  static bool _isSyncing = false;

  static List<OfflineData> getPendingData() {
    return LocalStorageService.getPendingData();
  }

  static Future<void> syncPendingData() async {
    // Prevent multiple sync operations from running together.
    if (_isSyncing) return;

    _isSyncing = true;

    try {
      final isOnline = await _connectivityService.isOnline();

      if (!isOnline) return;

      final pendingData = getPendingData();

      if (pendingData.isEmpty) return;

      final sosService = SosService();

      for (final item in pendingData) {
        try {
          if (item.type.toLowerCase() == 'sos') {
            final data = item.data;

            await sosService
                .sendSosAlert(
                  alertId: item.id,
                  latitude: (data['latitude'] as num?)?.toDouble(),
                  longitude: (data['longitude'] as num?)?.toDouble(),
                  userName: data['userName'] as String?,
                  userPhone: data['userPhone'] as String?,
                  message: data['message'] as String? ??
                      'Emergency! Immediate help needed.',
                )
                .timeout(const Duration(seconds: 10));

            // Mark as synced only after Firestore succeeds.
            await LocalStorageService.markAsSynced(item.id);

            print('SYNCED SUCCESSFULLY: ${item.id}');
          }
        } on TimeoutException {
          print('SYNC TIMEOUT: ${item.id}');
          // Keep the record pending.
        } catch (e) {
          print('SYNC FAILED: ${item.id}');
          print('Error: $e');
          // Keep the record pending.
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}
