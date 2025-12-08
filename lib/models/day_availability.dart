class DayAvailability {
  final String day;
  final bool enabled;
  final List<Map<String, String>> ranges;

  DayAvailability({
    required this.day,
    this.enabled = true,
    required this.ranges,
  });

  DayAvailability copyWith({bool? enabled, List<Map<String, String>>? ranges}) {
    return DayAvailability(
      day: day,
      enabled: enabled ?? this.enabled,
      ranges: ranges ?? this.ranges,
    );
  }
}
