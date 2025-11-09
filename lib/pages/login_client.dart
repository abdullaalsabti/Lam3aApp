import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/button.dart';

class LoginClient extends StatefulWidget {
  const LoginClient({super.key});

  @override
  State<LoginClient> createState() => _LoginClientState();
}

class _LoginClientState extends State<LoginClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 20, color: Colors.grey),
      border: InputBorder.none,
      suffixIcon: suffixIcon,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter some text';
    final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegEx.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter some text';
    if (value.trim().length > 30) {
      return 'Password can\'t be longer than 30 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                'lib/assets/images/lam3a-logo-login.png',
                fit: BoxFit.contain,
                colorBlendMode: BlendMode.modulate,
                color: Colors.white.withAlpha(100),
              ),
            ),
            const SizedBox(height: 25),

            // Login Form
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextFormField(
                        decoration: _inputDecoration('Email'),
                        validator: _validateEmail,
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        focusNode: _passwordFocusNode,
                        obscureText: _obscureText,
                        decoration: _inputDecoration(
                          'Password',
                          suffixIcon: _passwordFocusNode.hasFocus
                              ? IconButton(
                                  icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black,
                                  ),
                                  onPressed: () => setState(() {
                                    _obscureText = !_obscureText;
                                  }),
                                )
                              : null,
                        ),
                        validator: _validatePassword,
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      const SizedBox(height: 20),

                      Button(onTap: () {}, btnText: 'Log In'),
                      const SizedBox(height: 30),

                      const _DividerWithText(text: 'OR'),
                      const SizedBox(height: 30),

                      _GoogleLoginButton(),
                      const SizedBox(height: 20),

                      _SignUpPrompt(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Widgets ---

class _DividerWithText extends StatelessWidget {
  final String text;
  const _DividerWithText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(text, style: GoogleFonts.poppins()),
        ),
        const Expanded(child: Divider(color: Colors.grey, thickness: 1)),
      ],
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  const _GoogleLoginButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('lib/assets/images/google.png', width: 40),
          const SizedBox(width: 15),
          Text('Login with Google', style: GoogleFonts.poppins(fontSize: 18)),
        ],
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushReplacementNamed(context, '/signup_page'),
          child: Text(
            'Sign Up',
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
