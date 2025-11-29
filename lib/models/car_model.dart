class CarModel {
  final String id;
  final String name;
  final String brandId;

  CarModel({required this.id, required this.name, required this.brandId});

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['Id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      brandId: json['BrandId']?.toString() ?? json['brandId']?.toString() ?? '',
    );
  }

  CarModel copyWith({String? id, String? name, String? brandId}) {
    return CarModel(id: this.id, name: this.name, brandId: this.brandId);
  }
}
