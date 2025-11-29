import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/vehicle.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'package:lamaa/providers/brands_provider.dart';
import 'package:lamaa/pages/empty_garage.dart';
import 'package:lamaa/pages/garage_add.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/enums/car_colors.dart';
import 'dart:convert';

class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Garage",
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Pre-fetch brands before navigation
              ref.read(brandsProvider.future);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GarageAdd()),
              ).then((_) {
                // Refresh vehicles when returning from add page
                ref.invalidate(vehiclesProvider);
              });
            },
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            // Pass ref to EmptyGarage so it can navigate properly
            return EmptyGarage(
              onAdd: () {
                ref.read(brandsProvider.future);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GarageAdd()),
                ).then((_) {
                  ref.invalidate(vehiclesProvider);
                });
              },
            );
          }
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(vehiclesProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 100, // Space for FAB
                  ),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleCard(
                      vehicle: vehicle,
                      onEdit: () => _showEditDialog(context, ref, vehicle),
                      onDelete: () => _showDeleteDialog(context, ref, vehicle),
                    );
                  },
                ),
              ),
              // Floating Action Button for adding vehicles
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ref.read(brandsProvider.future);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GarageAdd()),
                    ).then((_) {
                      ref.invalidate(vehiclesProvider);
                    });
                  },
                  backgroundColor: scheme.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Vehicle',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading vehicles: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(vehiclesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GarageAdd(vehicleToEdit: vehicle),
      ),
    ).then((_) {
      ref.invalidate(vehiclesProvider);
    });
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.plateNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteVehicle(context, ref, vehicle.plateNumber);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(
      BuildContext context, WidgetRef ref, String plateNumber) async {
    try {
      final response = await ApiService()
          .deleteAuthenticated('api/client/Vehicle/$plateNumber');
      
      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted successfully')),
          );
        }
        ref.invalidate(vehiclesProvider);
      } else {
        String errorMessage = 'Failed to delete vehicle';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorMessage;
        } catch (e) {
          // Use default message
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting vehicle: $e')),
        );
      }
    }
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getColorFromString(String colorStr) {
    try {
      // Map backend color strings to CarColors enum
      final colorMap = {
        'Black': CarColors.black,
        'White': CarColors.white,
        'Silver': CarColors.silver,
        'Blue': CarColors.blue,
        'Red': CarColors.red,
        'Gray': CarColors.grey,
        'Green': CarColors.green,
      };
      
      final carColor = colorMap[colorStr] ?? CarColors.black;
      return getColor(carColor);
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getCarTypeIcon(String carType) {
    switch (carType.toLowerCase()) {
      case 'sedan':
        return Icons.directions_car;
      case 'suv':
        return Icons.airport_shuttle;
      case 'bike':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getColorFromString(vehicle.color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCarTypeIcon(vehicle.carType),
            color: Colors.white,
          ),
        ),
        title: Text(
          '${vehicle.brand} ${vehicle.model}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Plate: ${vehicle.plateNumber}',
          style: GoogleFonts.poppins(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: scheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

