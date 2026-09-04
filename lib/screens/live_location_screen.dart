import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class LiveLocationScreen extends StatefulWidget {
  final bool showBackButton;

  const LiveLocationScreen({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  bool _isSharing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Live Location',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Visual Map Painter
          Positioned.fill(
            child: CustomPaint(
              painter: _MockMapPainter(),
            ),
          ),

          // Map Control Floating Buttons (Zoom In/Out, Current Loc)
          Positioned(
            right: 16,
            top: 24,
            child: Column(
              children: [
                _buildMapFab(Icons.add, () {}),
                const SizedBox(height: 10),
                _buildMapFab(Icons.remove, () {}),
                const SizedBox(height: 10),
                _buildMapFab(Icons.my_location_rounded, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Centered to current GPS location',
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Rescue Team Status Card
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sharing with Rescue Team',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isSharing ? AppColors.infoGreen : AppColors.textLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDBEAFE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Color(0xFF1E88E5),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team Alpha',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '2.4 km away • ETA 8 mins',
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
                        size: 14,
                        color: AppColors.textLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _isSharing = !_isSharing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isSharing
                                ? 'Resumed live location sharing with Team Alpha'
                                : 'Live location sharing paused',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSharing ? AppColors.primaryNavy : AppColors.emergencyRed,
                      minimumSize: const Size(double.infinity, 46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isSharing ? 'Stop Sharing' : 'Share Location',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFab(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 20),
      ),
    );
  }
}

class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF1F5E9);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw main roads
    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.9, size.height * 0.25);
    final path2 = Path()
      ..moveTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.3, size.height);
    final path3 = Path()
      ..moveTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.7, size.height * 0.8);
    final path4 = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width, size.height * 0.6);

    for (final p in [path1, path2, path3, path4]) {
      canvas.drawPath(p, roadBorderPaint);
      canvas.drawPath(p, roadPaint);
    }

    // Draw Route Polyline
    final routePaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final route = Path()
      ..moveTo(size.width * 0.3, size.height * 0.35)
      ..lineTo(size.width * 0.45, size.height * 0.42)
      ..lineTo(size.width * 0.48, size.height * 0.55)
      ..lineTo(size.width * 0.65, size.height * 0.58);

    canvas.drawPath(route, routePaint);

    // Victim Pin (Start)
    final startPin = Offset(size.width * 0.3, size.height * 0.35);
    canvas.drawCircle(
      startPin,
      12,
      Paint()..color = AppColors.emergencyRed,
    );
    canvas.drawCircle(
      startPin,
      6,
      Paint()..color = Colors.white,
    );

    // Team Alpha Pin (Moving point)
    final teamPin = Offset(size.width * 0.65, size.height * 0.58);
    canvas.drawCircle(
      teamPin,
      16,
      Paint()..color = const Color(0xFF1E88E5).withOpacity(0.25),
    );
    canvas.drawCircle(
      teamPin,
      10,
      Paint()..color = const Color(0xFF1E88E5),
    );
    canvas.drawCircle(
      teamPin,
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
