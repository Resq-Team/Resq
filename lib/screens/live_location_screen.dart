import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';

class LiveLocationScreen extends StatefulWidget {
  final bool showBackButton;

  const LiveLocationScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSharing = true;
  bool _isLoading = true;
  String _currentAddress = 'Fetching current address...';

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;
  final MapController _mapController = MapController();

  // Mock Rescue Team Coordinates (Nearby)
  LatLng? _rescueTeamLocation;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // 1. GPS Permissions and Initial Position Setup
  Future<void> _checkPermissionsAndGetLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) _showSnackBar('Location services are disabled.');
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) _showSnackBar('Location permissions are denied.');
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) _showSnackBar('Location permissions are permanently denied.');
      setState(() => _isLoading = false);
      return;
    }

    // Geolocator v13+ Settings
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
          _rescueTeamLocation = LatLng(
            position.latitude + 0.008,
            position.longitude + 0.006,
          );
        });

        _getAddressFromLatLng(position);
        _saveLocationToFirestore(position);
        _startLiveLocationUpdates();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error getting initial location: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. Real-time Stream Updates (Every 10 meters move)
  void _startLiveLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Battery saving optimization
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      if (_isSharing && mounted) {
        setState(() {
          _currentPosition = position;
        });
        _getAddressFromLatLng(position);
        _saveLocationToFirestore(position);
      }
    });
  }

  // 3. Save / Sync Coordinates to Cloud Firestore
  Future<void> _saveLocationToFirestore(Position position) async {
    try {
      final userId = _auth.currentUser?.uid ?? 'guest_user';

      await _firestore.collection('live_locations').doc(userId).set({
        'userId': userId,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed,
        'accuracy': position.accuracy,
        'address': _currentAddress,
        'isSharing': _isSharing,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore Update Error: $e');
    }
  }

  // 4. Reverse Geocoding (Coordinates to Readable Address)
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress =
              '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        });
      }
    }
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: GoogleFonts.poppins(fontSize: 12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _centerToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.5,
      );
      _showSnackBar('Centered to current GPS location');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLatLng = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(6.9271, 79.8612);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
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
          'Live Location Tracking',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // OpenStreetMap Tile Layer (Updated to Voyager CartoDB tiles to fix web CORS/ClientException issue)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: userLatLng,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                      userAgentPackageName: 'com.resq.app',
                    ),
                    // Route Polyline to Rescue Team
                    if (_rescueTeamLocation != null)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [userLatLng, _rescueTeamLocation!],
                            strokeWidth: 4.0,
                            color: const Color(0xFF1E88E5),
                          ),
                        ],
                      ),
                    // Map Markers
                    MarkerLayer(
                      markers: [
                        // User GPS Location Marker
                        Marker(
                          point: userLatLng,
                          width: 60,
                          height: 60,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.emergencyRed.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.emergencyRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_pin_circle_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Rescue Team Alpha Marker
                        if (_rescueTeamLocation != null)
                          Marker(
                            point: _rescueTeamLocation!,
                            width: 50,
                            height: 50,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E88E5),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Top Floating Address Card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: AppColors.emergencyRed,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentAddress,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                _currentPosition != null
                                    ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)} • Acc: ±${_currentPosition!.accuracy.toStringAsFixed(0)}m'
                                    : 'Awaiting signal...',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Action Zoom & Location Controls
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      _buildMapFab(Icons.add, () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      }),
                      const SizedBox(height: 8),
                      _buildMapFab(Icons.remove, () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      }),
                      const SizedBox(height: 8),
                      _buildMapFab(
                        Icons.my_location_rounded,
                        _centerToCurrentLocation,
                      ),
                    ],
                  ),
                ),

                // Bottom Rescue Status & Control Card
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sharing with Rescue Team',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _isSharing ? 'LIVE' : 'PAUSED',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: _isSharing ? AppColors.infoGreen : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isSharing ? AppColors.infoGreen : AppColors.textLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Fixed: Wrapped with Material for proper InkSplash effect without assertion warnings
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              // Optional action when clicking on team item
                            },
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDBEAFE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Color(0xFF1E88E5),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              'Team Alpha',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '2.4 km away • ETA 8 mins',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => _isSharing = !_isSharing);

                            // Update sharing state in Firestore
                            final userId = _auth.currentUser?.uid ?? 'guest_user';
                            _firestore.collection('live_locations').doc(userId).update({
                              'isSharing': _isSharing,
                              'lastUpdated': FieldValue.serverTimestamp(),
                            });

                            _showSnackBar(
                              _isSharing
                                  ? 'Resumed live location sharing with Team Alpha'
                                  : 'Live location sharing paused',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSharing
                                ? AppColors.primaryNavy
                                : AppColors.emergencyRed,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isSharing ? 'Stop Sharing' : 'Share Location',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMapFab(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 20),
      ),
    );
  }
}