import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSosDashboardScreen extends StatelessWidget {
  const AdminSosDashboardScreen({Key? key}) : super(key: key);

  // Status එක Update කරන Function එක
  Future<void> _updateStatus(String docId, String newStatus) async {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin SOS Alerts Dashboard'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore එකෙන් SOS Alerts Real-Time ලබාගැනීම
        stream: FirebaseFirestore.instance
            .collection('sos_alerts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No active emergency alerts at the moment.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final docId = docs[index].id;

              final String userName = data['userName'] ?? 'Unknown User';
              final String emergencyType = data['emergencyType'] ?? 'Emergency';
              final String status = data['status'] ?? 'Pending';
              final GeoPoint? location = data['location'] as GeoPoint?;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(status),
                    child: const Icon(Icons.warning, color: Colors.white),
                  ),
                  title: Text(
                    '$userName - $emergencyType',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (location != null)
                        Text('Lat: ${location.latitude}, Lng: ${location.longitude}'),
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
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) => _updateStatus(docId, value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Pending',
                        child: Text('Mark as Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'In Progress',
                        child: Text('Mark as In Progress'),
                      ),
                      const PopupMenuItem(
                        value: 'Resolved',
                        child: Text('Mark as Resolved'),
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