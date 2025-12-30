import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/vehicle.dart';
import 'package:lamaa/pages/client/client_home.dart';
import 'package:lamaa/providers/client_home_provider.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'package:lamaa/providers/brands_provider.dart';
import 'package:lamaa/pages/client/garage_add.dart';
import 'package:lamaa/services/api_service.dart';
import 'dart:convert';

import 'package:lamaa/widgets/vehicle_card.dart';

class GaragePage extends ConsumerWidget {
  const GaragePage({super.key});

  
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
        content: Text(
          'Are you sure you want to delete ${vehicle.plateNumber}?',
        ),
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

  Future<void> _deleteVehicle( BuildContext context, WidgetRef ref, String plateNumber,) async {
    try {
      final response = await ApiService().deleteAuthenticated(
        'client/Vehicle/$plateNumber',
      );

      if (response.statusCode == 200) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle deleted successfully')),
          );
        }
        ref.invalidate(vehiclesProvider);
        ref.invalidate(clientHomeProvider);
      } else {
        String errorMessage = 'Failed to delete vehicle';
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (e) {
          // Use default message
        }

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting vehicle: $e')));
      }
    }
  }



  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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

        // ===================== EMPTY GARAGE =====================
        if (vehicles.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(vehiclesProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    
                    // Empty Garage Illustration
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Image.asset(
                        'lib/assets/images/empty_garage.png',
                        width: MediaQuery.of(context).size.width * 0.6,
                        height: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.directions_car_outlined,
                              size: 100,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Your garage is empty',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Add your first vehicle to start booking\ncar services with Lam3a',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Add Vehicle Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref.read(brandsProvider.future);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GarageAdd(),
                            ),
                          ).then((_) {
                            ref.invalidate(vehiclesProvider);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Add Your First Vehicle',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skip Button
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          "/main_page",
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Skip for now',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),

                    // Bottom spacing for pull-to-refresh
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          );
        }

        // ===================== GARAGE HAS VEHICLES =====================
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(vehiclesProvider);
          },
          child: Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: 80, // Extra padding for FAB
                ),
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return VehicleCard(
                    vehicle: vehicle,
                    onEdit: () => _showEditDialog(context, ref, vehicle),
                    onDelete: () => _showDeleteDialog(context, ref, vehicle),
                  );
                },
              ),
              // Floating Action Button
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ref.read(brandsProvider.future);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GarageAdd(),
                      ),
                    ).then((_) {
                      ref.invalidate(vehiclesProvider);
                    });
                  },
                  backgroundColor: scheme.primary,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Vehicle',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },

      // ===================== LOADING =====================
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      // ===================== ERROR =====================
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
}