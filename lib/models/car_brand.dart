import 'car_model.dart';

class CarBrand {
  final String id;
  final String brand;
  final List<CarModel> models;

  CarBrand({required this.id, required this.brand, required this.models});

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    return CarBrand(
      id: json['Id'],
      brand: json['Brand'],
      models: (json['models'] as List)
          .map((m) => CarModel.fromJson(m))
          .toList(),
    );
  }

  CarBrand copyWith({String? id, String? brand, List<CarModel>? models}) {
    return CarBrand(id: this.id, brand: this.brand, models: this.models);
  }
}
