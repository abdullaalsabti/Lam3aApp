import 'package:lamaa/models/client_home.dart';

import '../enums/service_status.dart';
import '../enums/payment_method.dart';
import 'service_category.dart';


class ClientServiceRequest {
  final String? carPlateNumber;
  final String? clientId;
  final String? providerId;
  final ServiceCategory? category;
  final DateTime? pickUpTime;
  final CoordinatesData? coordinates;
  final PaymentMethod? paymentMethod;

  const ClientServiceRequest({
    this.carPlateNumber,
    this.clientId,
    this.providerId,
    this.category,
    this.pickUpTime,
    this.coordinates,
    this.paymentMethod,
  });

  ClientServiceRequest copyWith({
    String? carPlateNumber,
    String? clientId,
    String? providerId,
    ServiceCategory? category,
    DateTime? pickUpTime,
    CoordinatesData? coordinates,
    PaymentMethod? paymentMethod,
  }) {
    return ClientServiceRequest(
      carPlateNumber: carPlateNumber ?? this.carPlateNumber,
      clientId: clientId ?? this.clientId,
      providerId: providerId ?? this.providerId,
      category: category ?? this.category,
      pickUpTime: pickUpTime ?? this.pickUpTime,
      coordinates: coordinates ?? this.coordinates,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class ServiceRequest {
  final String id;
  final String vehiclePlateNumber;
  final DateTime requestedDateTime;
  final PaymentMethod paymentMethod;
  final ServiceStatus status;
  final String serviceProviderId;
  final String serviceId;
  final ServiceCategory? category;
  final ProviderInfo? provider;
  final VehicleInfo? vehicle;
  final AddressInfo? address;
  final ServiceInfo? service;

  ServiceRequest({
    required this.id,
    required this.vehiclePlateNumber,
    required this.requestedDateTime,
    required this.paymentMethod,
    required this.status,
    required this.serviceProviderId,
    required this.serviceId,
    this.category,
    this.provider,
    this.vehicle,
    this.address,
    this.service,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      vehiclePlateNumber: json['VehiclePlateNumber'] ?? json['vehiclePlateNumber'] ?? '',
      requestedDateTime: DateTime.parse(json['RequestedDateTime'] ?? json['requestedDateTime'] ?? DateTime.now().toIso8601String()),
      paymentMethod: PaymentMethod.fromString(json['PaymentMethod']?.toString() ?? json['paymentMethod']?.toString() ?? 'Cash'),
      status: ServiceStatus.fromString(json['Status']?.toString() ?? json['status']?.toString() ?? 'OrderPlaced'),
      serviceProviderId: json['ServiceProviderId']?.toString() ?? json['serviceProviderId']?.toString() ?? '',
      serviceId: json['ServiceId']?.toString() ?? json['serviceId']?.toString() ?? '',
      category: json['Category'] != null ? ServiceCategory.fromJson(json['Category']) : 
                json['category'] != null ? ServiceCategory.fromJson(json['category']) : null,
      provider: json['Provider'] != null ? ProviderInfo.fromJson(json['Provider']) :
                json['provider'] != null ? ProviderInfo.fromJson(json['provider']) : null,
      vehicle: json['Vehicle'] != null ? VehicleInfo.fromJson(json['Vehicle']) :
              json['vehicle'] != null ? VehicleInfo.fromJson(json['vehicle']) : null,
      address: json['Address'] != null ? AddressInfo.fromJson(json['Address']) :
              json['address'] != null ? AddressInfo.fromJson(json['address']) : null,
      service: json['Service'] != null ? ServiceInfo.fromJson(json['Service']) :
              json['service'] != null ? ServiceInfo.fromJson(json['service']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehiclePlateNumber': vehiclePlateNumber,
      'requestedDateTime': requestedDateTime!.toIso8601String(),
      'paymentMethod': paymentMethod!.name,
      'status': status!.name,
      'serviceProviderId': serviceProviderId,
      'serviceId': serviceId,
      'category': category?.toJson(),
      'provider': provider?.toJson(),
      'vehicle': vehicle?.toJson(),
      'address': address?.toJson(),
      'service': service?.toJson(),
    };
  }
}

class ProviderInfo {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;
  final double rating;

  ProviderInfo({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.rating,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      userId: json['UserId']?.toString() ?? json['userId']?.toString() ?? '',
      firstName: json['FirstName'] ?? json['firstName'] ?? '',
      lastName: json['LastName'] ?? json['lastName'] ?? '',
      phone: json['Phone'] ?? json['phone'] ?? '',
      rating: (json['Rating'] ?? json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'rating': rating,
    };
  }
}

class VehicleInfo {
  final String plateNumber;
  final String brand;
  final String model;
  final String color;
  final String carType;

  VehicleInfo({
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.color,
    required this.carType,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      plateNumber: json['PlateNumber'] ?? json['plateNumber'] ?? '',
      brand: json['Brand'] ?? json['brand'] ?? '',
      model: json['Model'] ?? json['model'] ?? '',
      color: json['Color']?.toString() ?? json['color']?.toString() ?? '',
      carType: json['CarType']?.toString() ?? json['carType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'brand': brand,
      'model': model,
      'color': color,
      'carType': carType,
    };
  }
}

class AddressInfo {
  final String street;
  final String buildingNumber;
  final String landmark;
  final double latitude;
  final double longitude;

  AddressInfo({
    required this.street,
    required this.buildingNumber,
    required this.landmark,
    required this.latitude,
    required this.longitude,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      street: json['Street'] ?? json['street'] ?? '',
      buildingNumber: json['BuildingNumber'] ?? json['buildingNumber'] ?? '',
      landmark: json['Landmark'] ?? json['landmark'] ?? '',
      latitude: (json['Latitude'] ?? json['latitude'] ?? 0).toDouble(),
      longitude: (json['Longitude'] ?? json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'buildingNumber': buildingNumber,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class ServiceInfo {
  final String id;
  final double price;
  final String description;
  final int estimatedTime;

  ServiceInfo({
    required this.id,
    required this.price,
    required this.description,
    required this.estimatedTime,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      price: (json['Price'] ?? json['price'] ?? 0).toDouble(),
      description: json['Description'] ?? json['description'] ?? '',
      estimatedTime: json['EstimatedTime'] ?? json['estimatedTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'price': price,
      'description': description,
      'estimatedTime': estimatedTime,
    };
  }
}
