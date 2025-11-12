import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlignedRoleButton extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  const AlignedRoleButton({super.key, 
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      height: 100,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.grey.withValues(alpha: 0.3),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 70,
              height: 70,
              child: Image.asset(image, fit: BoxFit.contain),
            ),
            const SizedBox(width: 25),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 22)),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[700],
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
}
