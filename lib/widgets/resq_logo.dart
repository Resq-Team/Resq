import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class ResqLogo extends StatelessWidget {
  final double size;
  final bool showTagline;

  const ResqLogo({
    super.key,
    this.size = 140,
    this.showTagline = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Styled Icon Mark
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer radar waves top-right
            CustomPaint(
              size: Size(size * 1.1, size * 1.1),
              painter: _RadarWavesPainter(),
            ),
            // Circular badge
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emergencyRed.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: AppColors.emergencyRed,
                  width: size * 0.045,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Stylized "R" in dark navy with medical cross in loop
                    Text(
                      'R',
                      style: GoogleFonts.poppins(
                        fontSize: size * 0.58,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryNavy,
                        letterSpacing: -2,
                      ),
                    ),
                    // Red medical cross badge inside
                    Positioned(
                      top: size * 0.28,
                      left: size * 0.38,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: AppColors.emergencyRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    // Small pinpoint tail at bottom right of badge
                    Positioned(
                      bottom: size * 0.12,
                      right: size * 0.25,
                      child: Container(
                        width: size * 0.09,
                        height: size * 0.09,
                        decoration: const BoxDecoration(
                          color: AppColors.emergencyRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // "Resq" Title
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Res',
                style: GoogleFonts.poppins(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryNavy,
                  letterSpacing: 0.5,
                ),
              ),
              TextSpan(
                text: 'q',
                style: GoogleFonts.poppins(
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emergencyRed,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'HELP . ALERT . RESCUE.',
            style: GoogleFonts.poppins(
              fontSize: size * 0.085,
              fontWeight: FontWeight.w700,
              color: AppColors.emergencyRed,
              letterSpacing: 2.2,
            ),
          ),
        ],
      ],
    );
  }
}

class _RadarWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.emergencyRed.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width * 0.85, size.height * 0.15);

    // Draw small radar signal arcs
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 14),
      -1.2,
      0.8,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 22),
      -1.2,
      0.8,
      false,
      paint..strokeWidth = 2.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 30),
      -1.2,
      0.8,
      false,
      paint..strokeWidth = 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
