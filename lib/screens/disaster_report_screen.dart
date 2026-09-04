import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class DisasterReportScreen extends StatefulWidget {
  const DisasterReportScreen({super.key});

  @override
  State<DisasterReportScreen> createState() => _DisasterReportScreenState();
}

class _DisasterReportScreenState extends State<DisasterReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDisasterType = 'Flood';
  final TextEditingController _descController = TextEditingController(
    text: 'Heavy flooding in our area. People need immediate help.',
  );
  final TextEditingController _locationController = TextEditingController(
    text: '123 Main Street, Colombo',
  );

  final List<String> _disasterTypes = [
    'Flood',
    'Landslide',
    'Heavy Rain',
    'Fire Breakout',
    'Severe Storm',
    'Earthquake',
    'Building Collapse',
    'Other Emergency',
  ];

  final List<Map<String, dynamic>> _attachedImages = [
    {
      'id': '1',
      'label': 'Water level road',
      'color': Color(0xFF90CAF9),
      'icon': Icons.water_rounded,
    },
    {
      'id': '2',
      'label': 'House surroundings',
      'color': Color(0xFF80CBC4),
      'icon': Icons.home_rounded,
    },
    {
      'id': '3',
      'label': 'Submerged vehicle',
      'color': Color(0xFFB0BEC5),
      'icon': Icons.directions_car_rounded,
    },
  ];

  bool _isSubmitting = false;

  void _addImageMock() {
    setState(() {
      _attachedImages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'label': 'Photo ${_attachedImages.length + 1}',
        'color': Color(0xFFFFCC80),
        'icon': Icons.image_rounded,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Photo attached successfully',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.infoGreen,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Report Submitted!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your disaster report #DR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)} has been recorded and transmitted to emergency dispatchers.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return back to Home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Back to Home',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Disaster Report',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Disaster Type Section
              Text(
                'Disaster Type',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedDisasterType,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                    items: _disasterTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedDisasterType = val);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Description Section
              Text(
                'Description',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter incident details, hazards, or stranded count...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter description' : null,
              ),

              const SizedBox(height: 20),

              // Upload Images Section
              Text(
                'Upload Images',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Add Photo Camera Box
                    GestureDetector(
                      onTap: _addImageMock,
                      child: Container(
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.border,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.textSecondary,
                              size: 28,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Preview Thumbnails
                    ..._attachedImages.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final img = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 86,
                        height: 86,
                        decoration: BoxDecoration(
                          color: img['color'] as Color,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(
                                img['icon'] as IconData,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            // Delete badge
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location Section
              Text(
                'Location',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: const Icon(
                    Icons.location_on,
                    color: AppColors.emergencyRed,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Please enter location' : null,
              ),

              const SizedBox(height: 36),

              // Submit Report Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        'Submit Report',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
