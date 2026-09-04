import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'main_navigation_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  int _selectedRoleIndex = 0; // Default to Disaster Victim

  final List<Map<String, dynamic>> _roles = [
    {
      'title': 'Disaster Victim',
      'icon': Icons.person_pin_circle_rounded,
      'color': Color(0xFFE53935),
      'description': 'Need immediate rescue, food, shelter, or relief aid',
    },
    {
      'title': 'Volunteer',
      'icon': Icons.groups_rounded,
      'color': Color(0xFF1E88E5),
      'description': 'Join emergency ground operations & relief distribution',
    },
    {
      'title': 'Donor',
      'icon': Icons.volunteer_activism_rounded,
      'color': Color(0xFFE53935),
      'description': 'Contribute funds, emergency rations, and supplies',
    },
    {
      'title': 'Shelter Manager',
      'icon': Icons.night_shelter_rounded,
      'color': Color(0xFF1565C0),
      'description': 'Manage camp capacity, check-ins, and rations',
    },
    {
      'title': 'Govt. Officer',
      'icon': Icons.badge_rounded,
      'color': Color(0xFF2E7D32),
      'description': 'Coordinate state emergency response & hazard levels',
    },
    {
      'title': 'Administrator',
      'icon': Icons.admin_panel_settings_rounded,
      'color': Color(0xFF0F1E36),
      'description': 'System governance, broadcast alerts & resource allocations',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryNavy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'Select Your Role',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose how you want to help or receive aid',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Roles Grid (2 columns x 3 rows)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];
                    final isSelected = _selectedRoleIndex == index;
                    final color = role['color'] as Color;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRoleIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.06) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : AppColors.border,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? color.withOpacity(0.12)
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                role['icon'] as IconData,
                                color: color,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              role['title'] as String,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
