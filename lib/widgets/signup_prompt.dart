import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget that prompts user to switch between login and signup
class SignupPrompt extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onToggle;

  const SignupPrompt({
    super.key,
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'Don\'t have an account?' : 'Already have an account?',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        TextButton(
          onPressed: onToggle,
          child: Text(
            isLogin ? 'Sign Up' : 'Log In',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}










