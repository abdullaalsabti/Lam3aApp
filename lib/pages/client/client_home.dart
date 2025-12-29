import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/pages/client/all_services.dart';
import 'package:lamaa/providers/client_serviceRequest_provider.dart';
import '../../providers/client_home_provider.dart';
import '../../models/client_home.dart';
import '../../models/vehicle.dart';
import '../../models/service_category.dart';

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  Vehicle? _selectedVehicle;

  @override
  Widget build(BuildContext context) {
    final homeDataAsync = ref.watch(clientHomeProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: homeDataAsync.when(
        data: (homeData) {
          // Set default selected vehicle if not set
          if (_selectedVehicle == null && homeData.vehicles.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _selectedVehicle == null) {
                setState(() {
                  _selectedVehicle = homeData.vehicles.first;
                });
              }
            });
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15,),
                  // Lam3a Points Banner
                  _Lam3aPointsBanner(scheme: scheme,),
            
                  const SizedBox(height: 24),
            
                  // Popular Services Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Services',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (builder)=> AllServices(services: homeData.services)));
                          },
                          child: Text(
                            'see all →',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: homeData.services.length > 5 ? 5 : homeData.services.length,
                      itemBuilder: (context, index) {
                        final service = homeData.services[index];
                        return _ServiceCard(service: service , ref: ref,scheme:  scheme,);
                      },
                    ),
                  ),
            
                  const SizedBox(height: 24),
            
                  // Popular Providers Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Popular Providers',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Navigate to all providers page when implemented
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Providers page coming soon!')),
                            );
                          },
                          child: Text(
                            'see all →',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: homeData.serviceProviders.length > 5 ? 5 : homeData.serviceProviders.length,
                      itemBuilder: (context, index) {
                        final provider = homeData.serviceProviders[index];
                        return _ProviderCard(provider: provider);
                      },
                    ),
                  ),
            
            
                
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading home data: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(clientHomeProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final String address;

  const _LocationSelector({required this.address});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement location selection/editing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location editing coming soon!')),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                address.isEmpty ? 'Select location' : address,
                style: GoogleFonts.poppins(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _VehicleSelector extends StatelessWidget {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final Function(Vehicle) onVehicleSelected;

  const _VehicleSelector({
    required this.vehicles,
    required this.selectedVehicle,
    required this.onVehicleSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.grey, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No vehicles',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Vehicle',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...vehicles.map((vehicle) => ListTile(
                      leading: const Icon(Icons.directions_car),
                      title: Text('${vehicle.brand} ${vehicle.model}'),
                      subtitle: Text(vehicle.plateNumber),
                      onTap: () {
                        onVehicleSelected(vehicle);
                        Navigator.pop(context);
                      },
                    )),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.directions_car, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedVehicle != null
                        ? '${selectedVehicle!.brand} ${selectedVehicle!.model}'
                        : 'Select vehicle',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedVehicle != null)
                    Text(
                      selectedVehicle!.plateNumber,
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Lam3aPointsBanner extends StatelessWidget {
  _Lam3aPointsBanner({required this.scheme});

   ColorScheme scheme;
  @override
  Widget build(BuildContext context ) {
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We have introduced',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lam3a Points',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.card_giftcard, size: 60, color: Colors.blue),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceCategory service;

   _ServiceCard({required this.service , required this.ref , required this.scheme});
  final WidgetRef ref;
  ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(serviceRequestProvider.notifier).setCategory(service);
        Navigator.pushNamed(
          context,
          '/date_time_selection'
        );
      },
      child: Container(
        width: 120,
        margin:  EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset:  Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.local_car_wash, size: 60, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final PopularProvider provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 30),
          ),
          const SizedBox(width: 12),
          // Provider Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.isAvailable ? 'Available' : 'Unavailable',
                  style: GoogleFonts.poppins(
                    fontSize: 12, 
                    color: provider.isAvailable ? Colors.green : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      provider.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg. Price ${provider.averagePrice.toStringAsFixed(0)} JOD',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  'Projects completed ${provider.projectsCount}',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
