import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/enums/role.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/services/auth_service.dart';
import 'package:lamaa/utils/auth_validators.dart';
import '../../widgets/auth_divider.dart';
import '../../widgets/button.dart';
import '../../widgets/email_field.dart';
import '../../widgets/google_login_button.dart';
import '../../widgets/password_field.dart';
import '../../widgets/signup_prompt.dart';

class LoginClient extends ConsumerStatefulWidget {
  const LoginClient({super.key});

  @override
  ConsumerState<LoginClient> createState() => _LoginClientState();
}

class _LoginClientState extends ConsumerState<LoginClient> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  final _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _toggleFormMode() {
    setState(() {
      _isLogin = !_isLogin;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final signUpData = ref.read(signupProvider);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = _isLogin
          ? await _authService.login(
              email: email,
              password: password,
              role: signUpData.role,
              ref: ref,
            )
          : await _authService.register(
              email: email,
              password: password,
              role: signUpData.role,
              ref: ref,
            );

      if (!mounted) return;

      if (result.isSuccess) {
        if (_isLogin) {
          _navigateAfterLogin(result.role!);
        } else {
          _handleRegistrationSuccess(result);
        }
      } else {
        _showError(result.errorMessage!);
      }
    } catch (e) {
      if (mounted) {
        _showError('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateAfterLogin(Role role) {
    final route = role == Role.provider
        ? '/provider_main'
        : '/main_page';
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _handleRegistrationSuccess(AuthResult result) async {
    if (result.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.successMessage!),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    // Auto-login after registration
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isLoading = true);

    final loginResult = await _authService.loginAfterSignup(ref: ref);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (loginResult.isSuccess) {
      Navigator.pushReplacementNamed(context, '/extended_signup');
    } else {
      _showError(loginResult.errorMessage!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
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
                      EmailField(
                        controller: _emailController,
                        validator: AuthValidators.validateEmail,
                      ),
                      const SizedBox(height: 15),
                      PasswordField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        validator: AuthValidators.validatePassword,
                      ),
                      const SizedBox(height: 20),
                      Button(
                        onTap: _submit,
                        btnText: _isLogin ? 'Log In' : 'Sign Up',
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 30),
                      const AuthDivider(text: 'OR'),
                      const SizedBox(height: 30),
                      GoogleLoginButton(isLogin: _isLogin),
                      const SizedBox(height: 20),
                      SignupPrompt(
                        isLogin: _isLogin,
                        onToggle: _toggleFormMode,
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
