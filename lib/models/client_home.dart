import 'service_category.dart';
import 'vehicle.dart';
import 'address.dart';

class ClientHomeData {
  final List<Vehicle> vehicles;
  final Address address;
  final List<PopularProvider> serviceProviders;
  final List<ServiceCategory> services;
  final String clientId;

  ClientHomeData({
    required this.clientId,
    required this.vehicles,
    required this.address,
    required this.serviceProviders,
    required this.services,
  });

  factory ClientHomeData.fromJson(Map<String, dynamic> json) {
    return ClientHomeData(
      clientId: (json["clientId"] as String),
      vehicles: ((json['Vehicles'] ?? json['vehicles']) as List? ?? [])
          .map((v) => Vehicle.fromJson(v))
          .toList(),
      address: Address.fromJson(json['Address'] ?? json['address'] ?? {}),
      serviceProviders: ((json['ServiceProviders'] ?? json['serviceProviders']) as List? ?? [])
          .map((p) => PopularProvider.fromJson(p))
          .toList(),
      services: ( json['services'] as List? ?? [])
          .map((s) {
            // Debug: Print raw service data to verify structure
            print('Raw service data: $s');
            final category = ServiceCategory.fromJson(s);
            print('Parsed category - id: ${category.id}, name: ${category.name}');
            return category;
          })
          .toList(),
    );
  }
}

class PopularProvider {
  final String id;
  final String name;
  final bool isAvailable;
  final double rating;
  final double averagePrice;
  final int projectsCount;

  PopularProvider({
    required this.id,
    required this.name,
    required this.isAvailable,
    required this.rating,
    required this.averagePrice,
    required this.projectsCount,
  });

  factory PopularProvider.fromJson(Map<String, dynamic> json) {
    return PopularProvider(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      isAvailable: json['IsAvailable'] ?? json['isAvailable'] ?? false,
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
      averagePrice: (json['AveragePrice'] ?? json['averagePrice'] ?? 0).toDouble(),
      projectsCount: json['ProjectsCount'] ?? json['projectsCount'] ?? 0,
    );
  }
}
