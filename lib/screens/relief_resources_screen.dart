import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ReliefResourcesScreen extends StatelessWidget {
  const ReliefResourcesScreen({super.key});

  final List<Map<String, dynamic>> _resources = const [
    {
      'title': 'Food Supplies',
      'available': '1200 units',
      'stockLevel': 0.75,
      'category': 'Dry rations, canned food, baby meals',
      'icon': Icons.lunch_dining_rounded,
      'color': Color(0xFF2E7D32),
      'bgColor': Color(0xFFDCFCE7),
    },
    {
      'title': 'Water Bottles',
      'available': '3500 units',
      'stockLevel': 0.90,
      'category': '5L and 1.5L mineral drinking water',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF1E88E5),
      'bgColor': Color(0xFFDBEAFE),
    },
    {
      'title': 'Medicines',
      'available': '800 units',
      'stockLevel': 0.45,
      'category': 'First aid kits, antibiotics, ORS packs',
      'icon': Icons.medical_information_rounded,
      'color': Color(0xFFE53935),
      'bgColor': Color(0xFFFFEBEE),
    },
    {
      'title': 'Blankets',
      'available': '600 units',
      'stockLevel': 0.60,
      'category': 'Warm winter and thermal shelter bedding',
      'icon': Icons.bed_rounded,
      'color': Color(0xFF0288D1),
      'bgColor': Color(0xFFE0F7FA),
    },
    {
      'title': 'Clothes',
      'available': '900 units',
      'stockLevel': 0.70,
      'category': 'Adult & child emergency protective clothing',
      'icon': Icons.checkroom_rounded,
      'color': Color(0xFFFB8C00),
      'bgColor': Color(0xFFFFEDD5),
    },
  ];

  void _showResourceDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item['bgColor'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Current In Stock: ${item['available']}',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: item['color'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Distribution Category',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                item['category'] as String,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Resource request dispatched to central disaster hub.',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Request Resource Allocation',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

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
          'Relief Resources',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _resources.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _resources[index];
          return GestureDetector(
            onTap: () => _showResourceDetails(context, item),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Available: ${item['available']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
