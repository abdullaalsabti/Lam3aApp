import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../models/service_category.dart';
import '../../models/vehicle.dart';
import '../../providers/vehicles_provider.dart';
import '../../enums/payment_method.dart';
import '../../widgets/address_bottom_sheet.dart';
import '../../services/api_service.dart';

class DateTimeSelectionPage extends ConsumerStatefulWidget {
  final ServiceCategory category;

  const DateTimeSelectionPage({super.key, required this.category});

  @override
  ConsumerState<DateTimeSelectionPage> createState() => _DateTimeSelectionPageState();
}

class _DateTimeSelectionPageState extends ConsumerState<DateTimeSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Vehicle? _selectedVehicle;
  String _selectedAddress = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;
  String? _addressId; // Will store the address ID from client profile

  @override
  void initState() {
    super.initState();
    _loadClientAddress();
  }

  Future<void> _loadClientAddress() async {
    // Get client profile to get address ID
    try {
      final response = await ApiService().getAuthenticated('api/client/ClientProfile/getProfile');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = (data['Address'] ?? data['address']) as Map<String, dynamic>?;

        final addressId = address?['AddressId']?.toString() ?? address?['addressId']?.toString();
        final street = address?['Street']?.toString() ?? address?['street']?.toString();
        final building = address?['BuildingNumber']?.toString() ?? address?['buildingNumber']?.toString();
        final landmark = address?['Landmark']?.toString() ?? address?['landmark']?.toString();

        if (mounted) {
          setState(() {
            _addressId = addressId;
            // Pre-fill address display from profile (optional)
            final parts = <String>[
              if (street != null && street.isNotEmpty) street,
              if (building != null && building.isNotEmpty) building,
              if (landmark != null && landmark.isNotEmpty) landmark,
            ];
            if (parts.isNotEmpty) {
              _selectedAddress = parts.join(', ');
            }
          });
        }
      }
    } catch (e) {
      print('Error loading client address: $e');
    }
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

  void _showAddressSheet() {
    showAddressBottomSheet(context, (address) {
      setState(() {
        _selectedAddress = address;
      });
    });
  }

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    if (_selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an address')),
      );
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

    // Navigate to provider selection with all data
    Navigator.pushNamed(
      context,
      '/provider_selection',
      arguments: {
        'category': widget.category,
        'requestedDateTime': requestedDateTime,
        'vehicle': _selectedVehicle,
        'address': _selectedAddress,
        'addressId': _addressId ?? '', // Use actual address ID
        'paymentMethod': _selectedPaymentMethod,
      },
    );
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
              // Address Section
              Text(
                'Pick-up Address',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _selectedAddress.isEmpty ? 'Tap to enter address' : _selectedAddress),
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onTap: _showAddressSheet,
                validator: (value) {
                  if (_selectedAddress.isEmpty) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Vehicle Selection
              Text(
                'Select Car',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return const Text('No vehicles available. Please add a vehicle first.');
                  }
                  return DropdownButtonFormField<Vehicle>(
                    value: _selectedVehicle,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    hint: const Text('Select a vehicle'),
                    items: vehicles.map((vehicle) {
                      return DropdownMenuItem<Vehicle>(
                        value: vehicle,
                        child: Text('${vehicle.brand} ${vehicle.model} - ${vehicle.plateNumber}'),
                      );
                    }).toList(),
                    onChanged: (vehicle) {
                      setState(() {
                        _selectedVehicle = vehicle;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a vehicle';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error loading vehicles: $error'),
              ),
              const SizedBox(height: 24),

              // Date Selection
              Text(
                'When do you want the service?',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Select Date',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
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
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
