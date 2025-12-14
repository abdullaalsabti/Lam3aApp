import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable password text field with visibility toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final String hintText;

  const PasswordField({
    super.key,
    required this.controller,
    this.focusNode,
    this.validator,
    this.hintText = 'Password',
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
      border: InputBorder.none,
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = widget.focusNode?.hasFocus ?? false;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscureText,
      validator: widget.validator,
      style: GoogleFonts.poppins(fontSize: 15),
      decoration: _inputDecoration(
        widget.hintText,
        suffixIcon: hasFocus
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }
}

