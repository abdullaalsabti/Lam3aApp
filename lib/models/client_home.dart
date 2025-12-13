import 'service_category.dart';
import 'vehicle.dart';

class ClientHomeData {
  final List<Vehicle> vehicles;
  final AddressData address;
  final List<PopularProvider> serviceProviders;
  final List<ServiceCategory> services;

  ClientHomeData({
    required this.vehicles,
    required this.address,
    required this.serviceProviders,
    required this.services,
  });

  factory ClientHomeData.fromJson(Map<String, dynamic> json) {
    return ClientHomeData(
      vehicles: ((json['Vehicles'] ?? json['vehicles']) as List? ?? [])
          .map((v) => Vehicle.fromJson(v))
          .toList(),
      address: AddressData.fromJson(json['Address'] ?? json['address'] ?? {}),
      serviceProviders: ((json['ServiceProviders'] ?? json['serviceProviders']) as List? ?? [])
          .map((p) => PopularProvider.fromJson(p))
          .toList(),
      services: ((json['Services'] ?? json['services']) as List? ?? [])
          .map((s) => ServiceCategory.fromJson(s))
          .toList(),
    );
  }
}

class AddressData {
  final String street;
  final String buildingNumber;
  final String landmark;
  final CoordinatesData coordinates;

  AddressData({
    required this.street,
    required this.buildingNumber,
    required this.landmark,
    required this.coordinates,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      street: json['Street'] ?? json['street'] ?? '',
      buildingNumber: json['BuildingNumber'] ?? json['buildingNumber'] ?? '',
      landmark: json['Landmark'] ?? json['landmark'] ?? '',
      coordinates: CoordinatesData.fromJson(json['Coordinates'] ?? json['coordinates'] ?? {}),
    );
  }

  String get fullAddress {
    final parts = [street, buildingNumber, landmark].where((p) => p.isNotEmpty).toList();
    return parts.join(', ');
  }
}

class CoordinatesData {
  final double latitude;
  final double longitude;

  CoordinatesData({
    required this.latitude,
    required this.longitude,
  });

  factory CoordinatesData.fromJson(Map<String, dynamic> json) {
    return CoordinatesData(
      latitude: (json['Latitude'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'] ?? 0).toDouble(),
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
