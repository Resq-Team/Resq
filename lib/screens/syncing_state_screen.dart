import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import 'main_navigation_screen.dart';

class SyncingStateScreen extends StatefulWidget {
  const SyncingStateScreen({super.key});

  @override
  State<SyncingStateScreen> createState() => _SyncingStateScreenState();
}

class _SyncingStateScreenState extends State<SyncingStateScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _syncController;
  late Animation<double> _syncAnimation;

  @override
  void initState() {
    super.initState();
    _syncController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _syncAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _syncController, curve: Curves.easeInOut),
    );

    _syncController.forward();

    _syncController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Timer(const Duration(milliseconds: 400), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Data sync completed! All reports are up-to-date.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: AppColors.infoGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _syncController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Cloud Sync Animated Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.cloud_sync_rounded,
                    color: Color(0xFF1E88E5),
                    size: 64,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                'Syncing Data',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please wait while we\nsync your data...',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              // Progress Bar & Percentage
              AnimatedBuilder(
                animation: _syncAnimation,
                builder: (context, child) {
                  final percent = (_syncAnimation.value * 100).toInt();
                  return Column(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _syncAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$percent%',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
