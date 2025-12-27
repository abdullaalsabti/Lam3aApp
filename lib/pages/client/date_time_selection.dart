import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lamaa/models/address.dart';
import 'package:lamaa/models/service_request.dart';
import 'package:lamaa/providers/client_serviceRequest_provider.dart';
import 'package:lamaa/providers/service_categories_provider.dart';
import 'package:lamaa/widgets/location_map_card.dart';
import 'dart:convert';
import '../../models/service_category.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicles_provider.dart';
import '../../enums/payment_method.dart';
import '../../widgets/address_bottom_sheet.dart';
import '../../services/api_service.dart';

class DateTimeSelectionPage extends ConsumerStatefulWidget {
  const DateTimeSelectionPage({super.key});

  @override
  ConsumerState<DateTimeSelectionPage> createState() =>
      _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends ConsumerState<DateTimeSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Vehicle? _selectedVehicle;
  Address? clientAddress;
  String _selectedAddress = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _addressId; // Will store the address ID from client profile
  final API_KEY = "AIzaSyByCDOzdRCx0cJhxim3I-d8p0wm2--705Q";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadClientAddress();
  }

  Future<void> _loadClientAddress() async {
    setState(() {
      loading = true;

    });
    // Get client profile to get address ID
    try {
      final response = await ApiService().getAuthenticated(
        'api/client/ClientProfile/getAddress',
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(
          response.body,
        ); // assuming your ApiService returns already decoded JSON
        clientAddress = Address.fromJson(data);
      }
    } catch (e) {
      print('Error loading client address: $e');
    }
    setState(() {
      loading = false;

    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // void _showAddressSheet() {
  //   showAddressBottomSheet(context, (address) {
  //     setState(() {
  //       _selectedAddress = address;
  //     });
  //   });
  // }

  void _proceedToProviderSelection() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a vehicle')));
      return;
    }

    if (_selectedAddress.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter an address')));
      return;
    }

    // Combine date and time
    final requestedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final request = ClientServiceRequest(
      carPlateNumber: _selectedVehicle!.plateNumber,
      pickUpTime: requestedDateTime,
    );
    ref.read(serviceRequestProvider.notifier).mergeServiceRequest(request);
    // Navigate to provider selection with all data
    Navigator.pushNamed(context, '/provider_selection');
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Make it yours",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //------------------------------ Address Section ----------------------------
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: LocationMapCard(
                  latitude: clientAddress?.latitude,
                  longitude: clientAddress?.longitude,
                  loading: loading,
                  apiKey: API_KEY,
                ),
              ),
              Text(
                'Pick-up Address',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: clientAddress!.streetName,
                ),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () {},
                validator: (value) {
                  if (_selectedAddress.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              //-------------------------------- Vehicle Selection----------------------------------
              Text(
                'Select Car',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return const Text(
                      'No vehicles available. Please add a vehicle first.',
                    );
                  }
                  return PopupMenuButton<Vehicle>(
                    onSelected: (Vehicle value) {
                      setState(() {
                        _selectedVehicle = value;
                      });
                    },
                    itemBuilder: (context) => vehicles.map((vehicle) {
                      return PopupMenuItem<Vehicle>(
                        value: vehicle,
                        child: ListTile(
                          leading: const Icon(Icons.directions_car),
                          title: Text("${vehicle.brand} ${vehicle.model}"),
                          subtitle: Text("Plate: ${vehicle.plateNumber}"),
                        ),
                      );
                    }).toList(),

                    // 👇 THIS is the visible card
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          // Car icon / logo
                          const Icon(
                            Icons.directions_car,
                            size: 28,
                            color: Colors.black87,
                          ),

                          const SizedBox(width: 12),

                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedVehicle == null
                                      ? 'Select Car'
                                      : "${_selectedVehicle!.brand} ${_selectedVehicle!.model}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _selectedVehicle == null
                                      ? 'Choose your vehicle'
                                      : "${_selectedVehicle!.plateNumber}, ${_selectedVehicle!.color ?? ''}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Dropdown arrow
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  );

                  //old select a car
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading vehicles: $error'),
              ),
              const SizedBox(height: 24),

              // Date Selection
              Text(
                'When do you want the service?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text('Select Date', style: GoogleFonts.poppins(fontSize: 14)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Select date'
                            : DateFormat('EEE, MMM dd').format(_selectedDate!),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Time Selection
              Text(
                'Select Pick-up Time Slot',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedTime == null
                            ? 'Select time'
                            : _selectedTime!.format(context),
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      const Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method
              Text(
                'Payment Method',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem<PaymentMethod>(
                    value: method,
                    child: Text(method.toDisplayString()),
                  );
                }).toList(),
                onChanged: (method) {
                  setState(() {
                    _selectedPaymentMethod = method!;
                  });
                },
              ),
              const SizedBox(height: 32),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _proceedToProviderSelection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Proceed',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
