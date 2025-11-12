import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAddressBottomSheet(BuildContext context) {
  final formkey = GlobalKey<FormState>();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close + Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      'Address info',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Map placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/map_placeholder.png',
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Please select your location on the map',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                const SizedBox(height: 20),

                // House number field
                TextFormField(
                  controller: houseController,
                  decoration: InputDecoration(
                    labelText: 'House number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter house number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                // Landmark field
                TextFormField(
                  controller: landmarkController,
                  decoration: InputDecoration(
                    labelText: 'Landmark (Optional)',
                    hintText: 'Select landmark close to your address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  'Landmarks could be schools, supermarkets, popular places around your address.',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 25),

                // Save button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF157B72),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (formkey.currentState!.validate()) {
                        // You can access the values here
                        String house = houseController.text;
                        String landmark = landmarkController.text;

                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'Save and Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}