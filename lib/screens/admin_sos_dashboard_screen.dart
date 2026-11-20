
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../services/theme_provider.dart';

class AdminSosDashboardScreen extends StatelessWidget {
  const AdminSosDashboardScreen({Key? key}) : super(key: key);

  // Update SOS alert status in Firestore
  Future<void> _updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('sos_alerts')
          .doc(docId)
          .update({'status': newStatus});
    } catch (e) {
      debugPrint('Failed to update SOS status: $e');
    }
  }

  // Get the correct color for each status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.orange;

      case 'resolved':
        return Colors.green;

      case 'active':
      case 'pending':
      default:
        return Colors.red;
    }
  }

  // Display the status in a user-friendly format
  String _getDisplayStatus(String status) {
    if (status.toLowerCase() == 'active') {
      return 'Pending';
    }

    return status;
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Specify the provider type
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final bgColor =
        isDark ? const Color(0xFF121212) : AppColors.background;

    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final primaryTextColor =
        isDark ? Colors.white : AppColors.textPrimary;

    final secondaryTextColor =
        isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        title: const Text(
          'Admin SOS Alerts Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor:
            isDark ? const Color(0xFF1A1A2E) : Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Listen to SOS alerts in real time
        stream: FirebaseFirestore.instance
            .collection('sos_alerts')
            .orderBy('timestamp', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No emergency alerts at the moment.',
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index].data();
              final docId = docs[index].id;

              final userName =
                  data['userName']?.toString() ?? 'Unknown User';

              // Your SOS service saves a message, not emergencyType.
              final emergencyMessage =
                  data['message']?.toString() ??
                  data['emergencyType']?.toString() ??
                  'Emergency!';

              final status =
                  data['status']?.toString() ?? 'Pending';

              final displayStatus = _getDisplayStatus(status);

              // Your SOS service saves latitude and longitude separately.
              final latitude = (data['latitude'] as num?)?.toDouble();
              final longitude = (data['longitude'] as num?)?.toDouble();

              // Also support older records containing a GeoPoint.
              final location = data['location'];

              double? displayLatitude = latitude;
              double? displayLongitude = longitude;

              if (location is GeoPoint) {
                displayLatitude = location.latitude;
                displayLongitude = location.longitude;
              }

              final userPhone =
                  data['userPhone']?.toString() ?? 'Not provided';

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                elevation: 4,

                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                    ),
                  ),

                  title: Text(
                    userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

                      Text(
                        emergencyMessage,
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 5),

                      if (displayLatitude != null &&
                          displayLongitude != null)
                        Text(
                          'Lat: $displayLatitude, '
                          'Lng: $displayLongitude',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        )
                      else
                        Text(
                          'Location unavailable',
                          style: TextStyle(
                            color: secondaryTextColor,
                          ),
                        ),

                      const SizedBox(height: 5),

                      Text(
                        'Phone: $userPhone',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Status: ${displayStatus.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  trailing: PopupMenuButton<String>(
                    color: cardColor,

                    icon: Icon(
                      Icons.more_vert,
                      color: secondaryTextColor,
                    ),

                    onSelected: (value) {
                      _updateStatus(docId, value);
                    },

                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'active',
                        child: Text(
                          'Mark as Pending',
                          style: TextStyle(
                            color: primaryTextColor,
                          ),
                        ),
                      ),

                      PopupMenuItem(
                        value: 'In Progress',
                        child: Text(
                          'Mark as In Progress',
                          style: TextStyle(
                            color: primaryTextColor,
                          ),
                        ),
                      ),

                      PopupMenuItem(
                        value: 'Resolved',
                        child: Text(
                          'Mark as Resolved',
                          style: TextStyle(
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
