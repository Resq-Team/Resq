import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisasterReportScreen extends StatefulWidget {
  const DisasterReportScreen({Key? key}) : super(key: key);

  @override
  State<DisasterReportScreen> createState() => _DisasterReportScreenState();
}

class _DisasterReportScreenState extends State<DisasterReportScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDisasterType;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _peopleAffectedController = TextEditingController();
  bool _isUrgent = false;
  bool _isLoading = false; // Loading indicator එක සඳහා

  final List<String> _disasterTypes = [
    'Flood (ගංවතුර)',
    'Landslide (නායයාම්)',
    'Tsunami (සුනාමි)',
    'Fire (ගිනි ගැනීම්)',
    'Cyclone / Storm (කුණාටු)',
    'Other (වෙනත්)',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    _peopleAffectedController.dispose();
    super.dispose();
  }

  // Firebase Firestore වෙත Data එකතු කිරීමේ Method එක
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('disaster_reports').add({
        'disasterType': _selectedDisasterType,
        'location': _locationController.text.trim(),
        'peopleAffected': int.tryParse(_peopleAffectedController.text.trim()) ?? 0,
        'description': _descriptionController.text.trim(),
        'isUrgent': _isUrgent,
        'status': 'Pending', // Default status: Pending / Responded / Resolved
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disaster report submitted successfully to Firebase!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Report a Disaster'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 30),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please provide accurate information for quick emergency response.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Disaster Type *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDisasterType,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Select disaster type',
                    ),
                    items: _disasterTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedDisasterType = val),
                    validator: (val) => val == null ? 'Please select a disaster type' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Location / Landmark *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'e.g., Near Kaduwela bridge',
                      suffixIcon: Icon(Icons.my_location, color: Colors.blue),
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Please enter the location' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Estimated People Affected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _peopleAffectedController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'e.g., 50',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text('Description / Details *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Describe the current situation and immediate needs...',
                    ),
                    validator: (val) => (val == null || val.isEmpty) ? 'Please enter a description' : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: CheckboxListTile(
                  title: const Text('Mark as High Urgency / Life Threatening', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  activeColor: Colors.redAccent,
                  value: _isUrgent,
                  onChanged: (val) => setState(() => _isUrgent = val ?? false),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _submitReport,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SUBMIT REPORT',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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