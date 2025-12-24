import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable email text field
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String hintText;

  const EmailField({
    super.key,
    required this.controller,
    this.validator,
    this.hintText = 'Email',
  });

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
      border: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(hintText),
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 15),
      keyboardType: TextInputType.emailAddress,
    );
  }
}










