import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class MissingPersonsScreen extends StatefulWidget {
  const MissingPersonsScreen({super.key});

  @override
  State<MissingPersonsScreen> createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _persons = [
    {
      'name': 'Nimal Perera',
      'gender': 'Male',
      'age': '35 years',
      'lastSeen': 'Colombo • May 12, 2024',
      'contact': '077 123 4567',
      'details': 'Wearing blue shirt & black trousers, last seen near Kelani bridge during water rise.',
      'avatarBg': Color(0xFFFFCCBC),
      'avatarColor': Color(0xFFD84315),
    },
    {
      'name': 'Kavindu Silva',
      'gender': 'Male',
      'age': '28 years',
      'lastSeen': 'Gampaha • May 11, 2024',
      'contact': '071 987 6543',
      'details': 'Height 5ft 8in, last seen near Ja-Ela evacuation shelter center.',
      'avatarBg': Color(0xFFC8E6C9),
      'avatarColor': Color(0xFF2E7D32),
    },
    {
      'name': 'Dilhani Fernando',
      'gender': 'Female',
      'age': '22 years',
      'lastSeen': 'Kandy • May 10, 2024',
      'contact': '076 555 1234',
      'details': 'Student, carrying red backpack, last seen near Peradeniya flood shelter.',
      'avatarBg': Color(0xFFF8BBD0),
      'avatarColor': Color(0xFFC2185B),
    },
  ];

  List<Map<String, dynamic>> get _filteredPersons {
    if (_searchQuery.isEmpty) return _persons;
    return _persons
        .where((p) => (p['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showReportDialog() {
    final nameCtrl = TextEditingController();
    final locCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Report Missing Person',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Last Known Location & Date',
                  prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _persons.insert(0, {
                      'name': nameCtrl.text,
                      'gender': 'Unknown',
                      'age': 'Age not specified',
                      'lastSeen': locCtrl.text.isNotEmpty ? locCtrl.text : 'Reported Just Now',
                      'contact': 'Emergency Hotline 119',
                      'details': 'Recently filed missing person report. Under investigation.',
                      'avatarBg': Color(0xFFFFCDD2),
                      'avatarColor': Color(0xFFC62828),
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Missing person record posted.', style: GoogleFonts.poppins(fontSize: 12)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Submit', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showPersonDetails(Map<String, dynamic> person) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: person['avatarBg'] as Color,
                    child: Text(
                      (person['name'] as String).substring(0, 1),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: person['avatarColor'] as Color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${person['gender']} • ${person['age']}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Last Seen Location & Time',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(person['lastSeen'] as String, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Text(
                'Identification Details',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(person['details'] as String, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contacting reported family coordinator (${person['contact']})...', style: GoogleFonts.poppins(fontSize: 12)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                label: Text('Contact Family / Finder (${person['contact']})', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
          'Missing Persons',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textLight, size: 22),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                fillColor: const Color(0xFFF8FAFC),
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
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Persons List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: _filteredPersons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final person = _filteredPersons[index];
                return GestureDetector(
                  onTap: () => _showPersonDetails(person),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.025),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: person['avatarBg'] as Color,
                          child: Text(
                            (person['name'] as String).substring(0, 1),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: person['avatarColor'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                person['name'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${person['gender']} - ${person['age']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Last seen: ${person['lastSeen']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.emergencyRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.textLight,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Report Missing Person bottom action
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: _showReportDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Report Missing Person',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
