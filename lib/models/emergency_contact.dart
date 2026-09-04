import 'package:flutter/material.dart';

class EmergencyContact {
  final String title;
  final String number;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String description;

  EmergencyContact({
    required this.title,
    required this.number,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.description,
  });

  static List<EmergencyContact> getEmergencyContacts() {
    return [
      EmergencyContact(
        title: 'Police',
        number: '119',
        icon: Icons.local_police_rounded,
        iconColor: const Color(0xFF1E88E5),
        iconBgColor: const Color(0xFFE3F2FD),
        description: 'National Police Emergency Response & Patrol',
      ),
      EmergencyContact(
        title: 'Ambulance',
        number: '1990',
        icon: Icons.medical_services_rounded,
        iconColor: const Color(0xFFE53935),
        iconBgColor: const Color(0xFFFFEBEE),
        description: 'Suwa Seriya Free National Emergency Ambulance',
      ),
      EmergencyContact(
        title: 'Fire Brigade',
        number: '110',
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFB8C00),
        iconBgColor: const Color(0xFFFFF3E0),
        description: 'Fire Rescue & Disaster Relief Services',
      ),
      EmergencyContact(
        title: 'Hospital',
        number: '011-2345678',
        icon: Icons.local_hospital_rounded,
        iconColor: const Color(0xFF43A047),
        iconBgColor: const Color(0xFFE8F5E9),
        description: 'National Hospital Emergency & Trauma Unit',
      ),
      EmergencyContact(
        title: 'Disaster Management',
        number: '117',
        icon: Icons.shield_rounded,
        iconColor: const Color(0xFF00ACC1),
        iconBgColor: const Color(0xFFE0F7FA),
        description: 'Disaster Management Centre (DMC) Call Center',
      ),
    ];
  }
}
