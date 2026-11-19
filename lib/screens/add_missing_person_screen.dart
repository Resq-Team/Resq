import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/missing_person_service.dart';
import '../services/theme_provider.dart';

class AddMissingPersonScreen extends StatefulWidget {
  const AddMissingPersonScreen({super.key});

  @override
  State createState() => _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State {
  final _formKey = GlobalKey();
  final MissingPersonService _service = MissingPersonService();

  dynamic _selectedImage; // Mobile -> File, Web -> Uint8List
  final ImagePicker _picker = ImagePicker();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  // Gallery/Camera මඟින් Image එක තෝරාගැනීම
  Future _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _selectedImage = bytes);
      } else {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  // Submit Logic
  Future _submitReport() async {
    final formState = _formKey.currentState as FormState?;
    if (formState == null || !formState.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image of the missing person')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // 1. Upload Image to Cloudinary (using MissingPersonService)
    String? imageUrl = await _service.uploadImage(_selectedImage);

    if (!mounted) return;

    if (imageUrl != null) {
      // 2. Save Report to Firestore
      await _service.submitMissingReport(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        lastSeenLocation: _locationController.text.trim(),
        contactNumber: _contactController.text.trim(),
        imageUrl: imageUrl,
      );

      if (!mounted) return;

      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing person report submitted successfully!')),
      );
      Navigator.pop(context);
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload image. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch().isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : AppColors.background;
    final boxColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200;
    final borderColor = isDark ? Colors.white24 : Colors.grey.shade400;
    final placeholderTextColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Report Missing Person',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : AppColors.primaryNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Image Preview & Upload Box
              GestureDetector(
                onTap: () => _showImagePickerBottomSheet(isDark),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: kIsWeb
                              ? Image.memory(_selectedImage, fit: BoxFit.cover)
                              : Image.file(_selectedImage, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_rounded,
                              size: 40,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload photo',
                              style: GoogleFonts.poppins(color: placeholderTextColor),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Form Input Fields
              TextFormField(
                controller: _nameController,
                style: GoogleFonts.poppins(color: primaryTextColor),
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => (val == null || val.isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(color: primaryTextColor),
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (val) => (val == null || val.isEmpty) ? 'Enter age' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                style: GoogleFonts.poppins(color: primaryTextColor),
                decoration: const InputDecoration(labelText: 'Last Seen Location'),
                validator: (val) => (val == null || val.isEmpty) ? 'Enter location' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.poppins(color: primaryTextColor),
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (val) => (val == null || val.isEmpty) ? 'Enter contact number' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                style: GoogleFonts.poppins(color: primaryTextColor),
                decoration: const InputDecoration(
                  labelText: 'Additional Details (Clothing, Marks, etc.)',
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isUploading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Submit Report',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? Colors.white70 : null,
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: isDark ? Colors.white70 : null,
              ),
              title: Text(
                'Take a Photo',
                style: TextStyle(color: isDark ? Colors.white : null),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}