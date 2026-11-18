
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../services/language_provider.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final Map<String, String> _languages = const {
    'en': 'English',
    'si': 'සිංහල (Sinhala)',
    'ta': 'தமிழ் (Tamil)',
  };

  void _showLanguageSelector(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Language',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 12),
              ..._languages.entries.map((entry) {
                final isSelected =
                    languageProvider.currentLanguage == entry.key;

                return ListTile(
                  title: Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.emergencyRed
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emergencyRed,
                        )
                      : null,
                  onTap: () {
                    languageProvider.changeLanguage(entry.key);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _clearOfflineCache(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Clear Offline Cache?',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'This will remove data that has already been synchronized. '
            'Pending offline SOS requests will not be deleted.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergencyRed,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Clear',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    try {
      await LocalStorageService.clearSyncedData();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Offline cache cleared successfully.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.infoGreen,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear offline cache.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lang.getText('settings'),
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
          Text(
            lang.getText('general'),
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
              title: lang.getText('language'),
              trailingText:
                  _languages[lang.currentLanguage]?.split(' ').first,
              onTap: () => _showLanguageSelector(context),
            ),
            _buildSettingsRow(
              icon: Icons.brightness_6_rounded,
              title: lang.getText('theme'),
              trailingText: 'Light',
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.notifications_active_outlined,
              title: lang.getText('notifications'),
              onTap: () {},
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          // Pair 4: Offline Storage
          Text(
            'Offline & Storage',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          _buildSettingsGroup([
            _buildSettingsRow(
              icon: Icons.delete_sweep_outlined,
              title: 'Clear Offline Cache',
              trailingText: 'Synced data',
              onTap: () => _clearOfflineCache(context),
              showDivider: false,
            ),
          ]),

          const SizedBox(height: 24),

          Text(
            lang.getText('account'),
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
              title: lang.getText('privacy'),
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.description_outlined,
              title: lang.getText('terms'),
              onTap: () {},
            ),
            _buildSettingsRow(
              icon: Icons.info_outline_rounded,
              title: lang.getText('about'),
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
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      clipBehavior: Clip.antiAlias,
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
          leading: Icon(
            icon,
            color: AppColors.primaryNavy,
            size: 22,
          ),
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
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textLight,
              ),
            ],
          ),
          onTap: onTap,
        ),
        if (showDivider)
          const Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: AppColors.divider,
          ),
      ],
    );
  }
}
