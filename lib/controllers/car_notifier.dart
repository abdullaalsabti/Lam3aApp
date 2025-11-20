import 'package:flutter_riverpod/legacy.dart';
import '../models/car_brand.dart';
import '../models/car_model.dart';
import '../enums/car_type.dart';
import '../enums/car_colors.dart';
import '../models/car_selection.dart';


class CarSelectionNotifier extends StateNotifier<CarSelection> {
  CarSelectionNotifier() : super(CarSelection());

  void selectBrand(CarBrand? brand) {
    state = state.copyWith(
      selectedBrand: brand,
      selectedModel: null, // reset model
    );
  }

  void selectModel(CarModel? model) {
    state = state.copyWith(selectedModel: model);
  }

  void selectType(CarType type) {
    state = state.copyWith(selectedType: type);
  }

  void selectColor(CarColors color) {
    state = state.copyWith(selectedColor: color);
  }

  void reset() {
    state = CarSelection();
  }
}
