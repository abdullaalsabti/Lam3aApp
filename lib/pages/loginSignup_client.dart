import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lamaa/providers/sign_up_providers.dart';
import '../widgets/button.dart';

class LoginClient extends ConsumerStatefulWidget {
  const LoginClient({super.key});

  @override
  ConsumerState<LoginClient> createState() => _LoginClientState();
}

class _LoginClientState extends ConsumerState<LoginClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isLogin = true;
  bool _obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      emailController.value = TextEditingValue.empty;
      passwordController.value = TextEditingValue.empty;
    });
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
    if (value.trim().length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (value.trim().length > 30) {
      return 'Password can\'t be longer than 30 characters';
    }
    return null;
  }

  void _submit() async {

    if (true){
      Navigator.pushNamed(context, '/phone_signup');
      return;
    }

    print("submitted");
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Set the correct URL and body based on login/signup mode
    final String baseUrl = dotenv.env['API_BASE_URL']!;
    final String endpoint = _isLogin ? "api/Auth/login" : "api/Auth/register";
    final url = Uri.http(baseUrl, endpoint);

    final Map<String, dynamic> body = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    // Only add the 'role' if signing up
    if (!_isLogin) {
      body['role'] = ref.read(signupProvider.notifier).state.role.index;
    }

    // 2. Perform the request in a single try/catch block
    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      // 3. Check for success (CRITICAL STEP)
      if (response.statusCode == 200) {
        // Success!
        var responseBody = jsonDecode(response.body);
        var token = responseBody['token'];
        var refreshToken = responseBody['refreshToken'];

        print("Success!");
        print("Token: $token");
        print("Refresh Token: $refreshToken");

        //will only push the new page to the stack if API is called
        if (mounted) {
          Navigator.pushNamed(context, '/phone_signup');
        }
        print('Nav');
        // TODO: Save tokens and navigate to home screen
      } else {
        // Handle API errors (like "wrong password" or "email exists")
        print("API Error: ${response.statusCode}");
        print("Error Response: ${response.body}");

        // TODO: Show an error message to the user
      }
    } catch (ex) {
      // Handle network errors (like "Connection refused" or no internet)
      print("Network Error: $ex");

      // TODO: Show a network error message to the user
    }
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
                        controller: emailController,
                        decoration: _inputDecoration('Email'),
                        validator: _validateEmail,
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: passwordController,
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

                      Button(
                        onTap: _submit,
                        btnText: _isLogin ? 'Log In' : "Sign Up",
                      ),
                      const SizedBox(height: 30),

                      const _DividerWithText(text: 'OR'),
                      const SizedBox(height: 30),

                      _GoogleLoginButton(isLogin: _isLogin),
                      const SizedBox(height: 20),

                      _SignUpPrompt(
                        isLogin: _isLogin,
                        toggleFormMode: _toggleFormMode,
                      ),
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
  _GoogleLoginButton({required this.isLogin});

  bool isLogin;

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
          Text(
            isLogin ? 'Login with Google' : "Signup with Google",
            style: GoogleFonts.poppins(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  _SignUpPrompt({required this.isLogin, required this.toggleFormMode});

  void Function() toggleFormMode;

  bool isLogin;

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
          onPressed: toggleFormMode,
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
