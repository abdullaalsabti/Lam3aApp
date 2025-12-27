import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/address.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/widgets/error_message.dart';
import 'package:lamaa/widgets/location_map_card.dart';

class AddressBottomSheet extends StatefulWidget {
  AddressBottomSheet({super.key, required this.onAddressSaved});

  void Function(Address address) onAddressSaved;
  @override
  State<AddressBottomSheet> createState() => _AddressBottomSheetState();
}

class _AddressBottomSheetState extends State<AddressBottomSheet> {
  bool loadingLocation = false;
  final formkey = GlobalKey<FormState>();
  final TextEditingController houseController = TextEditingController();
  final TextEditingController landmarkController = TextEditingController();
  Address? _address;
  final apiService = ApiService();
  final API_KEY = "AIzaSyByCDOzdRCx0cJhxim3I-d8p0wm2--705Q";
  String? errorMessage;

  String get locationImage {
    final lat = _address!.latitude;
    final lng = _address!.longitude;
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng'
        '&zoom=16'
        '&size=600x300'
        '&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C$lat,$lng'
        '&key=$API_KEY';
  }

  void onPressed() {
    // Validate that coordinates are present (user must use "get current location")
    if (_address == null ||
        _address!.latitude == null ||
        _address!.longitude == null) {
      setState(() {
        errorMessage = 'please put your location first';
      });
      return;
    }

    // Clear error message if validation passes
    setState(() {
      errorMessage = null;
    });

    if (formkey.currentState!.validate()) {
      // Build address string
      String houseNumber = houseController.text.trim();
      String landmark = landmarkController.text.trim();

      _address!.houseNumber = houseNumber;
      _address!.landmark = landmark;
      print(_address!.address == null ? "address is null" : _address!.address);

      // Return the address via callback and close the bottom sheet
      widget.onAddressSaved(_address!);
      Navigator.pop(context);
    }
  }

  //a function to get the street name from the body
  String? getStreetName(Map<String, dynamic> data) {
    final results = data['results'] as List<dynamic>?;

    if (results != null && results.isNotEmpty) {
      final components = results[0]['address_components'] as List<dynamic>;

      for (var component in components) {
        final types = component['types'] as List<dynamic>;
        if (types.contains('route')) {
          return component['long_name'] as String?;
        }
      }
    }

    return null; // if not found
  }

  Future<Position> getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          loadingLocation = false;
          errorMessage =
              'Location services are disabled. Please enable them in settings.';
        });
        throw Exception('Location services are disabled');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            loadingLocation = false;
            errorMessage =
                'Location permission is required to get your address';
          });
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          loadingLocation = false;
          errorMessage =
              'Location permission permanently denied. Please enable it in app settings.';
        });
        throw Exception('Location permission permanently denied');
      }

      setState(() {
        loadingLocation = true;
        errorMessage = null; // Clear any previous error messages
      });

      Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Create Address object first with coordinates
      String? formattedAddress;
      String? streetName;

      try {
        // Use Uri to safely encode the URL
        final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
          'latlng': '${location.latitude},${location.longitude}',
          'key': API_KEY,
        });

        final response = await http.get(uri);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("data is $data");

          formattedAddress = data['results'][0]['formatted_address'][1];
          streetName = getStreetName(data);
        }
      } catch (ex) {
        print("Error calling geocoding API: $ex");
        setState(() {
          errorMessage =
              "Error retrieving address. Coordinates saved but address may be incomplete.";
        });
      }

      setState(() {
        _address = Address(
          latitude: location.latitude,
          longitude: location.longitude,
          address: formattedAddress,
          streetName: streetName,
        );
        loadingLocation = false;
        errorMessage = null; // Clear error on success
      });

      return location;
    } catch (e) {
      setState(() {
        loadingLocation = false;
      });
      // Error messages are already shown in the permission checks above
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget locationPreview = ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: LocationMapCard(
        latitude: _address?.latitude,
        longitude: _address?.longitude,
        loading: loadingLocation,
        apiKey: API_KEY,
      ),
    );

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

              Text(
                'Please select your location on the map',
                style: GoogleFonts.poppins(fontSize: 14),
              ),

              SizedBox(height: 3),
              // Map placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: locationPreview,
              ),

              // Error message display under the map
              if (errorMessage != null) ...[
                SizedBox(height: 8),
                ErrorMessage(errorMessage: errorMessage!),
              ],

              const SizedBox(height: 8),

              //get current location buton
              TextButton.icon(
                onPressed: () async {
                  try {
                    await getUserLocation();
                  } catch (e) {
                    // Error messages are already shown in getUserLocation
                    print("Error getting user location: $e");
                  }
                },
                icon: Icon(Icons.pin_drop),
                label: Text("get current location"),
              ),

              SizedBox(height: 20),

              // House number field
              TextFormField(
                keyboardType: TextInputType.number,
                controller: houseController,
                decoration: InputDecoration(
                  labelText: 'House number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
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
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
                  onPressed: onPressed,
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
  }
}
