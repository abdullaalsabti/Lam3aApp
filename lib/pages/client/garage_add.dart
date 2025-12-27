import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/enums/car_type.dart';
import 'package:lamaa/models/car_brand.dart';
import 'package:lamaa/models/car_model.dart';
import 'package:lamaa/pages/client/main_page.dart';
import 'package:lamaa/providers/car_provider.dart';
import 'package:lamaa/providers/brands_provider.dart';
import 'package:lamaa/providers/client_home_provider.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'package:lamaa/models/vehicle.dart';
import 'package:lamaa/widgets/button.dart';
import 'package:lamaa/widgets/select_car_color.dart';
import 'package:lamaa/enums/car_colors.dart';
import 'package:lamaa/services/api_service.dart';
import 'dart:convert';

class GarageAdd extends ConsumerStatefulWidget {
  final Vehicle? vehicleToEdit; // For editing mode
  const GarageAdd({super.key, this.vehicleToEdit});

  @override
  ConsumerState<GarageAdd> createState() => _GarageAddState();
}

class _GarageAddState extends ConsumerState<GarageAdd> {
  final List<Map<String, dynamic>> vehicleTypes = [
    {'image': 'lib/assets/images/sedan_car.png', 'label': 'Sedan'},
    {'image': 'lib/assets/images/suv_car.png', 'label': 'SUV'},
  ];

