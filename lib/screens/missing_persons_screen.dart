import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';

class MissingPersonsScreen extends StatefulWidget {
  const MissingPersonsScreen({super.key});

  @override
  State<MissingPersonsScreen> createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Database හිස් නම් එකතු කිරීමට ඇති Initial Data
  final List<Map<String, dynamic>> _initialPersons = const [
    {
      'name': 'Nimal Perera',
      'gender': 'Male',
      'age': '35 years',
      'lastSeen': 'Colombo • May 12, 2024',
      'contact': '0771234567',
      'details': 'Wearing blue shirt & black trousers, last seen near Kelani bridge during water rise.',
      'avatarBgHex': '#FFFFCCBC',
      'avatarColorHex': '#FFD84315',
    },
    {
      'name': 'Kavindu Silva',
      'gender': 'Male',
      'age': '28 years',
      'lastSeen': 'Gampaha • May 11, 2024',
      'contact': '0719876543',
      'details': 'Height 5ft 8in, last seen near Ja-Ela evacuation shelter center.',
      'avatarBgHex': '#FFC8E6C9',
      'avatarColorHex': '#FF2E7D32',
    },
    {
      'name': 'Dilhani Fernando',
      'gender': 'Female',
      'age': '22 years',
      'lastSeen': 'Kandy • May 10, 2024',
      'contact': '0765551234',
      'details': 'Student, carrying red backpack, last seen near Peradeniya flood shelter.',
      'avatarBgHex': '#FFF8BBD0',
      'avatarColorHex': '#FFC2185B',
    },
  ];

  // Database එක හිස් නම් Initial Data seed කරන Function එක
  Future<void> _seedInitialData() async {
    final collection = FirebaseFirestore.instance.collection('missing_persons');
    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) {
      for (var person in _initialPersons) {
        await collection.add({
          ...person,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  // Color Hex String එක Color Object බවට හරවන Helper
  Color _parseColor(String? colorHex, Color defaultColor) {
    if (colorHex == null || colorHex.isEmpty) return defaultColor;
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
    } catch (_) {
      return defaultColor;
    }
  }

  // Report Missing Person Dialog
  void _showReportDialog() {
    final nameCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    final genderCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final detailsCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Report Missing Person',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: ageCtrl,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Age (e.g. 25 yrs)',
                          prefixIcon: Icon(Icons.cake_outlined, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: genderCtrl,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Gender',
                          prefixIcon: Icon(Icons.wc_outlined, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: locCtrl,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Last Known Location & Date *',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Contact Phone Number *',
                    prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: detailsCtrl,
                  maxLines: 2,
                  style: GoogleFonts.poppins(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Identification details / clothes worn...',
                    prefixIcon: Icon(Icons.info_outline, size: 20),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty && contactCtrl.text.trim().isNotEmpty) {
                  final String name = nameCtrl.text.trim();
                  final String age = ageCtrl.text.trim().isNotEmpty ? ageCtrl.text.trim() : 'Age unspecified';
                  final String gender = genderCtrl.text.trim().isNotEmpty ? genderCtrl.text.trim() : 'Unknown';
                  final String lastSeen = locCtrl.text.trim().isNotEmpty ? locCtrl.text.trim() : 'Reported Just Now';
                  final String contact = contactCtrl.text.trim();
                  final String details = detailsCtrl.text.trim().isNotEmpty
                      ? detailsCtrl.text.trim()
                      : 'Recently filed missing person report.';

                  Navigator.pop(context);

                  try {
                    await FirebaseFirestore.instance.collection('missing_persons').add({
                      'name': name,
                      'gender': gender,
                      'age': age,
                      'lastSeen': lastSeen,
                      'contact': contact,
                      'details': details,
                      'avatarBgHex': '#FFFFCDD2',
                      'avatarColorHex': '#FFC62828',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Missing person record posted to database.', style: GoogleFonts.poppins(fontSize: 12)),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to submit report: $e', style: GoogleFonts.poppins(fontSize: 12)),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill Name and Contact Number.', style: GoogleFonts.poppins(fontSize: 12)),
                      backgroundColor: Colors.orange[800],
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

  // Contact Phone Call Launcher Helper
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // Person Details Bottom Sheet
  void _showPersonDetails(Map<String, dynamic> person) {
    final Color avatarBg = _parseColor(person['avatarBgHex'], const Color(0xFFFFCCBC));
    final Color avatarColor = _parseColor(person['avatarColorHex'], const Color(0xFFD84315));
    final String name = person['name'] ?? 'Unknown Person';
    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

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
                    backgroundColor: avatarBg,
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: avatarColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${person['gender'] ?? "N/A"} • ${person['age'] ?? "Age N/A"}',
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
              Text(person['lastSeen'] ?? 'Not specified', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              Text(
                'Identification Details',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(person['details'] ?? 'No additional details provided.', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  final String contactNum = person['contact'] ?? '';
                  if (contactNum.isNotEmpty) {
                    _makePhoneCall(contactNum);
                  }
                },
                icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                label: Text('Contact Family / Finder (${person['contact'] ?? "N/A"})',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
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
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
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

          // Persons List using Firestore StreamBuilder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('missing_persons')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading records: ${snapshot.error}',
                      style: GoogleFonts.poppins(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.emergencyRed),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                // Database එක හිස් නම් Auto Initial Seed කිරීම
                if (docs.isEmpty) {
                  _seedInitialData();
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.emergencyRed),
                  );
                }

                // Search Filter යෙදීම
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      'No missing person records match your search.',
                      style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredDocs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final person = filteredDocs[index].data() as Map<String, dynamic>;
                    final String name = person['name'] ?? 'Unknown';
                    final String initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
                    final Color avatarBg = _parseColor(person['avatarBgHex'], const Color(0xFFFFCCBC));
                    final Color avatarColor = _parseColor(person['avatarColorHex'], const Color(0xFFD84315));

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
                              backgroundColor: avatarBg,
                              child: Text(
                                initial,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: avatarColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${person['gender'] ?? "N/A"} - ${person['age'] ?? "N/A"}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last seen: ${person['lastSeen'] ?? "Unknown"}',
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