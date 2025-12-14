import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/assets/services_dummy_json.dart';
import '../../providers/sign_up_providers.dart';
import '../../widgets/button.dart';

class OnBoardingServices extends ConsumerStatefulWidget {
  const OnBoardingServices({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnBoardingServicesState();
}

class _OnBoardingServicesState extends ConsumerState<ConsumerStatefulWidget> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _estTimeController = TextEditingController();
  final TextEditingController _servDescController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _submitForm() {
    if (_formKey.currentState!.validate()) {
      final price = _priceController.text;
      final estTime = _estTimeController.text;
      final servDesc = _servDescController.text;

      final notifier = ref.read(signupProvider.notifier);

      notifier.updateServicePrice(price);
      notifier.updateEstServiceTime(estTime);
      notifier.updateServiceDesc(servDesc);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Service details saved!')));
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Select Your Services", style: theme.textTheme.titleLarge),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),
              Text(
                "Select a service you provide*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: signupState.services.isEmpty
                    ? null
                    : signupState.services.first,
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
                  'Select Service',
                  style: GoogleFonts.poppins(fontSize: 15),
                ),
                items: services.map<DropdownMenuItem<String>>((service) {
                  return DropdownMenuItem<String>(
                    value: service["Id"],
                    child: Text(
                      "${service["Name"]}",
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(signupProvider.notifier).updateServices(value);
                  }
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please choose a service';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Price of your service*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'JD',
                  suffixStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Estimated time to finish service*",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _estTimeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixText: 'min',
                  suffixStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an estimated time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Description of the service",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _servDescController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 45,
                    horizontal: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ), // extra space so button doesn’t overlap content
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(16.0),
        child: Button(
          btnText: 'Save & Continue',
          onTap: () {
            final isValid = _submitForm();
            isValid ? Navigator.pushNamed(context, '/provider_availability') : null;
          },
        ),
      ),
    );
  }
}