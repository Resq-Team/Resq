import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Live location එක Firestore හි update කිරීම
  Future<void> updateLiveLocation({
    required String userId,
    required Position position,
    String? address,
    bool isEmergency = false,
  }) async {
    try {
      await _firestore.collection('live_locations').doc(userId).set({
        'userId': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
        'accuracy': position.accuracy,
        'address': address ?? '',
        'isEmergency': isEmergency,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating location to Firestore: $e');
    }
  }

  // Location Sharing නැවැත්වූ විට Status එක Update කිරීම
  Future<void> stopSharingLocation(String userId) async {
    try {
      await _firestore.collection('live_locations').doc(userId).update({
        'isSharing': false,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error stopping location stream: $e');
    }
  }
}