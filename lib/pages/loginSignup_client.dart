import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'package:lamaa/services/api_service.dart';
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

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 1. Set the correct URL and body based on login/signup mode
    const String baseUrl = '192.168.1.11:5003';
    final String endpoint = _isLogin ? "api/Auth/login" : "api/Auth/register";
    final url = Uri.http(baseUrl, endpoint);

    final Map<String, dynamic> body = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    // Only add the 'role' if signing up
    if (!_isLogin) {
      final signUpData = ref.read(signupProvider);
      body['role'] = signUpData.role.index;
      
      // Save email and password to signup provider for later login
      ref.read(signupProvider.notifier).updateEmail(emailController.text);
      ref.read(signupProvider.notifier).updatePassword(passwordController.text);
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
        
        if (_isLogin) {
          // Login response has token and refreshToken
          var token = responseBody['token'];
          var refreshToken = responseBody['refreshToken']; // This is already a string

          print("Login Success!");
          
          // Save tokens using ApiService
          await ApiService().saveTokens(token, refreshToken);

          // Clear cached data from previous user session
          // Invalidate vehicles provider to ensure fresh data for new user
          ref.invalidate(vehiclesProvider);
          
          // Reset signup provider to clear any previous signup data
          ref.read(signupProvider.notifier).reset();

          // After login, go directly to garage page
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/garage');
          }
        } else {
          // Register response has message and userId (NO TOKEN)
          var userId = responseBody['userId']?.toString() ?? '';
          var message = responseBody['message'] ?? 'Registration successful';
          
          print("Registration Success! UserId: $userId");
          
          // Save userId to signup provider for later use
          ref.read(signupProvider.notifier).updateUserId(userId);
          
          // Set a default phone number temporarily (phone page removed)
          ref.read(signupProvider.notifier).updatePhone('+962700000000');
          
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            
            // After signup, wait a moment for DB transaction to complete, then login
            // (skipping phone verification page temporarily)
            await Future.delayed(const Duration(milliseconds: 500));
            _loginAfterSignup(context, ref);
          }
        }
        print('Nav');
      } else {
        // Handle API errors (like "wrong password" or "email exists")
        String errorMessage = 'An error occurred. Please try again.';
        
        try {
          final errorBody = jsonDecode(response.body);
          // Backend returns errors in format: { message: "..." } or { error: "..." }
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['Message'] ??
                        errorMessage;
        } catch (e) {
          // If response body is not JSON, use status code based message
          if (response.statusCode == 401) {
            errorMessage = 'Invalid email or password';
          } else if (response.statusCode == 409) {
            errorMessage = 'Email is already registered';
          } else if (response.statusCode == 400) {
            errorMessage = 'Invalid request. Please check your input.';
          } else if (response.statusCode == 500) {
            errorMessage = 'Server error. Please try again later.';
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (ex) { 
      // Handle network errors (like "Connection refused" or no internet)
      String errorMessage = 'Network error. Please check your internet connection.';
      
      if (ex.toString().contains('Connection timed out')) {
        errorMessage = 'Connection timed out. Please check if the server is running.';
      } else if (ex.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot reach server. Please check your network connection.';
      } else if (ex.toString().contains('SocketException')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _loginAfterSignup(BuildContext context, WidgetRef ref) async {
    try {
      final signupData = ref.read(signupProvider);
      const String baseUrl = '192.168.1.11:5003';
      final url = Uri.http(baseUrl, 'api/Auth/login');
      
      // Use email and password from signup provider (saved during registration)
      final loginEmail = signupData.email;
      final loginPassword = signupData.password;
      
      // Debug: Print credentials (remove in production)
      print("Attempting login with email: $loginEmail");
      
      if (loginEmail.isEmpty || loginPassword.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Email or password not saved. Please try again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': loginEmail,
          'password': loginPassword,
        }),
      );

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var token = responseBody['token'];
        var refreshToken = responseBody['refreshToken'];

        // Save tokens
        await ApiService().saveTokens(token, refreshToken);

        // Clear cached data from any previous session
        ref.invalidate(vehiclesProvider);

        if (mounted) {
          // Navigate directly to extended signup (skipping phone page)
          Navigator.pushReplacementNamed(context, '/extended_signup');
        }
      } else {
        String errorMessage = 'Failed to login after signup';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorBody['Message'] ?? 
                        errorMessage;
        } catch (e) {
          errorMessage = 'API Error: ${response.statusCode}. Please try again.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
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
