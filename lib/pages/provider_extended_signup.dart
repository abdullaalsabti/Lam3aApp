import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lamaa/enums/gender.dart';
import 'package:lamaa/pages/address_bottom_sheet.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/services/api_service.dart';
import '../widgets/button.dart';

class ProviderExtendedSignUp extends ConsumerStatefulWidget {
  const ProviderExtendedSignUp({super.key});

  @override
  ConsumerState<ProviderExtendedSignUp> createState() => _ProviderExtendedSignUpState();
}

class _ProviderExtendedSignUpState extends ConsumerState<ProviderExtendedSignUp> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController fNameController = TextEditingController();
  late final TextEditingController lNameController = TextEditingController();
  late final TextEditingController dobController = TextEditingController();
  late final TextEditingController addressController = TextEditingController();

  DateTime? selectedDate;
  bool isSubmitting = false;

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
      setState(() {});
    }
  }

  String _mapGenderToBackend(Gender gender) {
    switch (gender) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
    }
  }

  Map<String, String> _parseAddress(String address) {
    final trimmed = address.trim();
    final commaIndex = trimmed.indexOf(',');

    if (commaIndex == -1) {
      return {
        'buildingNumber': trimmed.isEmpty ? '0' : trimmed,
        'landmark': '',
      };
    } else {
      final buildingNumber = trimmed.substring(0, commaIndex).trim();
      final landmark = trimmed.substring(commaIndex + 1).trim();
      return {
        'buildingNumber': buildingNumber.isEmpty ? '0' : buildingNumber,
        'landmark': landmark,
      };
    }
  }

  Future<void> _submitProfile() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    if (fNameController.text.isEmpty ||
        lNameController.text.isEmpty ||
        selectedDate == null ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final addressParts = _parseAddress(addressController.text);
      final signupState = ref.read(signupProvider);

      final dateOfBirth = selectedDate!;
      final dateOfBirthUtc = DateTime.utc(
        dateOfBirth.year,
        dateOfBirth.month,
        dateOfBirth.day,
        0,
        0,
        0,
      );
      final dobString = dateOfBirthUtc.toIso8601String();

      final body = {
        'firstName': fNameController.text.trim(),
        'lastName': lNameController.text.trim(),
        'gender': _mapGenderToBackend(signupState.gender),
        'dateOfBirth': dobString,
        'address': {
          'street': 'Default Street',
          'buildingNumber': addressParts['buildingNumber'] ?? '0',
          'landmark': addressParts['landmark']?.toString().trim().isNotEmpty == true
              ? addressParts['landmark']
              : 'Amman',
          'coordinates': {
            'latitude': 31.9539,
            'longitude': 35.9106,
          },
        },
      };

      final response = await ApiService()
          .putAuthenticated('api/provider/ProviderProfile/editProfile', body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          Navigator.pushReplacementNamed(context, '/provider_availability');
        }
      } else {
        String errorMessage = 'Failed to save profile';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
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
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            'Provider Information',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        Text('First Name',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: fNameController,
                          style: GoogleFonts.poppins(fontSize: 20),
                          decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(fontSize: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'First name is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Last Name',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: lNameController,
                          style: GoogleFonts.poppins(fontSize: 20),
                          decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(fontSize: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Last name is required'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Gender',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<Gender>(
                          initialValue: signupState.gender,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          hint: Text('Select Gender',
                              style: GoogleFonts.poppins(fontSize: 15)),
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
                              ref.read(signupProvider.notifier).updateGender(value);
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Please select a gender' : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Date of Birth',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: dobController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Select Date of Birth',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          onTap: selectDate,
                          validator: (value) =>
                              value == null || value.isEmpty
                                  ? 'Please select a date'
                                  : null,
                        ),
                        const SizedBox(height: 16),

                        Text('Address',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: addressController,
                          readOnly: true,
                          style: GoogleFonts.poppins(fontSize: 20),
                          decoration: InputDecoration(
                            hintStyle: GoogleFonts.poppins(fontSize: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Address is required'
                                  : null,
                          onTap: () => showAddressBottomSheet(
                            context,
                            (address) {
                              addressController.text = address;
                              formKey.currentState?.validate();
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : Button(
                          btnText: 'Proceed',
                          onTap: _submitProfile,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


