import '../enums/car_type.dart';
import '../enums/car_colors.dart';

class Vehicle {
  final String plateNumber;
  final String model;
  final String brand;
  final String color; // Backend returns as string (enum name)
  final String carType; // Backend returns as string (enum name)

  Vehicle({
    required this.plateNumber,
    required this.model,
    required this.brand,
    required this.color,
    required this.carType,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plateNumber: json['PlateNumber'] ?? json['plateNumber'] ?? '',
      model: json['Model'] ?? json['model'] ?? '',
      brand: json['Brand'] ?? json['brand'] ?? '',
      color: json['Color']?.toString() ?? json['color']?.toString() ?? '',
      carType: json['CarType']?.toString() ?? json['carType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'model': model,
      'brand': brand,
      'color': color,
      'carType': carType,
    };
  }
}


