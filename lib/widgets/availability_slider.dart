import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvailabilitySlider extends StatefulWidget {
  final bool isAvailable;
  final bool isLoading;
  final ValueChanged<bool> onToggle;

  const AvailabilitySlider({
    super.key,
    required this.isAvailable,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  State<AvailabilitySlider> createState() => _AvailabilitySliderState();
}

class _AvailabilitySliderState extends State<AvailabilitySlider>
    with SingleTickerProviderStateMixin {
  // NOTE:
  // Using `late` here can crash after hot-reload because `initState()` doesn't rerun.
  // We keep a safe default scale animation so the widget never throws.
  AnimationController? _animationController;
  Animation<double> _scaleAnimation = const AlwaysStoppedAnimation<double>(1.0);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isLoading) {
      final controller = _animationController;
      if (controller == null) {
        widget.onToggle(!widget.isAvailable);
        return;
      }

      controller.forward().then((_) {
        controller.reverse();
        widget.onToggle(!widget.isAvailable);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: widget.isAvailable
                  ? [
                      const Color(0xFF4A90E2), // Bright blue
                      const Color(0xFF23918C), // Darker teal
                    ]
                  : [
                      Colors.grey.shade400,
                      Colors.grey.shade600,
                    ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left chevrons
                    Row(
                      children: List.generate(
                        3,
                        (index) => const Padding(
                          padding: EdgeInsets.only(right: 2),
                          child: Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Text
                    Text(
                      widget.isAvailable ? 'Go Online' : 'Go Offline',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Right chevrons
                    Row(
                      children: List.generate(
                        3,
                        (index) => const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}