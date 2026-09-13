import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../widgets/pulse_sos_button.dart';
import '../services/language_provider.dart';
import 'sos_emergency_screen.dart';
import 'package:resq/screens/disaster_report_screen.dart';
import 'disaster_alerts_screen.dart';
import 'emergency_contacts_screen.dart';
import 'feedback_screen.dart';
import 'shelter_locator_screen.dart';
import 'volunteer_dashboard_screen.dart';
import 'donations_screen.dart';
import 'relief_resources_screen.dart';
import 'missing_persons_screen.dart';
import 'admin_sos_dashboard_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateTab,
  });

  // Gets the logged-in user's display name, with a graceful fallback
  String _getUserFirstName() {
    final user = FirebaseAuth.instance.currentUser;
    final fullName = user?.displayName;
    if (fullName == null || fullName.isEmpty) return 'Guest';
    // Show only the first name for a cleaner greeting
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    // LanguageProvider එක Listen කිරීම (භාෂාව වෙනස් වූ පසු Auto Refresh වේ)
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Greeting Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${lang.getText('hello')}, ${_getUserFirstName()}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lang.getText('stay_safe'),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification Bell with badge
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.primaryNavy,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DisasterAlertsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.emergencyRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hero Circular SOS Button
              Center(
                child: Column(
                  children: [
                    PulseSosButton(
                      size: 110,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SosEmergencyScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lang.getText('emergency_sos'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Grid (10 Cards)
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
                children: [
                  // 1. Disaster Report
                  _buildGridAction(
                    icon: Icons.assignment_late_outlined,
                    iconColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFEBEE),
                    label: lang.getText('disaster_report'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisasterReportScreen(),
                        ),
                      );
                    },
                  ),

                  // 2. Shelter Locator
                  _buildGridAction(
                    icon: Icons.location_city_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    label: lang.getText('shelter_locator'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShelterLocatorScreen(),
                        ),
                      );
                    },
                  ),

                  // 3. Alerts
                  _buildGridAction(
                    icon: Icons.crisis_alert_rounded,
                    iconColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFEBEE),
                    label: lang.getText('alerts'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DisasterAlertsScreen(),
                        ),
                      );
                    },
                  ),

                  // 4. Volunteers
                  _buildGridAction(
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF1E88E5),
                    bgColor: const Color(0xFFE3F2FD),
                    label: lang.getText('volunteers'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VolunteerDashboardScreen(),
                        ),
                      );
                    },
                  ),

                  // 5. Donations
                  _buildGridAction(
                    icon: Icons.volunteer_activism_rounded,
                    iconColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFEBEE),
                    label: lang.getText('donations'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationsScreen(),
                        ),
                      );
                    },
                  ),

                  // 6. Resources
                  _buildGridAction(
                    icon: Icons.inventory_2_outlined,
                    iconColor: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    label: lang.getText('resources'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReliefResourcesScreen(),
                        ),
                      );
                    },
                  ),

                  // 7. Missing Persons
                  _buildGridAction(
                    icon: Icons.person_search_rounded,
                    iconColor: const Color(0xFFE53935),
                    bgColor: const Color(0xFFFFEBEE),
                    label: lang.getText('missing_persons'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MissingPersonsScreen(),
                        ),
                      );
                    },
                  ),

                  // 8. Emergency Contacts
                  _buildGridAction(
                    icon: Icons.phone_in_talk_rounded,
                    iconColor: const Color(0xFF0F1E36),
                    bgColor: const Color(0xFFE2E8F0),
                    label: lang.getText('emergency_contacts'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmergencyContactsScreen(),
                        ),
                      );
                    },
                  ),

                  // 9. Feedback
                  _buildGridAction(
                    icon: Icons.rate_review_outlined,
                    iconColor: const Color(0xFFFB8C00),
                    bgColor: const Color(0xFFFFF3E0),
                    label: lang.getText('feedback'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedbackScreen(),
                        ),
                      );
                    },
                  ),

                  // 10. Admin SOS Dashboard
                  _buildGridAction(
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: const Color(0xFFD32F2F),
                    bgColor: const Color(0xFFFFEBEE),
                    label: lang.getText('admin_sos'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminSosDashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridAction({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.025),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}