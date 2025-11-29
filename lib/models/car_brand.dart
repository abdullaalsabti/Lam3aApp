import 'car_model.dart';

class CarBrand {
  final String id;
  final String brand;
  final List<CarModel> models;

  CarBrand({required this.id, required this.brand, required this.models});

  factory CarBrand.fromJson(Map<String, dynamic> json) {
    final modelsList = json['Models'] ?? json['models'];
    List<CarModel> models = [];
    
    if (modelsList != null && modelsList is List) {
      models = modelsList
          .map<CarModel>((m) => CarModel.fromJson(m as Map<String, dynamic>))
          .toList();
    }
    
    return CarBrand(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      brand: json['Name'] ?? json['Brand'] ?? json['name'] ?? '',
      models: models,
    );
  }

  CarBrand copyWith({String? id, String? brand, List<CarModel>? models}) {
    return CarBrand(id: this.id, brand: this.brand, models: this.models);
  }
}
