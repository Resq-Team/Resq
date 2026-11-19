import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MissingPersonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cloudinary විස්තර (ඔබේ Cloudinary ගිණුමේ විස්තර මෙහි දමන්න)
  final String _cloudName = "expfwhzh";       // මෙතනට ඔබේ Cloud Name එක දමන්න
  final String _uploadPreset = "resq12"; // මෙතනට ඔබේ Upload Preset එක දමන්න

  // 1. Cloudinary වෙත Image එක Upload කර Secure URL එක ලබාගැනීම
  Future<String?> uploadImage(dynamic imageFile) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset;

      // Web සහ Mobile සඳහා වෙනස් ලෙස File/Bytes ඇතුළත් කිරීම
      if (kIsWeb) {
        // Web සඳහා (Uint8List bytes)
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile as Uint8List,
            filename: 'upload.jpg',
          ),
        );
      } else {
        // Mobile සඳහා (File)
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            (imageFile as File).path,
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonDat = json.decode(response.body);
        // Cloudinary මඟින් ලබාදෙන ස්ථිර Image URL එක (secure_url) Return කිරීම
        return jsonDat['secure_url'];
      } else {
        debugPrint('Cloudinary Upload Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading image to Cloudinary: $e');
      return null;
    }
  }

  // 2. Missing Person Report එක Firestore හි Save කිරීම
  Future<void> submitMissingReport({
    required String name,
    required int age,
    required String description,
    required String lastSeenLocation,
    required String contactNumber,
    required String imageUrl,
  }) async {
    await _firestore.collection('missing_persons').add({
      'name': name,
      'age': age,
      'description': description,
      'lastSeenLocation': lastSeenLocation,
      'contactNumber': contactNumber,
      'imageUrl': imageUrl,
      'status': 'Missing', // Status: Missing / Found
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Firestore හි ඇති Missing Persons Data Stream එකක් ලෙස ලබාගැනීම
  Stream<QuerySnapshot> getMissingPersons() {
    return _firestore
        .collection('missing_persons')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}