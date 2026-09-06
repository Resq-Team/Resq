import '../models/offline_data.dart';
import 'local_storage_service.dart';

class SyncService {
  // Get all offline records waiting for synchronization.
  static List<OfflineData> getPendingData() {
    return LocalStorageService.getPendingData();
  }

  // This will be connected to Firebase later.
  static Future<void> syncPendingData() async {
    final pendingData = getPendingData();

    print('PENDING RECORDS: ${pendingData.length}');

    for (final item in pendingData) {
      print('Waiting to sync: ${item.id}');
    }
  }
}