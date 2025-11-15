import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/providers/providers.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocus);
    });
  }

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'please enter a phone number';

    final phoneRegex = RegExp(r'^(\+9627\d{8})$');
    if (!phoneRegex.hasMatch(value)) return 'Please enter a valid phone number';

    return null;
  }

  void confirmPhone() {
    if (formKey.currentState!.validate()) {
      ref.read(signupProvider.notifier).state = ref
          .read(signupProvider.notifier)
          .state
          .copyWith(phone: phoneController.text);

      final currentPhone = ref.read(signupProvider).phone;
      print("Phone number saved: $currentPhone");
    } else {
      print("Invalid phone number");
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
                            hintText: 'ex: +9627________',
                            hintStyle: GoogleFonts.poppins(fontSize: 25),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 10,
                            ),
                          ),
                          onChanged: (value) {
                            ref.read(signupProvider.notifier).state = ref
                                .read(signupProvider.notifier)
                                .state
                                .copyWith(phone: value);
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
