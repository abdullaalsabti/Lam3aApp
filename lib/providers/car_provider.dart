import 'package:flutter_riverpod/legacy.dart';
import 'package:lamaa/controllers/car_notifier.dart';
import '../models/car_selection.dart';

final carSelectionProvider =
StateNotifierProvider<CarSelectionNotifier, CarSelection>(
      (ref) => CarSelectionNotifier(),
);