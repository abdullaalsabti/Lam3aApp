import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/providers/providers.dart';
import '../widgets/button.dart';
import 'package:lamaa/enums/enums.dart';
import 'package:lamaa/pages/address_bottom_sheet.dart';
import 'package:intl/intl.dart';

class ExtendedSignUp extends ConsumerStatefulWidget {
  const ExtendedSignUp({super.key});

  @override
  ConsumerState<ExtendedSignUp> createState() => _PhoneSignUpState();
}

class _PhoneSignUpState extends ConsumerState<ExtendedSignUp> {
  final formKey = GlobalKey<FormState>();

  //Controllers
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  DateTime? selectedDate;
  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);


    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
          dobController.text = DateFormat('dd/MM/yyyy').format(picked);
          // Update Riverpod provider if needed
          ref.read(signupProvider.notifier).state =
              ref.read(signupProvider.notifier).state.copyWith(dob: dobController.text);
        });
      }
    }

    @override
    void dispose() {
      fNameController.dispose();
      lNameController.dispose();
      dobController.dispose();
      addressController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 70),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    'Personal Information',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 30,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'First Name',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      TextFormField(
                        style: GoogleFonts.poppins(fontSize: 20),
                        controller: fNameController,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      Text(
                        'Last Name',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        style: GoogleFonts.poppins(fontSize: 20),
                        controller: lNameController,
                        decoration: InputDecoration(
                          hintStyle: GoogleFonts.poppins(fontSize: 20),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 10
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<Gender>(
                      value: ref.watch(signupProvider).gender as Gender?, // initial value from provider
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      hint: Text(
                        'Select Gender',
                        style: GoogleFonts.poppins(fontSize: 15),
                      ),
                      items: Gender.values.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(
                            gender.name[0].toUpperCase() + gender.name.substring(1),
                            style: GoogleFonts.poppins(fontSize: 15),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(signupProvider.notifier).state =
                              ref.read(signupProvider.notifier).state.copyWith(gender: value);
                        }
                      },
                      validator: (value) => value == null ? 'Please select a gender' : null,
                    ),

                    SizedBox(height: 10),

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Birth',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            controller: dobController,
                            readOnly: true, // prevent manual input
                            decoration: InputDecoration(
                              hintText: 'Select Date of Birth',
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: () => selectDate(context),
                            validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
                          )
                        ]
                      ),

                    SizedBox(height: 10),

                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 5),
                          TextFormField(
                            readOnly: true,
                            style: GoogleFonts.poppins(fontSize: 20),
                            decoration: InputDecoration(
                              hintStyle: GoogleFonts.poppins(fontSize: 20),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onTap: () => showAddressBottomSheet(context)
                            ,
                          ),
                          SizedBox(height: 180),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Button(btnText: 'Proceed', onTap: () {}),
                          ),
                        ]
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}