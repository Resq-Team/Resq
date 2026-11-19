import 'package:hive_flutter/hive_flutter.dart';

import '../models/offline_data.dart';

class LocalStorageService {
  static const String boxName = 'offline_data';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get box => Hive.box(boxName);

  // ------------------------------------------------------------
  // SAVE OFFLINE DATA
  // ------------------------------------------------------------
  static Future<void> saveOfflineData(OfflineData data) async {
    await box.put(data.id, data.toMap());
  }

  // ------------------------------------------------------------
  // GET ALL OFFLINE DATA
  // ------------------------------------------------------------
  static List<OfflineData> getAllOfflineData() {
    final records = <OfflineData>[];

    for (final value in box.values) {
      if (value is Map) {
        records.add(
          OfflineData.fromMap(
            Map<dynamic, dynamic>.from(value),
          ),
        );
      }
    }

    return records;
  }

  // ------------------------------------------------------------
  // GET PENDING DATA
  // ------------------------------------------------------------
  static List<OfflineData> getPendingData() {
    return getAllOfflineData()
        .where((item) => item.syncStatus == 'pending')
        .toList();
  }

  // ------------------------------------------------------------
  // GET ONLY SOS DATA
  // ------------------------------------------------------------
  static List<OfflineData> getSosData() {
    return getAllOfflineData()
        .where((item) => item.type == 'sos')
        .toList()
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );
  }

  // ------------------------------------------------------------
  // MARK DATA AS SYNCHRONIZED
  // ------------------------------------------------------------
  static Future<void> markAsSynced(String id) async {
    final existing = box.get(id);

    if (existing is Map) {
      final updated = Map<dynamic, dynamic>.from(existing);

      updated['syncStatus'] = 'synced';

      await box.put(id, updated);
    }
  }

  // ------------------------------------------------------------
  // DELETE LOCAL DATA
  // ------------------------------------------------------------
  static Future<void> deleteData(String id) async {
    await box.delete(id);
  }

  // ------------------------------------------------------------
  // CLEAR ONLY SYNCHRONIZED DATA
  // ------------------------------------------------------------
  static Future<void> clearSyncedData() async {
    final synced = getAllOfflineData()
        .where((item) => item.syncStatus == 'synced')
        .toList();

    for (final item in synced) {
      await box.delete(item.id);
    }
  }
}