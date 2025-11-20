import 'package:lamaa/enums/car_colors.dart';
import 'package:lamaa/enums/car_type.dart';
import 'package:lamaa/models/car_brand.dart';
import 'package:lamaa/models/car_model.dart';

class CarSelection {
  final CarBrand? selectedBrand;
  final CarModel? selectedModel;
  final CarType? selectedType;
  final CarColors? selectedColor;

  CarSelection({
    this.selectedBrand,
    this.selectedModel,
    this.selectedType,
    this.selectedColor,
  });

  CarSelection copyWith({
    CarBrand? selectedBrand,
    CarModel? selectedModel,
    CarType? selectedType,
    CarColors? selectedColor,
  }) {
    return CarSelection(
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedModel: selectedModel ?? this.selectedModel,
      selectedType: selectedType ?? this.selectedType,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }
}