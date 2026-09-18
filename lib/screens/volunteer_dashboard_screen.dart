import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_colors.dart';
import 'add_task_screen.dart'; // AddTaskScreen import කරගන්න

class VolunteerDashboardScreen extends StatelessWidget {
  const VolunteerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Tasks',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      // Admin / User ට අලුතෙන් Task එකක් එකතු කිරීමට Floating Action Button එක
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore හි 'volunteer_tasks' collection එක Stream එකක් ලෙස ලබා ගැනීම
        stream: FirebaseFirestore.instance
            .collection('volunteer_tasks')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading tasks',
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          // Dynamic Stats Calculation
          int assignedCount = docs.where((doc) => doc['status'] == 'Assigned').length;
          int inProgressCount = docs.where((doc) => doc['status'] == 'In-Progress').length;
          int completedCount = docs.where((doc) => doc['status'] == 'Completed').length;

          // '01', '02' ලෙස Format කිරීම
          String fmt(int n) => n < 10 ? '0$n' : '$n';

          // Current Task එක තෝරාගැනීම (In-Progress හෝ Assigned පළමු Task එක)
          DocumentSnapshot? currentTaskDoc;
          try {
            currentTaskDoc = docs.firstWhere(
              (doc) => doc['status'] == 'In-Progress' || doc['status'] == 'Assigned',
            );
          } catch (_) {
            currentTaskDoc = docs.isNotEmpty ? docs.first : null;
          }

          // Upcoming Tasks List (Current Task එක හැර අනික්වා)
          final upcomingTasks = docs.where((doc) => doc.id != currentTaskDoc?.id).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3 Stat Counters Row (Live Data)
                Row(
                  children: [
                    _buildStatBox(fmt(assignedCount), 'Assigned', const Color(0xFF1E88E5)),
                    const SizedBox(width: 12),
                    _buildStatBox(fmt(inProgressCount), 'In-Progress', const Color(0xFFFB8C00)),
                    const SizedBox(width: 12),
                    _buildStatBox(fmt(completedCount), 'Completed', const Color(0xFF2E7D32)),
                  ],
                ),

                const SizedBox(height: 24),

                // Current Task Section
                Text(
                  'Current Task',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Main Active Task Card (Firestore Data)
                if (currentTaskDoc != null)
                  _buildCurrentTaskCard(context, currentTaskDoc)
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      'No active task assigned.',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),

                const SizedBox(height: 24),

                // Upcoming Tasks Section
                Text(
                  'Upcoming Tasks',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                if (upcomingTasks.isEmpty)
                  Text(
                    'No upcoming tasks available.',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data = upcomingTasks[index].data() as Map<String, dynamic>;
                      return _buildUpcomingTaskTile(
                        title: data['title'] ?? 'Task Item',
                        date: data['date'] ?? 'No Date Specified',
                        icon: _getTaskIcon(data['category']),
                        iconColor: const Color(0xFF1E88E5),
                        bgColor: const Color(0xFFDBEAFE),
                      );
                    },
                  ),
                const SizedBox(height: 60), // Space for FloatingActionButton
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTaskCard(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emergencyRed.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data['title'] ?? 'Rescue Task',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.emergencyRedLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  data['priority'] ?? 'High Priority',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emergencyRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data['location'] ?? 'Location not specified',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data['date'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Opening task briefing for ${data['title']}...',
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergencyRed,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'View Details',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingTaskTile({
    required String title,
    required String date,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLight),
        ],
      ),
    );
  }

  IconData _getTaskIcon(String? category) {
    switch (category) {
      case 'Medical':
        return Icons.medical_services_outlined;
      case 'Supply':
        return Icons.inventory_2_outlined;
      case 'Shelter':
        return Icons.assignment_outlined;
      default:
        return Icons.task_alt_rounded;
    }
  }
}