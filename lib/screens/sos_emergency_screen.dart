import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_colors.dart';
import '../widgets/pulse_sos_button.dart';
import '../models/offline_data.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';

class SosEmergencyScreen extends StatefulWidget {
  const SosEmergencyScreen({super.key});

  @override
  State<SosEmergencyScreen> createState() => _SosEmergencyScreenState();
}

class _SosEmergencyScreenState extends State<SosEmergencyScreen> {
  bool _isSending = false;
  bool _isGettingLocation = true;

  String _locationText = 'Getting your location...';

  double? _latitude;
  double? _longitude;

  final ConnectivityService _connectivityService =
      ConnectivityService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ============================================================
  // GET REAL DEVICE GPS LOCATION
  // ============================================================

  Future<Position?> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isGettingLocation = true;
        _locationText = 'Getting your location...';
      });
    }

    try {
      // Check whether location services are enabled.
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _locationText = 'Location service is turned off';
          });
        }

        return null;
      }

      // Check permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Ask for permission if needed.
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // User permanently denied location.
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _locationText = 'Location permission denied';
          });
        }

        return null;
      }

      // User denied permission.
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isGettingLocation = false;
            _locationText = 'Location permission denied';
          });
        }

        return null;
      }

      // Get REAL GPS position.
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      if (mounted) {
        setState(() {
          _isGettingLocation = false;

          _locationText =
              '${position.latitude.toStringAsFixed(6)}, '
              '${position.longitude.toStringAsFixed(6)}';
        });
      }

      debugPrint(
        'REAL GPS LOCATION: '
        '${position.latitude}, ${position.longitude}',
      );

      return position;
    } catch (e) {
      debugPrint('Location error: $e');

      // Try last known location as a fallback.
      try {
        final Position? lastPosition =
            await Geolocator.getLastKnownPosition();

        if (lastPosition != null) {
          _latitude = lastPosition.latitude;
          _longitude = lastPosition.longitude;

          if (mounted) {
            setState(() {
              _isGettingLocation = false;

              _locationText =
                  '${lastPosition.latitude.toStringAsFixed(6)}, '
                  '${lastPosition.longitude.toStringAsFixed(6)}';
            });
          }

          debugPrint(
            'Using last known GPS location: '
            '${lastPosition.latitude}, '
            '${lastPosition.longitude}',
          );

          return lastPosition;
        }
      } catch (fallbackError) {
        debugPrint(
          'Last known location error: $fallbackError',
        );
      }

      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _locationText = 'Unable to get GPS location';
        });
      }

      return null;
    }
  }

  // ============================================================
  // SAVE SOS LOCALLY AND SYNC IF INTERNET IS AVAILABLE
  // ============================================================

  Future<bool> _saveAndSyncSos() async {
    /*
     * Get a fresh GPS location when SOS is actually sent.
     *
     * This is important because the user may have moved
     * after opening the SOS screen.
     */
    final Position? position = await _getCurrentLocation();

    final sosId =
        'SOS_${DateTime.now().millisecondsSinceEpoch}';

    final sosData = OfflineData(
      id: sosId,
      type: 'sos',
      data: {
        // REAL GPS LOCATION
        'latitude': position?.latitude ?? _latitude,
        'longitude': position?.longitude ?? _longitude,

        'locationAvailable': position != null ||
            (_latitude != null && _longitude != null),

        'userName': 'Anonymous',
        'userPhone': 'Not provided',
        'message': 'Emergency! Immediate help needed.',
      },
      createdAt: DateTime.now(),
      syncStatus: 'pending',
    );

    // ==========================================================
    // STEP 1: ALWAYS SAVE LOCALLY
    // ==========================================================

    await LocalStorageService.saveOfflineData(sosData);

    debugPrint(
      'SOS saved locally: $sosId',
    );

    debugPrint(
      'SOS GPS: '
      '${position?.latitude ?? _latitude}, '
      '${position?.longitude ?? _longitude}',
    );

    // ==========================================================
    // STEP 2: CHECK INTERNET
    // ==========================================================

    final bool isOnline =
        await _connectivityService.isOnline();

    // ==========================================================
    // STEP 3: OFFLINE
    // ==========================================================

    if (!isOnline) {
      debugPrint(
        'No internet connection. '
        'SOS saved locally.',
      );

      return false;
    }

    // ==========================================================
    // STEP 4: ONLINE - TRY TO SYNC
    // ==========================================================

    try {
      await SyncService.syncPendingData();

      // Check whether this SOS is still pending.
      final pending =
          LocalStorageService.getPendingData();

      final stillPending =
          pending.any((item) => item.id == sosId);

      if (stillPending) {
        debugPrint(
          'SOS could not be synchronized. '
          'Saved locally.',
        );

        return false;
      }

      debugPrint(
        'SOS synchronized successfully.',
      );

      return true;
    } catch (e) {
      debugPrint(
        'SOS synchronization failed: $e',
      );

      // It remains safely stored in Hive.
      return false;
    }
  }

  // ============================================================
  // START SOS COUNTDOWN
  // ============================================================

  void _triggerSos() {
    if (_isSending) return;

    int countdown = 5;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            timer ??= Timer.periodic(
              const Duration(seconds: 1),
              (t) async {
                if (countdown > 1) {
                  setDialogState(() {
                    countdown--;
                  });
                } else {
                  t.cancel();

                  if (Navigator.of(dialogCtx).canPop()) {
                    Navigator.of(dialogCtx).pop();
                  }

                  await _sendSos();
                }
              },
            );

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ICON
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color:
                            AppColors.emergencyRedLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: AppColors.emergencyRed,
                        size: 48,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TITLE
                    Text(
                      'Broadcasting SOS Alert!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            AppColors.emergencyRed,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DESCRIPTION
                    Text(
                      'Dispatching distress signal & GPS location to nearby disaster teams in:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color:
                            AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // COUNTDOWN
                    Text(
                      '$countdown',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color:
                            AppColors.emergencyRed,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // BUTTONS
                    Row(
                      children: [
                        // CANCEL
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              timer?.cancel();

                              if (Navigator.of(
                                dialogCtx,
                              ).canPop()) {
                                Navigator.of(
                                  dialogCtx,
                                ).pop();
                              }
                            },
                            style:
                                OutlinedButton.styleFrom(
                              foregroundColor:
                                  AppColors.textSecondary,
                              side: const BorderSide(
                                color: AppColors.border,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // SEND NOW
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              timer?.cancel();

                              if (Navigator.of(
                                dialogCtx,
                              ).canPop()) {
                                Navigator.of(
                                  dialogCtx,
                                ).pop();
                              }

                              await _sendSos();
                            },
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.emergencyRed,
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child: Text(
                              'Send Now',
                              style: GoogleFonts.poppins(
                                fontWeight:
                                    FontWeight.w600,
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

  // ============================================================
  // SEND SOS
  // ============================================================

  Future<void> _sendSos() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final bool synced =
          await _saveAndSyncSos();

      if (!mounted) return;

      if (synced) {
        _showSosDispatchedModal();
      } else {
        _showSosSavedOfflineModal();
      }
    } catch (e) {
      debugPrint('SOS error: $e');

      if (!mounted) return;

      _showSosSavedOfflineModal();
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // ============================================================
  // ONLINE SUCCESS MODAL
  // ============================================================

  void _showSosDispatchedModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.infoGreen,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'SOS Alert Dispatched!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your emergency alert has been successfully synchronized with the disaster management system.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryNavy,
                    minimumSize:
                        const Size(
                      double.infinity,
                      48,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // OFFLINE SUCCESS MODAL
  // ============================================================

  void _showSosSavedOfflineModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF4D6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.orange,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'SOS Saved Offline',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Your SOS information and GPS location have been safely saved on this device. It will be synchronized automatically when the internet connection becomes available.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color:
                        AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.emergencyRed,
                    minimumSize:
                        const Size(
                      double.infinity,
                      48,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  child: Text(
                    'Dismiss',
                    style: GoogleFonts.poppins(
                      fontWeight:
                          FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      body: Column(
        children: [
          // ======================================================
          // HEADER
          // ======================================================

          Container(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context)
                      .padding
                      .top +
                  8,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            decoration:
                const BoxDecoration(
              color:
                  AppColors.emergencyRed,
              borderRadius:
                  BorderRadius.vertical(
                bottom:
                    Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },
                  icon: const Icon(
                    Icons
                        .arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),

                Expanded(
                  child: Text(
                    'Emergency SOS',
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w700,
                      color:
                          Colors.white,
                    ),
                  ),
                ),

                const SizedBox(
                  width: 48,
                ),
              ],
            ),
          ),

          // ======================================================
          // BODY
          // ======================================================

          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 32,
                  ),

                  Text(
                    'Tap the button in case\nof an emergency',
                    textAlign:
                        TextAlign.center,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  // ==================================================
                  // SOS BUTTON
                  // ==================================================

                  Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 160,
                            height: 160,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 6,
                              color: AppColors
                                  .emergencyRed,
                            ),
                          )
                        : PulseSosButton(
                            size: 160,
                            onTap:
                                _triggerSos,
                          ),
                  ),

                  const Spacer(),

                  // ==================================================
                  // LOCATION CARD
                  // ==================================================

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.white,
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                      border: Border.all(
                        color:
                            AppColors.border,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha: 0.04,
                          ),
                          blurRadius: 10,
                          offset:
                              const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets
                                  .all(
                            10,
                          ),
                          decoration:
                              const BoxDecoration(
                            color: AppColors
                                .emergencyRedLight,
                            shape:
                                BoxShape.circle,
                          ),
                          child:
                              const Icon(
                            Icons
                                .location_on_rounded,
                            color: AppColors
                                .emergencyRed,
                            size: 24,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'Your Location',
                                style: GoogleFonts
                                    .poppins(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight
                                          .w500,
                                  color: AppColors
                                      .textSecondary,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                _isGettingLocation
                                    ? 'Getting GPS location...'
                                    : _locationText,
                                maxLines: 2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: GoogleFonts
                                    .poppins(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                  color: _locationText ==
                                          'Location permission denied' ||
                                      _locationText ==
                                          'Location service is turned off' ||
                                      _locationText ==
                                          'Unable to get GPS location'
                                      ? AppColors
                                          .emergencyRed
                                      : AppColors
                                          .textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width: 8,
                        ),

                        // GPS ICON / LOADING
                        _isGettingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                  color: AppColors
                                      .emergencyRed,
                                ),
                              )
                            : IconButton(
                                onPressed:
                                    _isSending
                                        ? null
                                        : () {
                                            _getCurrentLocation();
                                          },
                                icon:
                                    const Icon(
                                  Icons
                                      .gps_fixed_rounded,
                                  color: AppColors
                                      .emergencyRed,
                                  size: 20,
                                ),
                                tooltip:
                                    'Refresh GPS location',
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ==================================================
                  // SEND SOS BUTTON
                  // ==================================================

                  ElevatedButton(
                    onPressed:
                        _isSending
                            ? null
                            : _triggerSos,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors
                              .emergencyRed,
                      minimumSize:
                          const Size(
                        double.infinity,
                        54,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      elevation: 4,
                      shadowColor:
                          AppColors
                              .emergencyRed
                              .withValues(
                        alpha: 0.4,
                      ),
                    ),
                    child: Text(
                      'Send SOS',
                      style:
                          GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            Colors.white,
                        letterSpacing:
                            0.5,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}