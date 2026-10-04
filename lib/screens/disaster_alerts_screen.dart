import 'package:flutter/material.dart';
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

  late List<AlertModel> _alerts;

  List<OfflineData> _offlineSos = [];

  @override
  void initState() {
    super.initState();

    _alerts = AlertModel.getSampleAlerts();

    _loadOfflineSos();
  }

  // ------------------------------------------------------------
  // LOAD OFFLINE SOS RECORDS
  // ------------------------------------------------------------
  void _loadOfflineSos() {
    final sosRecords = LocalStorageService.getSosData();

    if (!mounted) return;

    setState(() {
      _offlineSos = sosRecords;
    });
  }

  // ------------------------------------------------------------
  // REFRESH WHEN SCREEN BECOMES ACTIVE
  // ------------------------------------------------------------
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _loadOfflineSos();
  }

  // ------------------------------------------------------------
  // FILTER NORMAL DISASTER ALERTS
  // ------------------------------------------------------------
  List<AlertModel> get _filteredAlerts {
    if (_selectedFilterIndex == 1) {
      return _alerts.where((a) => !a.isRead).toList();
    } else if (_selectedFilterIndex == 2) {
      return _alerts.where((a) => a.isImportant).toList();
    }

    return _alerts;
  }

  // ------------------------------------------------------------
  // FILTER OFFLINE SOS
  // ------------------------------------------------------------
  List<OfflineData> get _filteredOfflineSos {
    if (_selectedFilterIndex == 1) {
      // Pending SOS = unread
      return _offlineSos
          .where((sos) => sos.syncStatus == 'pending')
          .toList();
    }

    if (_selectedFilterIndex == 2) {
      // All SOS alerts are treated as important
      return _offlineSos;
    }

    return _offlineSos;
  }

  // ------------------------------------------------------------
  // TOTAL NUMBER OF DISPLAYED ALERTS
  // ------------------------------------------------------------
  int get _totalDisplayedAlerts {
    return _filteredAlerts.length +
        _filteredOfflineSos.length;
  }

  // ------------------------------------------------------------
  // NORMAL ALERT DETAILS
  // ------------------------------------------------------------
  void _showAlertDetails(AlertModel alert) {
    setState(() {
      alert.isRead = true;
    });

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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius:
                        BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(10),
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
                          style:
                              GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${alert.location} • ${alert.timeAgo}',
                          style:
                              GoogleFonts.poppins(
                            fontSize: 12,
                            color:
                                AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alert.badgeBgColor,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      alert.severityLabel,
                      style:
                          GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                        color:
                            alert.severityColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(
                color: AppColors.divider,
              ),

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

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Alert advisory link copied to clipboard',
                              style:
                                  GoogleFonts.poppins(
                                fontSize: 12,
                              ),
                            ),
                            behavior:
                                SnackBarBehavior
                                    .floating,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.share_outlined,
                        size: 18,
                      ),
                      label: Text(
                        'Share Alert',
                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      style:
                          OutlinedButton.styleFrom(
                        foregroundColor:
                            AppColors.primaryNavy,
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
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            alert.severityColor,
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
                        'Acknowledge',
                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // OFFLINE SOS DETAILS
  // ------------------------------------------------------------
  void _showOfflineSosDetails(
    OfflineData sos,
  ) {
    final latitude =
        sos.data['latitude']?.toString() ?? 'Unknown';

    final longitude =
        sos.data['longitude']?.toString() ?? 'Unknown';

    final message =
        sos.data['message']?.toString() ??
            'Emergency SOS';

    final userName =
        sos.data['userName']?.toString() ??
            'Anonymous';

    final userPhone =
        sos.data['userPhone']?.toString() ??
            'Not provided';

    final isSynced =
        sos.syncStatus == 'synced';

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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSynced
                            ? const Color(
                                0xFFDCFCE7,
                              )
                            : AppColors
                                .emergencyRedLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSynced
                            ? Icons
                                .check_circle_rounded
                            : Icons
                                .crisis_alert_rounded,
                        color: isSynced
                            ? AppColors.infoGreen
                            : AppColors.emergencyRed,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency SOS',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color: AppColors
                                  .textPrimary,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            isSynced
                                ? 'Synchronized'
                                : 'Saved Offline',
                            style:
                                GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w600,
                              color: isSynced
                                  ? AppColors
                                      .infoGreen
                                  : AppColors
                                      .emergencyRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Divider(
                  color: AppColors.divider,
                ),

                const SizedBox(height: 14),

                Text(
                  'SOS Details',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                _buildDetailRow(
                  Icons.person_outline,
                  'Name',
                  userName,
                ),

                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.phone_outlined,
                  'Phone',
                  userPhone,
                ),

                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Latitude',
                  latitude,
                ),

                const SizedBox(height: 8),

                _buildDetailRow(
                  Icons.location_on_outlined,
                  'Longitude',
                  longitude,
                ),

                const SizedBox(height: 14),

                Text(
                  'Message',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  'Created: ${_formatDateTime(sos.createdAt)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          isSynced
                              ? AppColors
                                  .primaryNavy
                              : AppColors
                                  .emergencyRed,
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
                      style:
                          GoogleFonts.poppins(
                        fontWeight:
                            FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // DETAIL ROW
  // ------------------------------------------------------------
  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),

        const SizedBox(width: 8),

        Text(
          '$label: ',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // FORMAT DATE/TIME
  // ------------------------------------------------------------
  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    return '${local.year}-${twoDigits(local.month)}-${twoDigits(local.day)} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hasAlerts = _totalDisplayedAlerts > 0;

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
                onPressed: () =>
                    Navigator.pop(context),
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
          // --------------------------------------------------------
          // FILTER TABS
          // --------------------------------------------------------
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            child: Row(
              children: [
                _buildFilterTab(
                  0,
                  'All',
                ),

                const SizedBox(width: 10),

                _buildFilterTab(
                  1,
                  'Unread',
                ),

                const SizedBox(width: 10),

                _buildFilterTab(
                  2,
                  'Important',
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color: AppColors.border,
          ),

          // --------------------------------------------------------
          // ALERT LIST
          // --------------------------------------------------------
          Expanded(
            child: !hasAlerts
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      _loadOfflineSos();
                    },
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.all(16),
                      itemCount:
                          _totalDisplayedAlerts,
                      separatorBuilder:
                          (context, index) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        // Normal disaster alert
                        if (index <
                            _filteredAlerts.length) {
                          final alert =
                              _filteredAlerts[index];

                          return _buildAlertCard(
                            alert,
                          );
                        }

                        // Offline SOS
                        final sosIndex = index -
                            _filteredAlerts.length;

                        final sos =
                            _filteredOfflineSos[
                                sosIndex];

                        return _buildOfflineSosCard(
                          sos,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 54,
            color: AppColors.textLight,
          ),

          const SizedBox(height: 12),

          Text(
            'No alerts found in this category',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER TAB
  // ------------------------------------------------------------
  Widget _buildFilterTab(
    int index,
    String label,
  ) {
    final isSelected =
        _selectedFilterIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.emergencyRed
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.emergencyRed
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // NORMAL ALERT CARD
  // ------------------------------------------------------------
  Widget _buildAlertCard(
    AlertModel alert,
  ) {
    return GestureDetector(
      onTap: () =>
          _showAlertDetails(alert),

      child: Container(
        padding:
            const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: !alert.isRead
                ? alert.severityColor
                    .withValues(alpha: 0.35)
                : AppColors.border,
            width:
                !alert.isRead ? 1.2 : 1.0,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.03),
              blurRadius: 8,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Container(
              width: 44,
              height: 44,

              decoration:
                  BoxDecoration(
                color:
                    alert.badgeBgColor,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Icon(
                alert.icon,
                color:
                    alert.severityColor,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),

                      Text(
                        alert.timeAgo,
                        style:
                            GoogleFonts
                                .poppins(
                          fontSize: 11,
                          color: AppColors
                              .textLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    alert.severityLabel,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          alert.severityColor,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    alert.location,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors
                          .textSecondary,
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

  // ------------------------------------------------------------
  // OFFLINE SOS CARD
  // ------------------------------------------------------------
  Widget _buildOfflineSosCard(
    OfflineData sos,
  ) {
    final isSynced =
        sos.syncStatus == 'synced';

    final message =
        sos.data['message']?.toString() ??
            'Emergency! Immediate help needed.';

    return GestureDetector(
      onTap: () =>
          _showOfflineSosDetails(sos),

      child: Container(
        padding:
            const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),

          border: Border.all(
            color: isSynced
                ? AppColors.infoGreen
                    .withValues(alpha: 0.35)
                : AppColors.emergencyRed
                    .withValues(alpha: 0.35),
            width: 1.2,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.03),
              blurRadius: 8,
              offset:
                  const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // SOS ICON
            Container(
              width: 44,
              height: 44,

              decoration: BoxDecoration(
                color: isSynced
                    ? const Color(
                        0xFFDCFCE7,
                      )
                    : AppColors
                        .emergencyRedLight,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Icon(
                isSynced
                    ? Icons
                        .check_circle_rounded
                    : Icons
                        .crisis_alert_rounded,
                color: isSynced
                    ? AppColors.infoGreen
                    : AppColors
                        .emergencyRed,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Emergency SOS',
                          style:
                              GoogleFonts
                                  .poppins(
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color: AppColors
                                .textPrimary,
                          ),
                        ),
                      ),

                      Text(
                        _formatDateTime(
                          sos.createdAt,
                        ),
                        style:
                            GoogleFonts
                                .poppins(
                          fontSize: 10,
                          color: AppColors
                              .textLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    isSynced
                        ? 'Synchronized'
                        : 'Saved Offline',
                    style:
                        GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                      color: isSynced
                          ? AppColors
                              .infoGreen
                          : AppColors
                              .emergencyRed,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    message,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors
                          .textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              size: 14,
              color:
                  AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}