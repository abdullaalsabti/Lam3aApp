import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../widgets/button.dart';

class PhoneSignup extends ConsumerStatefulWidget {
  const PhoneSignup({super.key});

  @override
  ConsumerState<PhoneSignup> createState() => _PhoneSignupState();
}

class _PhoneSignupState extends ConsumerState<PhoneSignup> {
  final formKey = GlobalKey<FormState>();
  final phoneFocus = FocusNode();
  final phoneController = TextEditingController();
  static const String countryCode = '+962';

  @override
  void initState() {
    super.initState();
    // Pre-fill with country code
    phoneController.text = countryCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Move cursor to end after +962
      phoneController.selection = TextSelection.fromPosition(
        TextPosition(offset: countryCode.length),
      );
      FocusScope.of(context).requestFocus(phoneFocus);
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocus.dispose();
    super.dispose();
  }

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'please enter a phone number';
    
    // Ensure it starts with +962
    if (!value.startsWith(countryCode)) {
      return 'Phone number must start with $countryCode';
    }

    // Validate format: +9627XXXXXXXX (9 digits after +962)
    final phoneRegex = RegExp(r'^\+9627\d{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number (e.g., +9627XXXXXXXX)';
    }

    return null;
  }

  Future<void> confirmPhone() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Save phone number
    ref.read(signupProvider.notifier).updatePhone(phoneController.text);
    final signupData = ref.read(signupProvider);

    // Show loading indicator
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Login with saved email and password to get token
      const String baseUrl = '192.168.1.11:5003';
      final url = Uri.http(baseUrl, 'api/Auth/login');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'email': signupData.email,
          'password': signupData.password,
        }),
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
      }

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        var token = responseBody['token'];
        var refreshToken = responseBody['refreshToken'];

        // Save tokens
        await ApiService().saveTokens(token, refreshToken);

        if (mounted) {
          // Navigate to extended signup page
          Navigator.pushNamed(context, '/extended_signup');
        }
      } else {
        String errorMessage = 'Failed to login after phone verification';
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
        Navigator.pop(context); // Close loading dialog
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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Please Enter your phone number',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 30,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'The number on which you wish to receive text messages and phone calls by our providers.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),

                    // Label
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Phone Number',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Input field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          controller: phoneController,
                          focusNode: phoneFocus,
                          keyboardType: TextInputType.phone,
                          validator: phoneValidator,
                          style: GoogleFonts.poppins(fontSize: 25),
                          decoration: InputDecoration(
                            hintText: '7XXXXXXXX',
                            hintStyle: GoogleFonts.poppins(fontSize: 25),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            // Prevent deletion of country code
                            if (!value.startsWith(countryCode)) {
                              // If user tries to delete +962, restore it
                              final newValue = value.isEmpty 
                                  ? countryCode 
                                  : countryCode + value.replaceAll(RegExp(r'^\+962'), '');
                              
                              phoneController.value = TextEditingValue(
                                text: newValue,
                                selection: TextSelection.collapsed(
                                  offset: newValue.length,
                                ),
                              );
                              return;
                            }
                            
                            // Prevent cursor from going before +962
                            if (phoneController.selection.start < countryCode.length) {
                              phoneController.selection = TextSelection.collapsed(
                                offset: countryCode.length,
                              );
                            }
                            
                            ref.read(signupProvider.notifier).updatePhone(value);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              child: Button(btnText: 'Send OTP', onTap: confirmPhone),
            ),
          ],
        ),
      ),
    );
  }
}
