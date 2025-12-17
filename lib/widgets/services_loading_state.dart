import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesLoadingState extends StatelessWidget {
  final ColorScheme scheme;

  const ServicesLoadingState({
    super.key,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your services...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

