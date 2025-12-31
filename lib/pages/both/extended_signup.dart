import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lamaa/enums/gender.dart';
import 'package:lamaa/enums/role.dart';
import 'package:lamaa/widgets/address_bottom_sheet.dart';
import 'package:lamaa/models/address.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/services/api_service.dart';
import '../../widgets/button.dart';

class ExtendedSignup extends ConsumerStatefulWidget {
  final Map<String, dynamic>? profileData;
  
  const ExtendedSignup({super.key, this.profileData});

  @override
  ConsumerState<ExtendedSignup> createState() => _ExtendedSignupState();
}

class _ExtendedSignupState extends ConsumerState<ExtendedSignup> {
  final formKey = GlobalKey<FormState>();
  bool loadingLocation = false;
  late final TextEditingController fNameController = TextEditingController();
  late final TextEditingController lNameController = TextEditingController();
  late final TextEditingController dobController = TextEditingController();
  late final TextEditingController addressController = TextEditingController();

  DateTime? selectedDate;
  bool isSubmitting = false;
  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    // Pre-fill form if profile data is provided
    // Use addPostFrameCallback to avoid modifying providers during build
    if (widget.profileData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadProfileData();
        }
      });
    }
  }

  void _loadProfileData() {
    final profileData = widget.profileData!;
    
    // Pre-fill first name
    if (profileData['firstName'] != null) {
      fNameController.text = profileData['firstName'].toString();
    }
    
    // Pre-fill last name
    if (profileData['lastName'] != null) {
      lNameController.text = profileData['lastName'].toString();
    }
    
    // Pre-fill date of birth
    if (profileData['dateOfBirth'] != null) {
      try {
        final dobString = profileData['dateOfBirth'].toString();
        selectedDate = DateTime.parse(dobString);
        dobController.text = DateFormat('dd/MM/yyyy').format(selectedDate!);
      } catch (e) {
        // If parsing fails, leave empty
      }
    }
    
    // Pre-fill gender (this modifies provider, so it's done after build)
    if (profileData['gender'] != null) {
      final genderString = profileData['gender'].toString().toLowerCase();
      Gender? gender;
      if (genderString == 'male') {
        gender = Gender.male;
      } else if (genderString == 'female') {
        gender = Gender.female;
      }
      if (gender != null) {
        ref.read(signupProvider.notifier).updateGender(gender);
      }
    }
    
    // Pre-fill address
    final addressData = profileData['Address'] ?? profileData['address'];
    if (addressData != null && addressData is Map<String, dynamic>) {
      try {
        selectedAddress = Address.fromJson(addressData);
        
        // Update address display text
        final parts = <String>[];
        if (selectedAddress!.streetName != null && selectedAddress!.streetName!.isNotEmpty) {
          parts.add(selectedAddress!.streetName!);
        }
        if (selectedAddress!.houseNumber != null) {
          parts.add(selectedAddress!.houseNumber.toString());
        }
        if (selectedAddress!.landmark != null && selectedAddress!.landmark!.isNotEmpty) {
          parts.add(selectedAddress!.landmark!);
        }
        addressController.text = parts.join(', ');
      } catch (e) {
        // If parsing fails, leave empty
      }
    }
    
    // Trigger rebuild to reflect the pre-filled data
    setState(() {});
  }

  @override
  void dispose() {
    fNameController.dispose();
    lNameController.dispose();
    dobController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _showAddressSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return AddressBottomSheet(
          initialAddress: selectedAddress,
          onAddressSaved: (Address address) {
            setState(() {
              selectedAddress = address;
              // Update the address display text
              final parts = <String>[];
              if (address.streetName != null && address.streetName!.isNotEmpty) {
                parts.add(address.streetName!);
              }
              if (address.houseNumber != null) {
                parts.add(address.houseNumber.toString());
              }
              if (address.landmark != null && address.landmark!.isNotEmpty) {
                parts.add(address.landmark!);
              }
              addressController.text = parts.join(', ');
            });
          },
        );
      },
    );
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

  Future<void> _submitProfile() async {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    // Validate required fields including address
    if (fNameController.text.isEmpty ||
        lNameController.text.isEmpty ||
        selectedDate == null ||
        selectedAddress == null ||
        selectedAddress!.coordinates == null ||
        selectedAddress!.streetName == null ||
        selectedAddress!.streetName!.isEmpty ||
        selectedAddress!.houseNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields, including address')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
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

      // Build address object with real data from AddressBottomSheet
      final address = selectedAddress!;
      final body = {
        'firstName': fNameController.text.trim(),
        'lastName': lNameController.text.trim(),
        'gender': _mapGenderToBackend(signupState.gender),
        'dateOfBirth': dobString,
        'address': {
          'street': address.streetName ?? '',
          'buildingNumber': address.houseNumber?.toString() ?? '',
          'landmark': address.landmark?.trim() ?? '', // Optional, can be empty string
          'coordinates': address.coordinates!.toJson(),
        },
      };

      var response;
      final userData = ref.read(signupProvider);

      userData.role == Role.provider
          ? response = await ApiService().putAuthenticated(
              'provider/ProviderProfile/profile',
              body
            )
          : response = await ApiService().putAuthenticated(
              'client/ClientProfile/editProfile',
              body,
            );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          
          // If profileData is provided, it means we're in edit mode (from profile page)
          // Otherwise, we're in signup flow
          if (widget.profileData != null) {
            // Edit mode: go back to profile page
            Navigator.pop(context);
          } else {
            // Signup flow: navigate based on role
            if (userData.role == Role.provider) {
              // Provider: go to services page
              Navigator.pushReplacementNamed(context, '/provider_services');
            } else {
              // Client: go to garage page
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/garage",
                (route) => false, // removes Signup & ExtendedSignup
              );
            }
          }
        }
      } else {
        String errorMessage = 'Failed to save profile';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (_) {}

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving profile: $e')));
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
                            signupState.role == Role.provider
                                ? 'Provider Information'
                                : 'Client Information',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontSize: 30,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

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
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'First name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

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
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Last name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Gender',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        DropdownButtonFormField<Gender>(
                          value: signupState.gender,
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
                              ref
                                  .read(signupProvider.notifier)
                                  .updateGender(value);
                            }
                          },
                          validator: (value) =>
                              value == null ? 'Please select a gender' : null,
                        ),
                        const SizedBox(height: 16),

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
                          validator: (value) {
                            if (selectedAddress == null ||
                                selectedAddress!.coordinates == null) {
                              return 'Please select your address';
                            }
                            return null;
                          },
                          onTap: _showAddressSheet,
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : Button(btnText: 'Proceed', onTap: _submitProfile),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
