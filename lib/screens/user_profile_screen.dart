import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'settings_screen.dart';
import 'offline_state_screen.dart';
import 'syncing_state_screen.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final bool showBackButton;

  const UserProfileScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isDarkMode = false;
  final AuthService _authService = AuthService();

  // Holds the user's profile info fetched from Firestore
  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  // Convenience getters that fall back gracefully if data isn't loaded yet
  String get _displayName =>
      _userProfile?['name'] ?? _authService.currentUser?.displayName ?? 'Guest User';

  String get _displayEmail =>
      _userProfile?['email'] ?? _authService.currentUser?.email ?? 'No email';

  String get _displayRole =>
      _userProfile?['role'] ?? 'citizen';

  String get _avatarLetter =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _displayName);
    final phoneCtrl = TextEditingController(text: _userProfile?['phone'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Profile',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: const InputDecoration(labelText: 'Phone Number'),
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Profile information updated.', style: GoogleFonts.poppins(fontSize: 12)),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Save', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
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
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoadingProfile
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // User Header Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.emergencyRedLight,
                          child: Text(
                            _avatarLetter,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.emergencyRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.emergencyRedLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _displayRole == 'citizen'
                                      ? 'Disaster Victim / Citizen'
                                      : _displayRole,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emergencyRed,
                                  ),
                                ),
                              ),
                              Text(
                                _displayEmail,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (_userProfile?['phone'] != null)
                                Text(
                                  _userProfile!['phone'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Options
                  _buildActionTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    onTap: _showEditProfileDialog,
                  ),
                  _buildActionTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Push notifications are active for high severity alerts.', style: GoogleFonts.poppins(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.palette_outlined,
                    title: 'Theme',
                    trailing: Text(
                      _isDarkMode ? 'Dark' : 'Light',
                      style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    onTap: () {
                      setState(() => _isDarkMode = !_isDarkMode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Theme switched to ${_isDarkMode ? "Dark" : "Light"} mode', style: GoogleFonts.poppins(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Password change verification code sent to your mobile.', style: GoogleFonts.poppins(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Demo Navigation to Offline & Sync States
                  _buildActionTile(
                    icon: Icons.wifi_off_rounded,
                    title: 'Offline State Demo',
                    iconColor: AppColors.emergencyRed,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflineStateScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.sync_rounded,
                    title: 'Data Sync State Demo',
                    iconColor: const Color(0xFF1E88E5),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SyncingStateScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // Logout
                  _buildActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: AppColors.emergencyRed,
                    textColor: AppColors.emergencyRed,
                    onTap: () async {
                      await _authService.logout();
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color iconColor = AppColors.primaryNavy,
    Color textColor = AppColors.textPrimary,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 22),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
