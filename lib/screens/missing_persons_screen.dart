import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import 'add_missing_person_screen.dart';

class MissingPersonsScreen extends StatefulWidget {
  const MissingPersonsScreen({super.key});

  @override
  State<MissingPersonsScreen> createState() => _MissingPersonsScreenState();
}

class _MissingPersonsScreenState extends State<MissingPersonsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Database හිස් නම් එකතු කිරීමට ඇති Initial Mock Data
  final List<Map<String, dynamic>> _initialPersons = const [
    {
      'name': 'Nimal Perera',
      'gender': 'Male',
      'age': '35',
      'lastSeenLocation': 'Colombo • May 12, 2024',
      'contactNumber': '0771234567',
      'description': 'Wearing blue shirt & black trousers, last seen near Kelani bridge during water rise.',
      'avatarBgHex': '#FFFFCCBC',
      'avatarColorHex': '#FFD84315',
    },
    {
      'name': 'Kavindu Silva',
      'gender': 'Male',
      'age': '28',
      'lastSeenLocation': 'Gampaha • May 11, 2024',
      'contactNumber': '0719876543',
      'description': 'Height 5ft 8in, last seen near Ja-Ela evacuation shelter center.',
      'avatarBgHex': '#FFC8E6C9',
      'avatarColorHex': '#FF2E7D32',
    },
    {
      'name': 'Dilhani Fernando',
      'gender': 'Female',
      'age': '22',
      'lastSeenLocation': 'Kandy • May 10, 2024',
      'contactNumber': '0765551234',
      'description': 'Student, carrying red backpack, last seen near Peradeniya flood shelter.',
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

  // Phone Call Launcher Helper
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
    final String? imageUrl = person['imageUrl'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => CircleAvatar(
                              radius: 30,
                              backgroundColor: avatarBg,
                              child: Text(initial, style: TextStyle(color: avatarColor, fontSize: 24, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 30,
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
                          '${person['gender'] ?? "N/A"} • Age: ${person['age'] ?? "N/A"}',
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
                'Last Seen Location & Date',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                person['lastSeenLocation'] ?? person['lastSeen'] ?? 'Not specified',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              Text(
                'Identification Details',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                person['description'] ?? person['details'] ?? 'No additional details provided.',
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  final String contactNum = person['contactNumber'] ?? person['contact'] ?? '';
                  if (contactNum.isNotEmpty) {
                    _makePhoneCall(contactNum);
                  }
                },
                icon: const Icon(Icons.phone, size: 18, color: Colors.white),
                label: Text(
                  'Contact Family / Finder (${person['contactNumber'] ?? person['contact'] ?? "N/A"})',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
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
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: GoogleFonts.poppins(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by name or location...',
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

          // Persons List StreamBuilder
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

                if (docs.isEmpty) {
                  _seedInitialData();
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.emergencyRed),
                  );
                }

                // Filter by name or last seen location
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final location = (data['lastSeenLocation'] ?? data['lastSeen'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || location.contains(_searchQuery);
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
                    final String? imageUrl = person['imageUrl'];

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
                            imageUrl != null && imageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Image.network(
                                      imageUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                        radius: 24,
                                        backgroundColor: avatarBg,
                                        child: Text(initial, style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
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
                                    '${person['gender'] ?? "N/A"} • Age: ${person['age'] ?? "N/A"}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Last seen: ${person['lastSeenLocation'] ?? person['lastSeen'] ?? "Unknown"}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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

          // Bottom Action Button to navigate to AddMissingPersonScreen (Fixed const issue here)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMissingPersonScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Report Missing Person (with Photo)',
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