import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../services/language_provider.dart';
import '../services/theme_provider.dart';
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
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Map _userProfile = {};
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      final profile = await _authService.getUserProfile(user.uid);
      if (mounted) {
        setState(() {
          _userProfile = profile is Map ? profile : {};
          _isLoadingProfile = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoadingProfile = false);
    }
  }

  String get _displayName =>
      _userProfile['name']?.toString() ??
      _authService.currentUser?.displayName ??
      'Guest User';

  String get _displayEmail =>
      _userProfile['email']?.toString() ??
      _authService.currentUser?.email ??
      'No email';

  String get _displayRole =>
      _userProfile['role']?.toString() ?? 'citizen';

  String? get _profileImageUrl =>
      _userProfile['profileImageUrl']?.toString() ??
      _authService.currentUser?.photoURL;

  String get _avatarLetter =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?';

  Future _pickProfileImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile == null) return null;

    if (kIsWeb) {
      return await pickedFile.readAsBytes();
    } else {
      return File(pickedFile.path);
    }
  }

  Widget _buildDialogAvatar(dynamic pickedImage) {
    if (pickedImage != null) {
      if (kIsWeb) {
        return CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.emergencyRedLight,
          backgroundImage: MemoryImage(pickedImage as Uint8List),
        );
      } else {
        return CircleAvatar(
          radius: 42,
          backgroundColor: AppColors.emergencyRedLight,
          backgroundImage: FileImage(pickedImage as File),
        );
      }
    }

    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 42,
        backgroundColor: AppColors.emergencyRedLight,
        backgroundImage: NetworkImage(_profileImageUrl!),
      );
    }

    return CircleAvatar(
      radius: 42,
      backgroundColor: AppColors.emergencyRedLight,
      child: Text(
        _avatarLetter,
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.emergencyRed,
        ),
      ),
    );
  }

  void _showEditProfileDialog(LanguageProvider lang) {
    final user = _authService.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(
      text: _displayName == 'Guest User' ? '' : _displayName,
    );
    final phoneCtrl = TextEditingController(
      text: _userProfile['phone']?.toString() ?? '',
    );
    dynamic pickedImage;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: !isSaving,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future selectSource(ImageSource source) async {
              final img = await _pickProfileImage(source);
              if (img != null) {
                setDialogState(() => pickedImage = img);
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                lang.getText('edit_profile'),
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        _buildDialogAvatar(pickedImage),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: PopupMenuButton(
                            enabled: !isSaving,
                            onSelected: (val) {
                              if (val is ImageSource) {
                                selectSource(val);
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: ImageSource.gallery,
                                child: Row(
                                  children: [
                                    const Icon(Icons.photo_library_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Gallery', style: GoogleFonts.poppins(fontSize: 12)),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: ImageSource.camera,
                                child: Row(
                                  children: [
                                    const Icon(Icons.camera_alt_rounded, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Camera', style: GoogleFonts.poppins(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      enabled: !isSaving,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: lang.getText('full_name'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneCtrl,
                      enabled: !isSaving,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: lang.getText('phone_number'),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: Text(
                    lang.getText('cancel'),
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final updatedName = nameCtrl.text.trim();
                          final updatedPhone = phoneCtrl.text.trim();

                          if (updatedName.isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please enter your name.',
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                backgroundColor: AppColors.emergencyRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSaving = true);

                          try {
                            final result = await _authService.updateUserProfile(
                              uid: user.uid,
                              name: updatedName,
                              phone: updatedPhone,
                              newProfileImageFile: pickedImage,
                              existingImageUrl: _profileImageUrl,
                            );

                            if (!mounted) return;
                            setState(() {
                              _userProfile = {
                                ..._userProfile,
                                'name': result['name'],
                                'phone': result['phone'],
                                'profileImageUrl': result['profileImageUrl'],
                              };
                            });

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  lang.getText('profile_updated_msg'),
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceAll('Exception: ', ''),
                                  style: GoogleFonts.poppins(fontSize: 12),
                                ),
                                backgroundColor: AppColors.emergencyRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          lang.getText('save'),
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    // Dark Mode සහ Light Mode සඳහා Dynamic Colors
    final bgColor = isDark ? const Color(0xFF121212) : AppColors.background;
    final cardBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white12 : AppColors.border;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : AppColors.primaryNavy,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          lang.getText('my_profile'),
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
                      color: cardBgColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                              ? Image.network(
                                  _profileImageUrl!,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 64,
                                      height: 64,
                                      color: AppColors.emergencyRedLight,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.emergencyRed,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
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
                                )
                              : CircleAvatar(
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
                                  color: primaryTextColor,
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
                                      ? lang.getText('citizen_role')
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
                                  color: secondaryTextColor,
                                ),
                              ),
                              if (_userProfile['phone'] != null &&
                                  _userProfile['phone'].toString().isNotEmpty)
                                Text(
                                  _userProfile['phone'].toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: isDark ? Colors.white54 : AppColors.textLight,
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
                    title: lang.getText('edit_profile'),
                    isDark: isDark,
                    onTap: () => _showEditProfileDialog(lang),
                  ),
                  _buildActionTile(
                    icon: Icons.notifications_none_rounded,
                    title: lang.getText('notifications'),
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.getText('notifications_msg'), style: GoogleFonts.poppins(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.palette_outlined,
                    title: lang.getText('theme'),
                    isDark: isDark,
                    trailing: Text(
                      isDark ? lang.getText('dark') : lang.getText('light'),
                      style: GoogleFonts.poppins(fontSize: 12, color: secondaryTextColor),
                    ),
                    onTap: () {
                      final nextDark = !isDark;
                      themeProvider.toggleTheme(nextDark);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${lang.getText('theme_switched_msg')} ${nextDark ? lang.getText('dark') : lang.getText('light')}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.lock_outline_rounded,
                    title: lang.getText('change_password'),
                    isDark: isDark,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(lang.getText('change_password_msg'), style: GoogleFonts.poppins(fontSize: 12)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.settings_outlined,
                    title: lang.getText('settings'),
                    isDark: isDark,
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
                    title: lang.getText('offline_demo'),
                    iconColor: AppColors.emergencyRed,
                    isDark: isDark,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const OfflineStateScreen()),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.sync_rounded,
                    title: lang.getText('sync_demo'),
                    iconColor: const Color(0xFF1E88E5),
                    isDark: isDark,
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
                    title: lang.getText('logout'),
                    iconColor: AppColors.emergencyRed,
                    textColor: AppColors.emergencyRed,
                    isDark: isDark,
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
    required bool isDark,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final effectiveIconColor = iconColor ?? (isDark ? Colors.white70 : AppColors.primaryNavy);
    final effectiveTextColor = textColor ?? (isDark ? Colors.white : AppColors.textPrimary);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white12 : AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: effectiveIconColor, size: 22),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: effectiveTextColor,
          ),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white38 : AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}