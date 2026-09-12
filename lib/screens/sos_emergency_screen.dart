import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../widgets/pulse_sos_button.dart';
import '../services/sos_service.dart';

class SosEmergencyScreen extends StatefulWidget {
  const SosEmergencyScreen({super.key});

  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen> {
  final SosService _sosService = SosService();
  bool _isSending = false;

  void _triggerSos() {
    int countdown = 5;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (countdown > 1) {
                setDialogState(() {
                  countdown--;
                });
              } else {
                t.cancel();
                Navigator.pop(dialogCtx);
                _sendSosToFirestore();
              }
            });

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.emergencyRedLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: AppColors.emergencyRed,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Broadcasting SOS Alert!',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dispatching distress signal & GPS location to nearby disaster teams in:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$countdown',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: AppColors.emergencyRed,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              timer?.cancel();
                              Navigator.pop(dialogCtx);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              side: const BorderSide(color: AppColors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              timer?.cancel();
                              Navigator.pop(dialogCtx);
                              _sendSosToFirestore();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emergencyRed,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Send Now',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Sends the SOS alert to Firestore, then shows the result modal
  Future<void> _sendSosToFirestore() async {
    setState(() => _isSending = true);

    try {
      // TODO: Replace with real GPS coordinates using geolocator package
      // For now using dummy Colombo coordinates
      await _sosService.sendSosAlert(
        latitude: 6.9271,
        longitude: 79.8612,
        userName: 'ResQ User', // Replace with actual logged-in user name
        message: 'Emergency! Immediate help needed.',
      );

      if (mounted) {
        _showSosDispatchedModal(success: true);
      }
    } catch (e) {
      if (mounted) {
        _showSosDispatchedModal(success: false, errorMessage: e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _showSosDispatchedModal({bool success = true, String? errorMessage}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: success ? const Color(0xFFDCFCE7) : AppColors.emergencyRedLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: success ? AppColors.infoGreen : AppColors.emergencyRed,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                success ? 'SOS Alert Dispatched!' : 'Failed to Send SOS',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                success
                    ? 'Rescue Team Alpha (2.4 km away) and Emergency Management have received your coordinates. Stay calm in your current location.'
                    : 'Could not reach the server. Please check your internet connection and try again.\n${errorMessage ?? ''}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? AppColors.primaryNavy : AppColors.emergencyRed,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  success ? 'Dismiss' : 'Try Again',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
      body: Column(
        children: [
          // Red Header with back button
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration: const BoxDecoration(
              color: AppColors.emergencyRed,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Emergency SOS',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance back button
              ],
            ),
          ),

          // Main Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  // Instruction label
                  Text(
                    'Tap the button in case\nof an emergency',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),

                  // Giant Glowing Pulsing SOS Button
                  Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              strokeWidth: 6,
                              color: AppColors.emergencyRed,
                            ),
                          )
                        : PulseSosButton(
                            size: 160,
                            onTap: _triggerSos,
                          ),
                  ),

                  const Spacer(),

                  // Location Display Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.emergencyRedLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.emergencyRed,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Location',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '123 Main Street, Colombo, Sri Lanka',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.gps_fixed_rounded,
                          color: AppColors.emergencyRed.withOpacity(0.8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Red "Send SOS" Button
                  ElevatedButton(
                    onPressed: _isSending ? null : _triggerSos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emergencyRed,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.emergencyRed.withOpacity(0.4),
                    ),
                    child: Text(
                      'Send SOS',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
