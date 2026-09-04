import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class PulseSosButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  final String label;
  final bool animate;

  const PulseSosButton({
    super.key,
    this.size = 130,
    required this.onTap,
    this.label = 'SOS',
    this.animate = true,
  });

  @override
  State<PulseSosButton> createState() => _PulseSosButtonState();
}

class _PulseSosButtonState extends State<PulseSosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer animated pulse ring
              if (widget.animate)
                Container(
                  width: widget.size * _pulseAnimation.value * 1.15,
                  height: widget.size * _pulseAnimation.value * 1.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emergencyRed.withOpacity(
                      (1.3 - _pulseAnimation.value).clamp(0.05, 0.25),
                    ),
                  ),
                ),
              // Middle glow halo
              Container(
                width: widget.size * 1.12,
                height: widget.size * 1.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.emergencyRed.withOpacity(0.15),
                ),
              ),
              // Outer thin border ring
              Container(
                width: widget.size * 1.04,
                height: widget.size * 1.04,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 3.5,
                  ),
                ),
              ),
              // Main 3D Gradient SOS Circle
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.25, -0.35),
                    radius: 0.95,
                    colors: [
                      Color(0xFFFF5252),
                      Color(0xFFE53935),
                      Color(0xFFB71C1C),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.emergencyRed.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.poppins(
                      fontSize: widget.size * 0.3,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: const [
                        Shadow(
                          color: Colors.black38,
                          offset: Offset(1, 2),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
