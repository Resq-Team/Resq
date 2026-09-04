import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum AlertSeverity {
  highRisk,
  moderateRisk,
  information,
}

class AlertModel {
  final String id;
  final String title;
  final AlertSeverity severity;
  final String severityLabel;
  final String location;
  final String timeAgo;
  final String description;
  final IconData icon;
  bool isRead;
  final bool isImportant;

  AlertModel({
    required this.id,
    required this.title,
    required this.severity,
    required this.severityLabel,
    required this.location,
    required this.timeAgo,
    required this.description,
    required this.icon,
    this.isRead = false,
    this.isImportant = false,
  });

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.highRisk:
        return AppColors.highRisk;
      case AlertSeverity.moderateRisk:
        return AppColors.moderateRisk;
      case AlertSeverity.information:
        return AppColors.infoGreen;
    }
  }

  Color get badgeBgColor {
    return severityColor.withOpacity(0.12);
  }

  static List<AlertModel> getSampleAlerts() {
    return [
      AlertModel(
        id: '1',
        title: 'Flood Warning',
        severity: AlertSeverity.highRisk,
        severityLabel: 'High Risk',
        location: 'Colombo District',
        timeAgo: '2 min ago',
        description: 'Kelani river water levels are rising rapidly. Residents in low-lying areas of Colombo and Wellampitiya are advised to evacuate immediately.',
        icon: Icons.warning_rounded,
        isRead: false,
        isImportant: true,
      ),
      AlertModel(
        id: '2',
        title: 'Heavy Rain Alert',
        severity: AlertSeverity.moderateRisk,
        severityLabel: 'Moderate Risk',
        location: 'Gampaha District',
        timeAgo: '1 hour ago',
        description: 'Continuous rainfall expected for the next 24 hours. High possibility of waterlogging on roads and minor inundation.',
        icon: Icons.thunderstorm_rounded,
        isRead: false,
        isImportant: false,
      ),
      AlertModel(
        id: '3',
        title: 'Landslide Warning',
        severity: AlertSeverity.highRisk,
        severityLabel: 'High Risk',
        location: 'Kandy District',
        timeAgo: '3 hours ago',
        description: 'NBRO issued Level 3 Red landslide alert for hill slopes in Kandy and surrounding divisional secretariats.',
        icon: Icons.landscape_rounded,
        isRead: true,
        isImportant: true,
      ),
      AlertModel(
        id: '4',
        title: 'Shelter Opened',
        severity: AlertSeverity.information,
        severityLabel: 'Information',
        location: 'Matara District',
        timeAgo: '5 hours ago',
        description: 'Safe Haven Community Relief Shelter is now fully operational with food, medical aid, and 120 available beds.',
        icon: Icons.home_work_rounded,
        isRead: true,
        isImportant: false,
      ),
    ];
  }
}
