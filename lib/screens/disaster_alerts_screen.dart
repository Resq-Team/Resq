
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';
import '../models/alert_model.dart';
import '../models/offline_data.dart';
import '../services/local_storage_service.dart';

class DisasterAlertsScreen extends StatefulWidget {
  final bool showBackButton;

  const DisasterAlertsScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<DisasterAlertsScreen> createState() =>
      _DisasterAlertsScreenState();
}

class _DisasterAlertsScreenState
    extends State<DisasterAlertsScreen> {
  int _selectedFilterIndex = 0;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  List<OfflineData> _offlineSos = [];

  @override
  void initState() {
    super.initState();
    _loadOfflineSos();
  }

  void _loadOfflineSos() {
    final records = LocalStorageService.getSosData();

    if (!mounted) return;

    setState(() {
      _offlineSos = records;
    });
  }

  Future<void> _markAlertAsRead(String alertId) async {
    try {
      await _firestore
          .collection('alerts')
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error updating alert read status: $e');
    }
  }

  List<AlertModel> _filterAlerts(
    List<AlertModel> alerts,
  ) {
    if (_selectedFilterIndex == 1) {
      return alerts.where((a) => !a.isRead).toList();
    }

    if (_selectedFilterIndex == 2) {
      return alerts.where((a) => a.isImportant).toList();
    }

    return alerts;
  }

  List<OfflineData> get _filteredOfflineSos {
    if (_selectedFilterIndex == 1) {
      return _offlineSos
          .where((sos) => sos.syncStatus == 'pending')
          .toList();
    }

    return _offlineSos;
  }

  void _showAlertDetails(AlertModel alert) {
    if (!alert.isRead) {
      _markAlertAsRead(alert.id);
    }

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
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: alert.badgeBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      alert.icon,
                      color: alert.severityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${alert.location} • ${alert.timeAgo}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 12),
              Text(
                'Incident Details & Advisory',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                alert.description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alert.severityColor,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    'Acknowledge',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOfflineSosDetails(OfflineData sos) {
    final data = sos.data;
    final isSynced = sos.syncStatus == 'synced';

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isSynced ? 'Synchronized' : 'Saved Offline',
                  style: GoogleFonts.poppins(
                    color: isSynced
                        ? AppColors.infoGreen
                        : AppColors.emergencyRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Name',
                  data['userName']?.toString() ?? 'Anonymous',
                ),
                _buildDetailRow(
                  'Phone',
                  data['userPhone']?.toString() ?? 'Not provided',
                ),
                _buildDetailRow(
                  'Latitude',
                  data['latitude']?.toString() ?? 'Unknown',
                ),
                _buildDetailRow(
                  'Longitude',
                  data['longitude']?.toString() ?? 'Unknown',
                ),
                const SizedBox(height: 12),
                Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  data['message']?.toString() ??
                      'Emergency! Immediate help needed.',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  'Created: ${_formatDateTime(sos.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    String twoDigits(int value) =>
        value.toString().padLeft(2, '0');

    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  Widget _buildFilterTab(int index, String label) {
    final selected = _selectedFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.emergencyRed
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.emergencyRed
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert) {
    return GestureDetector(
      onTap: () => _showAlertDetails(alert),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: !alert.isRead
                ? alert.severityColor.withValues(alpha: 0.35)
                : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: alert.badgeBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                alert.icon,
                color: alert.severityColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        alert.timeAgo,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alert.severityLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: alert.severityColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    alert.location,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineSosCard(OfflineData sos) {
    final isSynced = sos.syncStatus == 'synced';
    final message = sos.data['message']?.toString() ??
        'Emergency! Immediate help needed.';

    return GestureDetector(
      onTap: () => _showOfflineSosDetails(sos),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSynced
                ? AppColors.infoGreen.withValues(alpha: 0.35)
                : AppColors.emergencyRed.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSynced
                    ? const Color(0xFFDCFCE7)
                    : AppColors.emergencyRedLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSynced
                    ? Icons.check_circle_rounded
                    : Icons.crisis_alert_rounded,
                color: isSynced
                    ? AppColors.infoGreen
                    : AppColors.emergencyRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Emergency SOS',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _formatDateTime(sos.createdAt),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isSynced ? 'Synchronized' : 'Saved Offline',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSynced
                          ? AppColors.infoGreen
                          : AppColors.emergencyRed,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No alerts found in this category',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offlineSos = _filteredOfflineSos;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Disaster Alerts',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            onPressed: _loadOfflineSos,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildFilterTab(0, 'All'),
                const SizedBox(width: 10),
                _buildFilterTab(1, 'Unread'),
                const SizedBox(width: 10),
                _buildFilterTab(2, 'Important'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore
                  .collection('alerts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Keep sample alerts visible if Firestore is loading
                // or unavailable. Offline SOS records remain visible too.
                List<AlertModel> alerts =
                    AlertModel.getSampleAlerts();

                if (snapshot.hasData) {
                  final docs = snapshot.data!.docs;

                  if (docs.isNotEmpty) {
                    alerts = docs
                        .map((doc) => AlertModel.fromFirestore(doc))
                        .toList();
                  }
                }

                final filteredAlerts = _filterAlerts(alerts);
                final total = filteredAlerts.length + offlineSos.length;

                if (total == 0) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadOfflineSos();
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: total,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index < filteredAlerts.length) {
                        return _buildAlertCard(
                          filteredAlerts[index],
                        );
                      }

                      final sosIndex = index - filteredAlerts.length;
                      return _buildOfflineSosCard(
                        offlineSos[sosIndex],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
