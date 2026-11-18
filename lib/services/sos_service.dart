import 'package:cloud_firestore/cloud_firestore.dart';

class SosService {
  final CollectionReference _sosCollection =
      FirebaseFirestore.instance.collection('sos_alerts');

  /// Sends an SOS alert using its local ID to prevent duplicates.
  Future<void> sendSosAlert({
    required String alertId,
    double? latitude,
    double? longitude,
    String? userName,
    String? userPhone,
    String message = 'Emergency! Immediate help needed.',
  }) async {
    try {
      final document = _sosCollection.doc(alertId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final existingDocument = await transaction.get(document);

        // Do not overwrite an SOS that has already been uploaded.
        if (!existingDocument.exists) {
          transaction.set(document, {
            'id': alertId,
            'latitude': latitude,
            'longitude': longitude,
            'locationAvailable': latitude != null && longitude != null,
            'userName': userName ?? 'Anonymous',
            'userPhone': userPhone ?? 'Not provided',
            'message': message,
            'status': 'active',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      throw Exception('Failed to send SOS alert: $e');
    }
  }

  /// Fetches all active SOS alerts.
  Stream<QuerySnapshot> getActiveSosAlerts() {
    return _sosCollection
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Marks an SOS alert as resolved.
  Future<void> resolveSosAlert(String alertId) async {
    await _sosCollection.doc(alertId).update({
      'status': 'resolved',
    });
  }
}
