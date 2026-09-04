import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'syncing_state_screen.dart';

class OfflineStateScreen extends StatefulWidget {
  const OfflineStateScreen({super.key});

  @override
  State<OfflineStateScreen> createState() => _OfflineStateScreenState();
}

class _OfflineStateScreenState extends State<OfflineStateScreen> {
  bool _isReconnecting = false;

  void _reconnect() {
    setState(() => _isReconnecting = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _isReconnecting = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SyncingStateScreen()),
      );
    });
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Red Offline Wifi Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.emergencyRedLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.emergencyRed,
                  size: 52,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'You are Offline',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Some features may not be available.\nLocal disaster data is cached.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 2),

              // Queued Offline Data Boxes
              _buildOfflineRow(
                icon: Icons.save_alt_rounded,
                title: 'Saved Reports',
                count: '3',
              ),
              const SizedBox(height: 12),
              _buildOfflineRow(
                icon: Icons.sync_problem_rounded,
                title: 'Pending Sync',
                count: '2',
              ),

              const Spacer(flex: 3),

              // Red Go Online Action
              ElevatedButton(
                onPressed: _isReconnecting ? null : _reconnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isReconnecting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Go Online',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineRow({
    required IconData icon,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryNavy, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }
}
