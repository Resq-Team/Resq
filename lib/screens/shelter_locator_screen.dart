import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';

class ShelterLocatorScreen extends StatefulWidget {
  const ShelterLocatorScreen({super.key});

  @override
  State<ShelterLocatorScreen> createState() => _ShelterLocatorScreenState();
}

class _ShelterLocatorScreenState extends State<ShelterLocatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMap = false; // Toggle between List view and Map view
  String _selectedFacilityFilter = 'All';

  final List<String> _filterCategoryList = [
    'All',
    'Food Supplies',
    'Medical Aid',
    'Clean Water',
    'Child Care',
    'Blankets',
  ];

  // External Map App එක හරහා Google Maps Navigation Open කිරීමට
  Future<void> _openMapDirections(double lat, double lng, String label) async {
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map application.', style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error launching maps: $e', style: GoogleFonts.poppins(fontSize: 12)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Direct Phone Call එකක් ලබා දීමට
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showShelterDetails(Map<String, dynamic> shelter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final List<dynamic> facilities = shelter['facilities'] ?? [];
        final String contactNo = shelter['contact'] ?? '119';

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shelter['name'] ?? 'Shelter',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          shelter['address'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${shelter['availableBeds'] ?? 0} Beds Free',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.infoGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              Text(
                'Available Camp Amenities',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: facilities.map((f) {
                  return Chip(
                    backgroundColor: const Color(0xFFF1F5F9),
                    side: const BorderSide(color: AppColors.border),
                    label: Text(
                      f.toString(),
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary),
                    ),
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: AppColors.infoGreen),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Hotline Call Button
                  IconButton.filled(
                    onPressed: () => _makePhoneCall(contactNo),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFDCFCE7),
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: const Icon(Icons.phone_rounded, color: AppColors.infoGreen),
                  ),
                  const SizedBox(width: 12),
                  // Directions Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        final double lat = (shelter['lat'] as num).toDouble();
                        final double lng = (shelter['lng'] as num).toDouble();
                        _openMapDirections(lat, lng, shelter['name'] ?? '');
                      },
                      icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'Get Directions (${shelter['distance'] ?? 'Near'})',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emergencyRed,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Filter shelters according to search text & selected chip
  List<Map<String, dynamic>> _filterShelterList(List<Map<String, dynamic>> rawShelters) {
    return rawShelters.where((s) {
      final nameMatches = (s['name'] as String? ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final addressMatches = (s['address'] as String? ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesQuery = nameMatches || addressMatches;

      if (_selectedFacilityFilter == 'All') {
        return matchesQuery;
      } else {
        final List<dynamic> facilities = s['facilities'] ?? [];
        final hasFacility = facilities.contains(_selectedFacilityFilter);
        return matchesQuery && hasFacility;
      }
    }).toList();
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
          'Nearby Shelters',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _showMap ? Icons.list_rounded : Icons.map_rounded,
              color: Colors.white,
            ),
            tooltip: _showMap ? 'Show List' : 'Show Map',
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('shelters').snapshots(),
        builder: (context, snapshot) {
          // If Firestore is still loading or doesn't have data, we fallback gracefully or show indicator
          List<Map<String, dynamic>> loadedShelters = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            loadedShelters = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            }).toList();
          } else {
            // Fallback default shelters list when Firestore data is empty
            loadedShelters = _fallbackShelters;
          }

          final filteredShelters = _filterShelterList(loadedShelters);

          return Column(
            children: [
              // Search & Facility Filter Header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search shelters by name or location...',
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
                    const SizedBox(height: 10),
                    // Filter Chips Bar
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filterCategoryList.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final facility = _filterCategoryList[index];
                          final isSelected = _selectedFacilityFilter == facility;
                          return ChoiceChip(
                            label: Text(
                              facility,
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryNavy,
                            backgroundColor: const Color(0xFFF1F5F9),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedFacilityFilter = facility);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // Map View or List View
              Expanded(
                child: _showMap
                    ? _buildMapView(filteredShelters)
                    : _buildListView(filteredShelters),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<Map<String, dynamic>> shelters) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(6.9147, 79.8600), // Colombo center
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.resq.resq',
        ),
        MarkerLayer(
          markers: shelters.map((shelter) {
            final double lat = (shelter['lat'] as num).toDouble();
            final double lng = (shelter['lng'] as num).toDouble();
            final int availableBeds = shelter['availableBeds'] ?? 0;
            final Color markerColor = availableBeds > 20
                ? const Color(0xFF2E7D32)
                : (availableBeds > 0 ? const Color(0xFFFB8C00) : Colors.redAccent);

            return Marker(
              point: LatLng(lat, lng),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _showShelterDetails(shelter),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: markerColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: markerColor,
                    size: 22,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> shelters) {
    return shelters.isEmpty
        ? Center(
            child: Text(
              'No shelters found matching criteria',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: shelters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shelter = shelters[index];
              return _buildShelterCard(shelter);
            },
          );
  }

  Widget _buildShelterCard(Map<String, dynamic> shelter) {
    return GestureDetector(
      onTap: () => _showShelterDetails(shelter),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Home/Shelter Icon Box
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: AppColors.infoGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Shelter Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shelter['name'] ?? 'Shelter',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shelter['distance'] ?? 'Nearby',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Available Beds: ',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextSpan(
                          text: '${shelter['availableBeds'] ?? 0}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.infoGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Arrow Button
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.navigation_rounded,
                color: Color(0xFF1E88E5),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fallback static data if database connection is pending
  static final List<Map<String, dynamic>> _fallbackShelters = [
    {
      'name': 'Safe Haven Shelter',
      'distance': '1.2 km away',
      'availableBeds': 45,
      'totalBeds': 100,
      'address': 'Community Hall, Colombo 03',
      'facilities': ['Food Supplies', 'Medical Aid', 'Clean Water', 'Child Care'],
      'lat': 6.9147,
      'lng': 79.8489,
      'contact': '0112345678',
    },
    {
      'name': 'Unity Shelter Center',
      'distance': '2.7 km away',
      'availableBeds': 32,
      'totalBeds': 80,
      'address': 'St. Joseph Sports Complex, Colombo 10',
      'facilities': ['Food Supplies', 'Clean Water', 'Blankets'],
      'lat': 6.9180,
      'lng': 79.8650,
      'contact': '0112987654',
    },
    {
      'name': 'Hope Shelter',
      'distance': '4.1 km away',
      'availableBeds': 18,
      'totalBeds': 50,
      'address': 'Public Library Hall, Wellawatte',
      'facilities': ['Medical Aid', 'Clean Water'],
      'lat': 6.8747,
      'lng': 79.8590,
      'contact': '0112111222',
    },
    {
      'name': 'Relief Shelter Home',
      'distance': '5.3 km away',
      'availableBeds': 60,
      'totalBeds': 150,
      'address': 'Mahanama College Auditorium, Colombo 07',
      'facilities': ['Food Supplies', 'Medical Aid', 'Blankets'],
      'lat': 6.9010,
      'lng': 79.8670,
      'contact': '0112555666',
    },
  ];
}