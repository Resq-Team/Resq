import 'package:hive_flutter/hive_flutter.dart';

import '../models/offline_data.dart';

class LocalStorageService {
  static const String boxName = 'offline_data';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Box get box => Hive.box(boxName);

  // Save an offline record
  static Future<void> saveOfflineData(OfflineData data) async {
    await box.put(data.id, data.toMap());
  }

  // Get all offline records
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

  // Get only records waiting to be synchronized
  static List<OfflineData> getPendingData() {
    return getAllOfflineData()
        .where((item) => item.syncStatus == 'pending')
        .toList();
  }

  // Mark a record as synchronized
  static Future<void> markAsSynced(String id) async {
    final existing = box.get(id);

    if (existing is Map) {
      final updated = Map<dynamic, dynamic>.from(existing);
      updated['syncStatus'] = 'synced';

      await box.put(id, updated);
    }
  }

  // Delete a local record
  static Future<void> deleteData(String id) async {
    await box.delete(id);
  }
}