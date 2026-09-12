import 'package:cloud_firestore/cloud_firestore.dart';

class SosService {
  final CollectionReference _sosCollection =
      FirebaseFirestore.instance.collection('sos_alerts');

  /// Sends an SOS emergency alert to Firestore
  Future<void> sendSosAlert({
    required double latitude,
    required double longitude,
    String? userName,
    String? userPhone,
    String message = 'Emergency! Immediate help needed.',
  }) async {
    try {
      await _sosCollection.add({
        'latitude': latitude,
        'longitude': longitude,
        'userName': userName ?? 'Anonymous',
        'userPhone': userPhone ?? 'Not provided',
        'message': message,
        'status': 'active', // active, resolved, cancelled
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send SOS alert: $e');
    }
  }

  /// Fetches all active SOS alerts (for volunteer/admin dashboard)
  Stream<QuerySnapshot> getActiveSosAlerts() {
    return _sosCollection
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Marks an SOS alert as resolved
  Future<void> resolveSosAlert(String alertId) async {
    await _sosCollection.doc(alertId).update({'status': 'resolved'});
  }
}