  final TextEditingController _plateController = TextEditingController();
  String? _originalPlateNumber; // Store original plate number for editing

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with vehicle data
    if (widget.vehicleToEdit != null) {
      final vehicle = widget.vehicleToEdit!;
      _plateController.text = vehicle.plateNumber;
      _originalPlateNumber = vehicle.plateNumber;
      // Note: We'll need to set brand/model/color/type from vehicle data
      // This requires finding the brand/model by name, which we'll do after brands load
    }
  }

  // Helper to map Frontend colors to Backend Enum strings
  String _mapColorToBackend(CarColors color) {
    switch (color) {
      case CarColors.black:
        return "Black";
      case CarColors.white:
        return "White";
      case CarColors.silver:
        return "Silver";
      case CarColors.blue:
        return "Blue";
      case CarColors.navy:
        return "Blue";
      case CarColors.petrol:
        return "Blue";
      case CarColors.red:
        return "Red";
      case CarColors.whine:
        return "Red";
      case CarColors.orange:
        return "Red";
      case CarColors.pink:
        return "Red";
      case CarColors.grey:
        return "Gray"; // Note spelling: Gray vs Grey
      case CarColors.green:
        return "Green";
      default:
        return "Gray";
    }
  }

  String _mapTypeToBackend(CarType type) {
    switch (type) {
      case CarType.sedan:
        return "Sedan";
      case CarType.suv:
        return "Suv";
    }
  }

  void addVehicleToGarage() async {
    final carSelection = ref.read(carSelectionProvider);

    if (carSelection.selectedType != null &&
        carSelection.selectedBrand != null &&
        carSelection.selectedModel != null &&
        carSelection.selectedColor != null &&
        _plateController.text.isNotEmpty) {
      try {
        final body = {
          'plateNumber': _plateController.text,
          'brandId': int.parse(carSelection.selectedBrand!.id),
          'modelId': int.parse(carSelection.selectedModel!.id),
          'color': _mapColorToBackend(carSelection.selectedColor!),
          'carType': _mapTypeToBackend(carSelection.selectedType!),
        };

        final bool isEditing = _originalPlateNumber != null;
        final response = isEditing
            ? await ApiService().putAuthenticated(
                'api/client/Vehicle/$_originalPlateNumber',
                body,
              )
            : await ApiService().postAuthenticated(
                'api/client/Vehicle/addVehicle',
                body,
              );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEditing
                      ? 'Vehicle updated successfully!'
                      : 'Vehicle added successfully!',
                ),
              ),
            );
            // Refresh vehicles list
            ref.invalidate(vehiclesProvider);
            ref.invalidate(clientHomeProvider);

            // Navigate to garage page after adding/editing
            if (isEditing) {
              Navigator.pop(context);
             } // Just go back if editing
             
              Navigator.push(context, MaterialPageRoute(builder: (ctx)=> MainPage()));
          }
        } else {

          String errorMessage =
              'Failed to ${isEditing ? 'update' : 'add'} vehicle';
          try {
            final errorBody = jsonDecode(response.body);
            errorMessage =
                errorBody['message'] ?? errorMessage;
          } catch (e) {
            // Use default message
          }

          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(errorMessage)));
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error connecting to server: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all selections and plate number'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _originalPlateNumber != null;
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final carSelection = ref.watch(carSelectionProvider);
    final notifier = ref.read(carSelectionProvider.notifier);

    // Watch brands from provider (fetched in background)
    final brandsAsync = ref.watch(brandsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Garage",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: SafeArea(
        // The main body is a Column to stack the scrollable content and the fixed button
        child: Column(
          children: [
            // Expanded allows the content above the button to take up remaining space and scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 34),
                      child: Text(
                        widget.vehicleToEdit != null
                            ? 'Edit vehicle'
                            : 'Add a vehicle',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your type of vehicle',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30),

                    // Vehicle Type Selector
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: vehicleTypes.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicleTypes[index];
                          final isSelected =
                              carSelection.selectedType?.index == index;
                          final selectedCarType = CarType.values[index];

                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  notifier.selectType(selectedCarType);
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? scheme.primary.withOpacity(0.5)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? scheme.primary
                                          : Colors.grey[300]!,
                                      width: isSelected ? 3 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: scheme.primary.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        height: 90,
                                        child: Image.asset(
                                          vehicle['image'],
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.directions_car,
                                                  size: 60,
                                                  color: isSelected
                                                      ? scheme.primary
                                                      : Colors.grey[600],
                                                );
                                              },
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vehicle['label'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? scheme.primary
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Car Brand, Model, and Color Selectors
                    // Note: Padding was moved to the SingleChildScrollView above
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Car Brand',
                          style: theme.textTheme.bodyLarge,
                        ),
                        brandsAsync.when(
                          data: (brands) => DropdownMenu<CarBrand>(
                            enableFilter: true,
                            enableSearch: true,
                            initialSelection: carSelection.selectedBrand,
                            onSelected: (CarBrand? value) {
                              if (value != null) {
                                notifier.selectBrand(value);
                              }
                            },
                            width: MediaQuery.of(context).size.width - 32,
                            dropdownMenuEntries: brands
                                .map(
                                  (b) => DropdownMenuEntry(
                                    value: b,
                                    label: b.brand,
                                  ),
                                )
                                .toList(),
                          ),
                          loading: () => const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (error, stack) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Error loading brands: $error',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Select Your Car Model',
                          style: theme.textTheme.bodyLarge,
                        ),
                        DropdownMenu<CarModel>(
                          enableFilter: true,
                          enableSearch: true,
                          key: ValueKey(carSelection.selectedBrand?.id),
                          initialSelection: carSelection.selectedModel,
                          enabled:
                              brandsAsync.hasValue &&
                              carSelection.selectedBrand != null,
                          onSelected: (CarModel? value) {
                            if (value != null) {
                              notifier.selectModel(value);
                            }
                          },
                          width:
                              MediaQuery.of(context).size.width -
                              32, // Adjust to fill screen
                          dropdownMenuEntries:
                              (carSelection.selectedBrand?.models ?? [])
                                  .map(
                                    (m) => DropdownMenuEntry(
                                      value: m,
                                      label: m.name,
                                    ),
                                  )
                                  .toList(),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Enter Car Plate Number',
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width:
                              MediaQuery.of(context).size.width -
                              32, // same width as DropdownMenu
                          height: 55, // adjust as needed
                          child: TextFormField(
                            controller: _plateController,
                            enabled: isEditing ? false : true,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'e.g. 12345',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 16,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter plate number';
                              }
                              final plateRegExp = RegExp(r'^\d{2,7}$');

                              if (!plateRegExp.hasMatch(value)) {
                                return 'Plate number must be 2 to 7 digits (e.g., 12, 123, 1234567)';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Select color of your vehicle',
                          style: theme.textTheme.bodyLarge,
                        ),
                        SizedBox(height: 20),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var clr in CarColors.values)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ColorButton(
                                    selectedColor: getColor(clr),
                                    isSelected:
                                        carSelection.selectedColor == clr,
                                    onTap: () => notifier.selectColor(clr),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20), // Add spacing for scroll
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Bottom Button (Fixed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: double.infinity,
              child: Button(
                btnText: widget.vehicleToEdit != null
                    ? 'Update Vehicle'
                    : 'Add to Garage',
                onTap: addVehicleToGarage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
