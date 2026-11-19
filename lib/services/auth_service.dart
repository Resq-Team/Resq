import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cloudinary විස්තර
  final String _cloudName = "expfwhzh";
  final String _uploadPreset = "resq12";

  /// Returns the currently logged-in user, or null if not logged in
  User? get currentUser => _auth.currentUser;

  /// Stream that notifies when auth state changes (login/logout)
  Stream get authStateChanges => _auth.authStateChanges();

  /// Profile Image එක Cloudinary වෙත Upload කිරීමේ Helper Method එක
  Future _uploadProfileImage(dynamic imageFile) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");

      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            imageFile as Uint8List,
            filename: 'profile.jpg',
          ),
        );
      } else {
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
        final jsonData = json.decode(response.body);
        return jsonData['secure_url']; // Cloudinary මඟින් ලැබෙන ස්ථිර Image URL එක
      } else {
        debugPrint('Cloudinary Upload Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Registers a new user with email & password, profile image, and saves their profile to Firestore
  Future register({
    required String name,
    required String email,
    required String password,
    dynamic profileImageFile,
    String role = 'citizen',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        String? profileImageUrl;

        // Profile Image එක දී ඇත්නම් Cloudinary වෙත Upload කිරීම
        if (profileImageFile != null) {
          profileImageUrl = await _uploadProfileImage(profileImageFile);
        }

        // Save additional profile info to Firestore with profileImageUrl
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': role,
          'profileImageUrl': profileImageUrl ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update Firebase Auth display name too
        await user.updateDisplayName(name);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  /// Updates user name, phone, and optionally uploads a new profile image to Cloudinary
  Future updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    dynamic newProfileImageFile,
    String? existingImageUrl,
  }) async {
    try {
      String imageUrl = existingImageUrl ?? '';

      if (newProfileImageFile != null) {
        final uploadedUrl = await _uploadProfileImage(newProfileImageFile);
        if (uploadedUrl != null && uploadedUrl.toString().isNotEmpty) {
          imageUrl = uploadedUrl.toString();
        }
      }

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'phone': phone,
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final current = _auth.currentUser;
      if (current != null && current.uid == uid) {
        await current.updateDisplayName(name);
        if (imageUrl.isNotEmpty) {
          await current.updatePhotoURL(imageUrl);
        }
      }

      return {
        'name': name,
        'phone': phone,
        'profileImageUrl': imageUrl,
      };
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Re-authenticates with current password and updates to new password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No logged-in user found.');
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Logs in an existing user with email & password
  Future login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Logs out the current user
  Future logout() async {
    await _auth.signOut();
  }

  /// Sends a password reset email
  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Fetches the user's profile document from Firestore
  Future getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data();
  }

  /// Converts Firebase error codes into friendly messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect current password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect current password or credentials.';
      case 'requires-recent-login':
        return 'Please log in again before changing your password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}