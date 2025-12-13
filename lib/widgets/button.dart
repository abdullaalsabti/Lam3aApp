import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  const Button({
    required this.onTap,
    required this.btnText,
    this.isLoading = false,
    super.key,
  });

  final String btnText;
  final void Function() onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF23918C),
        elevation: 5,
        shadowColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        disabledBackgroundColor: Color(0xFF23918C).withOpacity(0.6),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              btnText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
            ),
    );
  }
}
