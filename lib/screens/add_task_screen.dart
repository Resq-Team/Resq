import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/theme_provider.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State {
  final _formKey = GlobalKey();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedPriority = 'High Priority';
  String _selectedCategory = 'Medical';
  String _selectedStatus = 'Assigned';
  bool _isLoading = false;

  final List _priorities = ['High Priority', 'Medium Priority', 'Low Priority'];
  final List _categories = ['Medical', 'Supply', 'Shelter', 'General'];
  final List _statuses = ['Assigned', 'In-Progress', 'Completed'];

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future _saveTaskToFirestore() async {
    final formState = _formKey.currentState as FormState?;
    if (formState == null || !formState.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('volunteer_tasks').add({
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'date': _dateController.text.trim(),
        'priority': _selectedPriority,
        'category': _selectedCategory,
        'status': _selectedStatus,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task added successfully!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add task: $e', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch().isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : AppColors.background;
    final fieldFillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : AppColors.border;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final hintTextColor = isDark ? Colors.white54 : AppColors.textLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : AppColors.primaryNavy,
        title: Text(
          'Create Volunteer Task',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Task Title *', primaryTextColor),
              TextFormField(
                controller: _titleController,
                style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                decoration: _inputDecoration(
                  'e.g., Rescue Operation',
                  fillColor: fieldFillColor,
                  borderColor: borderColor,
                  hintColor: hintTextColor,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter task title' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Location *', primaryTextColor),
              TextFormField(
                controller: _locationController,
                style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                decoration: _inputDecoration(
                  'e.g., Flood - Colombo Sector 4',
                  fillColor: fieldFillColor,
                  borderColor: borderColor,
                  hintColor: hintTextColor,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Date & Time *', primaryTextColor),
              TextFormField(
                controller: _dateController,
                style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                decoration: _inputDecoration(
                  'e.g., May 15, 2026 • 10:30 AM',
                  fillColor: fieldFillColor,
                  borderColor: borderColor,
                  hintColor: hintTextColor,
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter date/time' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Category', primaryTextColor),
                        DropdownButtonFormField(
                          value: _selectedCategory,
                          dropdownColor: fieldFillColor,
                          style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                          decoration: _inputDecoration(
                            '',
                            fillColor: fieldFillColor,
                            borderColor: borderColor,
                            hintColor: hintTextColor,
                          ),
                          items: _categories
                              .map((c) => DropdownMenuItem(value: c, child: Text(c.toString())))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedCategory = v.toString());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Priority', primaryTextColor),
                        DropdownButtonFormField(
                          value: _selectedPriority,
                          dropdownColor: fieldFillColor,
                          style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                          decoration: _inputDecoration(
                            '',
                            fillColor: fieldFillColor,
                            borderColor: borderColor,
                            hintColor: hintTextColor,
                          ),
                          items: _priorities
                              .map((p) => DropdownMenuItem(value: p, child: Text(p.toString())))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedPriority = v.toString());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Status', primaryTextColor),
              DropdownButtonFormField(
                value: _selectedStatus,
                dropdownColor: fieldFillColor,
                style: GoogleFonts.poppins(fontSize: 13, color: primaryTextColor),
                decoration: _inputDecoration(
                  '',
                  fillColor: fieldFillColor,
                  borderColor: borderColor,
                  hintColor: hintTextColor,
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.toString())))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStatus = v.toString());
                },
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveTaskToFirestore,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SAVE TASK',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: textColor,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint, {
    required Color fillColor,
    required Color borderColor,
    required Color hintColor,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: hintColor),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }
}