import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/enums/car_type.dart';
import 'package:lamaa/models/car_brand.dart';
import 'package:lamaa/models/car_model.dart';
import 'package:lamaa/dummy_garage_json.dart';
import 'package:lamaa/providers/car_provider.dart';
import 'package:lamaa/widgets/button.dart';
import 'package:lamaa/widgets/select_car_color.dart';
import 'package:lamaa/enums/car_colors.dart';

class GarageAdd extends ConsumerStatefulWidget {
  const GarageAdd({super.key});

  @override
  ConsumerState<GarageAdd> createState() => _GarageAddState();
}

class _GarageAddState extends ConsumerState<GarageAdd> {
  final List<Map<String, dynamic>> vehicleTypes = [
    {'image': 'lib/assets/images/sedan_car.png', 'label': 'Sedan'},
    {'image': 'lib/assets/images/suv_car.png', 'label': 'SUV'},
  ];

  final brands = dummyJson.map((b) => CarBrand.fromJson(b)).toList();

  void addVehicleToGarage() {
    final carSelection = ref.read(carSelectionProvider);
    // TODO: Implement logic to save the selected car to the garage
    if (carSelection.selectedType != null &&
        carSelection.selectedBrand != null &&
        carSelection.selectedModel != null &&
        carSelection.selectedColor != null) {
      print("Vehicle added successfully:");
      print("Type: ${carSelection.selectedType}");
      print("Brand: ${carSelection.selectedBrand!.brand}");
      print("Model: ${carSelection.selectedModel!.name}");
      print("Color: ${carSelection.selectedColor}");
      // Navigator.pop(context); // Example: navigate back after saving
    } else {
      // Handle validation error if fields are incomplete
      print("Validation failed: Please complete all selections.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final carSelection = ref.watch(carSelectionProvider);
    final notifier = ref.read(carSelectionProvider.notifier);

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
                        'Add a vehicle',
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
                                        color: scheme.primary
                                            .withOpacity(0.3),
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
                        DropdownMenu<CarBrand>(
                          enableFilter: true,
                          enableSearch: true,
                          initialSelection: carSelection.selectedBrand,
                          onSelected: (CarBrand? value) {
                            if (value != null) {
                              notifier.selectBrand(value);
                            }
                          },
                          width: MediaQuery.of(context).size.width - 32, // Adjust to fill screen
                          dropdownMenuEntries: brands
                              .map(
                                (b) => DropdownMenuEntry(
                                value: b, label: b.brand),
                          )
                              .toList(),
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
                          enabled: carSelection.selectedBrand != null,
                          onSelected: (CarModel? value) {
                            if (value != null) {
                              notifier.selectModel(value);
                            }
                          },
                          width: MediaQuery.of(context).size.width - 32, // Adjust to fill screen
                          dropdownMenuEntries:
                          (carSelection.selectedBrand?.models ?? [])
                              .map(
                                (m) => DropdownMenuEntry(
                                value: m, label: m.name),
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
                          width: MediaQuery.of(context).size.width - 32, // same width as DropdownMenu
                          height: 55, // adjust as needed
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'e.g. 12-12345',
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter plate number';
                              }
                              final plateRegExp = RegExp(r'^\d{2}-\d{5}$');
                              if (!plateRegExp.hasMatch(value)) {
                                return 'Plate number must be in format 12-12345';
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
                btnText: 'Add to Garage',
                onTap: ()
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to Garage'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}