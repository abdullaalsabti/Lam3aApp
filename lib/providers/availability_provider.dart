import 'package:flutter_riverpod/legacy.dart';

import '../models/day_availability.dart';

final availabilityProvider = StateNotifierProvider<AvailabilityNotifier, List<DayAvailability>>((ref){
  return AvailabilityNotifier();
});

class AvailabilityNotifier extends StateNotifier<List<DayAvailability>>{
  AvailabilityNotifier() : super([
    DayAvailability(day: 'Sunday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Monday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Tuesday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Wednesday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Thursday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Friday', ranges: [{"from": "09:00", "to": "17:00"}]),
    DayAvailability(day: 'Saturday', ranges: [{"from": "09:00", "to": "17:00"}]),
  ]);

  void updateDay(String day, {bool? enabled, List<Map<String, String>>? ranges}) {
    state = [
      for (final item in state)
        if (item.day == day)
          item.copyWith(enabled: enabled, ranges: ranges)
        else
          item,
    ];
  }
}