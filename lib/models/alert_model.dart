
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AlertModel {
  final String id;
  final String title;
  final String description;
  final String location;
  final String timeAgo;
  final String severityLabel;
  final Color severityColor;
  final Color badgeBgColor;
  final IconData icon;
  bool isRead;
  final bool isImportant;

  AlertModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.timeAgo,
    required this.severityLabel,
    required this.severityColor,
    required this.badgeBgColor,
    required this.icon,
    this.isRead = false,
    this.isImportant = false,
  });

  // Create an AlertModel object from a Firestore document.
  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AlertModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      timeAgo: data['timeAgo'] ?? 'Just now',
      severityLabel: data['severityLabel'] ?? 'Info',
      severityColor: _parseColor(data['severityColor']),
      badgeBgColor: _parseColor(data['badgeBgColor'])
          .withValues(alpha: 0.15),
      icon: _parseIcon(data['icon']),
      isRead: data['isRead'] ?? false,
      isImportant: data['isImportant'] ?? false,
    );
  }

  // Parse colors from Firestore.
  static Color _parseColor(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    }

    if (colorValue is String && colorValue.startsWith('#')) {
      final hexCode = colorValue.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    }

    return AppColors.emergencyRed;
  }

  // Parse icons from Firestore.
  static IconData _parseIcon(dynamic iconData) {
    if (iconData is int) {
      // ignore: non_const_argument_for_const_parameter
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }

    return Icons.warning_amber_rounded;
  }

  // Sample data for testing or when Firestore data is unavailable.
  static List<AlertModel> getSampleAlerts() {
    return [
      AlertModel(
        id: '1',
        title: 'Severe Flood Warning',
        description:
            'Water levels rising rapidly along Kelani River. Low-lying areas are advised to evacuate to designated safe locations immediately.',
        location: 'Colombo District',
        timeAgo: '10m ago',
        severityLabel: 'High Severity',
        severityColor: AppColors.emergencyRed,
        badgeBgColor:
            AppColors.emergencyRed.withValues(alpha: 0.12),
        icon: Icons.flood_outlined,
        isRead: false,
        isImportant: true,
      ),
      AlertModel(
        id: '2',
        title: 'Landslide Risk Alert',
        description:
            'Heavy rainfall may trigger landslides in hilly areas. Residents should stay vigilant for signs of slope failure.',
        location: 'Ratnapura & Kegalle',
        timeAgo: '1h ago',
        severityLabel: 'Medium Severity',
        severityColor: Colors.orange,
        badgeBgColor: Colors.orange.withValues(alpha: 0.12),
        icon: Icons.landscape_outlined,
        isRead: false,
        isImportant: true,
      ),
      AlertModel(
        id: '3',
        title: 'Heavy Rain & Wind Advisory',
        description:
            'Strong winds up to 50km/h expected during monsoon showers. Avoid standing near large trees or unstable structures.',
        location: 'Western Province',
        timeAgo: '3h ago',
        severityLabel: 'Advisory',
        severityColor: Colors.amber.shade700,
        badgeBgColor: Colors.amber.withValues(alpha: 0.12),
        icon: Icons.air_rounded,
        isRead: true,
        isImportant: false,
      ),
    ];
  }
}
