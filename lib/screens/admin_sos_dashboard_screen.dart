import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../services/theme_provider.dart';

class AdminSosDashboardScreen extends StatelessWidget {
  const AdminSosDashboardScreen({Key? key}) : super(key: key);

  // Status එක Update කරන Function එක
  Future _updateStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('sos_alerts')
        .doc(docId)
        .update({'status': newStatus});
  }

  // Status එකට අදාළ Color එක ලබාගැනීම
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'pending':
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch().isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : AppColors.background;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : AppColors.textPrimary;
    final secondaryTextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Admin SOS Alerts Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.redAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        // Firestore එකෙන් SOS Alerts Real-Time ලබාගැනීම
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
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No active emergency alerts at the moment.',
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final rawData = docs[index].data();
              final data = rawData is Map ? rawData : {};
              final docId = docs[index].id;

              final String userName = data['userName']?.toString() ?? 'Unknown User';
              final String emergencyType = data['emergencyType']?.toString() ?? 'Emergency';
              final String status = data['status']?.toString() ?? 'Pending';
              final GeoPoint? location = data['location'] as GeoPoint?;

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(Icons.warning, color: Colors.white),
                  ),
                  title: Text(
                    '$userName - $emergencyType',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (location != null)
                        Text(
                          'Lat: ${location.latitude}, Lng: ${location.longitude}',
                          style: TextStyle(color: secondaryTextColor),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${status.toUpperCase()}',
                        style: TextStyle(
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    color: cardColor,
                    icon: Icon(Icons.more_vert, color: secondaryTextColor),
                    onSelected: (value) {
                      if (value != null) {
                        _updateStatus(docId, value.toString());
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'Pending',
                        child: Text(
                          'Mark as Pending',
                          style: TextStyle(color: primaryTextColor),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'In Progress',
                        child: Text(
                          'Mark as In Progress',
                          style: TextStyle(color: primaryTextColor),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'Resolved',
                        child: Text(
                          'Mark as Resolved',
                          style: TextStyle(color: primaryTextColor),
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