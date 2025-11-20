import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lamaa/enums/gender.dart';
import 'package:lamaa/pages/address_bottom_sheet.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import '../widgets/button.dart';

class ExtendedSignUp extends ConsumerStatefulWidget {
  const ExtendedSignUp({super.key});

  @override
  ConsumerState<ExtendedSignUp> createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends ConsumerState<ExtendedSignUp> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController fNameController = TextEditingController();
  late final TextEditingController lNameController = TextEditingController();
  late final TextEditingController dobController = TextEditingController();
  late final TextEditingController addressController = TextEditingController();

  DateTime? selectedDate;

  @override
  void dispose() {
    fNameController.dispose();
    lNameController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      selectedDate = picked;
      dobController.text = DateFormat('dd/MM/yyyy').format(picked);

      final notifier = ref.read(signupProvider.notifier);
      notifier.state = notifier.state.copyWith(dob: dobController.text);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final signupState = ref.watch(signupProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Personal Information',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // First Name
                      Text(
                        'First Name',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: fNameController,
                        style: GoogleFonts.poppins(fontSize: 20),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(fontSize: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Last Name
                      Text(
                        'Last Name',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: lNameController,
                        style: GoogleFonts.poppins(fontSize: 20),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(fontSize: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Gender
                      Text(
                        'Gender',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      DropdownButtonFormField<Gender>(
                        initialValue: signupState.gender,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        hint: Text(
                          'Select Gender',
                          style: GoogleFonts.poppins(fontSize: 15),
                        ),
                        items: Gender.values
                            .map(
                              (gender) => DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender.name[0].toUpperCase() +
                                      gender.name.substring(1),
                                  style: GoogleFonts.poppins(fontSize: 15),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            final notifier = ref.read(signupProvider.notifier);
                            notifier.state = notifier.state.copyWith(
                              gender: value,
                            );
                          }
                        },
                        validator: (value) =>
                            value == null ? 'Please select a gender.dart' : null,
                      ),

                      const SizedBox(height: 16),

                      // Date of Birth
                      Text(
                        'Date of Birth',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Select Date of Birth',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                        onTap: selectDate,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a date'
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // Address
                      Text(
                        'Address',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: addressController,
                        readOnly: true,
                        style: GoogleFonts.poppins(fontSize: 20),
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(fontSize: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onTap: () => showAddressBottomSheet(context),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Button at bottom
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Button(btnText: 'Proceed', onTap: () { Navigator.pushNamed(context, '/empty_garage');}),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
