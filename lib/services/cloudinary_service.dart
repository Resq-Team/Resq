import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadService {
  // 1. ඔබේ Cloudinary විස්තර මෙහි දමන්න
  final String cloudName = "expfwhzh"; // ඔබේ Cloud Name එක මෙහි දමන්න
  final String uploadPreset = "resq12"; // ඔබේ Upload Preset එක මෙහි දමන්න

  // 2. Image එක Cloudinary වෙත Upload කිරීමේ Function එක
  Future<String?> uploadImageToCloudinary(File imageFile) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonDat = json.decode(response.body);
        // Upload වූ පසු ලැබෙන Secure URL එක ලබා දීම
        return jsonDat['secure_url'];
      } else {
        print("Cloudinary Upload Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  // 3. ඩේටා සහ Image URL එක Firestore වෙත Save කිරීම
  Future<void> submitMissingPersonData({
    required String name,
    required String details,
    required File imageFile,
  }) async {
    try {
      // පළමුව Image එක Cloudinary වෙත Upload කර URL එක ලබා ගැනීම
      String? imageUrl = await uploadImageToCloudinary(imageFile);

      if (imageUrl == null) {
        throw Exception("Failed to upload image to Cloudinary");
      }

      // ඊට පසු Firestore වෙත දේටා Save කිරීම
      await FirebaseFirestore.instance.collection('missing_persons').add({
        'name': name,
        'details': details,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Data and Image successfully saved!");
    } catch (e) {
      print("Submission Failed: $e");
    }
  }
}