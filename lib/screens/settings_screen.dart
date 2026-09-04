import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // General Section
          Text(
            'General',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            _buildSettingsRow(
              icon: Icons.language_rounded,
              title: 'Language',
              trailingText: 'English',
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.brightness_6_rounded,
              title: 'Theme',
              trailingText: 'Light',
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.notifications_active_outlined,
              title: 'Notification Settings',
              onTap: () {},
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          // Account & Legal Section
          Text(
            'Account',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildSettingsGroup([
            _buildSettingsRow(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.info_outline_rounded,
              title: 'About Resq App',
              trailingText: 'v1.0.0',
              onTap: () {},
              showDivider: false,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    String? trailingText,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primaryNavy, size: 22),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingText != null)
                Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 56, endIndent: 16, color: AppColors.divider),
      ],
    );
  }
}
