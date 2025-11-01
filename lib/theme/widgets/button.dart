import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatelessWidget {
  const Button({required this.btnText, super.key});

  final String btnText;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF23918C),
        elevation: 5,
        shadowColor: Colors.black,
        minimumSize: Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        btnText,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
