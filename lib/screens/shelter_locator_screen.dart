import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

  final List<Map<String, dynamic>> _shelters = [
    {
      'name': 'Safe Haven Shelter',
      'distance': '1.2 km away',
      'availableBeds': 45,
      'totalBeds': 100,
      'address': 'Community Hall, Colombo 03',
      'facilities': ['Food Supplies', 'Medical Aid', 'Clean Water', 'Child Care'],
      'color': Color(0xFF2E7D32),
      'lat': 6.9147,
      'lng': 79.8489,
    },
    {
      'name': 'Unity Shelter Center',
      'distance': '2.7 km away',
      'availableBeds': 32,
      'totalBeds': 80,
      'address': 'St. Joseph Sports Complex, Colombo 10',
      'facilities': ['Food Supplies', 'Clean Water', 'Blankets'],
      'color': Color(0xFF1E88E5),
      'lat': 6.9180,
      'lng': 79.8650,
    },
    {
      'name': 'Hope Shelter',
      'distance': '4.1 km away',
      'availableBeds': 18,
      'totalBeds': 50,
      'address': 'Public Library Hall, Wellawatte',
      'facilities': ['First Aid', 'Dry Rations', 'Security'],
      'color': Color(0xFFFB8C00),
      'lat': 6.8747,
      'lng': 79.8590,
    },
    {
      'name': 'Relief Shelter Home',
      'distance': '5.3 km away',
      'availableBeds': 60,
      'totalBeds': 150,
      'address': 'Mahanama College Auditorium, Colombo 07',
      'facilities': ['Food Supplies', 'Medical Unit', 'Backup Power', 'Beds'],
      'color': Color(0xFF2E7D32),
      'lat': 6.9010,
      'lng': 79.8670,
    },
  ];

  List<Map<String, dynamic>> get _filteredShelters {
    if (_searchQuery.isEmpty) return _shelters;
    return _shelters
        .where((s) =>
            (s['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (s['address'] as String).toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
        final facilities = shelter['facilities'] as List<String>;
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
                          shelter['name'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          shelter['address'] as String,
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
                      '${shelter['availableBeds']} Beds Free',
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
                      f,
                      style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textPrimary),
                    ),
                    avatar: const Icon(Icons.check_circle_outline, size: 16, color: AppColors.infoGreen),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Navigating to ${shelter['name']} (${shelter['distance']})',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.directions_rounded, color: Colors.white, size: 20),
                label: Text(
                  'Get Directions (${shelter['distance']})',
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
      body: Column(
        children: [
          // Search Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: TextField(
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
          ),
          const Divider(height: 1, color: AppColors.border),

          // Map View or List View
          Expanded(
            child: _showMap ? _buildMapView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(6.9147, 79.8600), // Colombo center
        initialZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.resq.resq',
        ),
        MarkerLayer(
          markers: _filteredShelters.map((shelter) {
            return Marker(
              point: LatLng(shelter['lat'] as double, shelter['lng'] as double),
              width: 44,
              height: 44,
              child: GestureDetector(
                onTap: () => _showShelterDetails(shelter),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: shelter['color'] as Color, width: 2),
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
                    color: shelter['color'] as Color,
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

  Widget _buildListView() {
    return _filteredShelters.isEmpty
        ? Center(
            child: Text(
              'No shelters found matching search',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          )
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: _filteredShelters.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shelter = _filteredShelters[index];
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
                    shelter['name'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    shelter['distance'] as String,
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
                          text: '${shelter['availableBeds']}',
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
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
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
}