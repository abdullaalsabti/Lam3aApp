import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Google login/signup button widget
class GoogleLoginButton extends StatelessWidget {
  final bool isLogin;
  final VoidCallback? onPressed;

  const GoogleLoginButton({
    super.key,
    required this.isLogin,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed ?? () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/images/google.png',
            width: 40,
          ),
          const SizedBox(width: 15),
          Text(
            isLogin ? 'Login with Google' : 'Signup with Google',
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ],
      ),
    );
  }
}











