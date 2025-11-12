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

  @override
  void initState() {
    super.initState();

    // Automatically focus the field after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocus);
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

  TextEditingController phoneController = TextEditingController();

  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'please enter a phone number';

    final phoneRegex = RegExp(r'\+\d{12}');
    if (!phoneRegex.hasMatch(value)) return 'Please enter a valid phone number';

    return null;
  }

  void confirmPhone() {
    if (formKey.currentState!.validate()) {
      // Input is valid
      ref.read(signupProvider.notifier).state = ref
          .read(signupProvider.notifier)
          .state
          .copyWith(phone: phoneController.text);

      final currentPhone = ref.read(signupProvider).phone;
      print("Phone number saved in Riverpod: $currentPhone");
    } else {
      // Input is invalid
      print("Invalid phone number");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Please Enter your phone number',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'The number on which you wish '
                  'to receive text messages and '
                  'phone calls by our providers.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
                ),
              ),
              SizedBox(height: 100),

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

              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    validator: phoneValidator,
                    style: GoogleFonts.poppins(fontSize: 25),
                    decoration: InputDecoration(
                      hintText: 'ex: +9627________',
                      hintStyle: GoogleFonts.poppins(fontSize: 25),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10
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
              SizedBox(height: 380),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Button(btnText: 'Send OTP', onTap: confirmPhone),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
