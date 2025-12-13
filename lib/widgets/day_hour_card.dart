import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/availability_provider.dart';

class DayHoursCard extends ConsumerStatefulWidget {
  final String day;

  const DayHoursCard({super.key, required this.day});

  @override
  ConsumerState<DayHoursCard> createState() => _DayHoursCardState();
}

class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    String digits = newValue.text.replaceAll(':', '');

    if (digits.length > 4) digits = digits.substring(0, 4);

    // Validate Hours
    if (digits.length >= 2) {
      int hours = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (hours > 23) digits = '23${digits.substring(2)}';
    }

    // Validate Minutes
    if (digits.length > 2) {
      int minutes = int.tryParse(digits.substring(2)) ?? 0;
      if (minutes > 59) digits = '${digits.substring(0, 2)}59';
    }

    String formatted = digits;
    if (digits.length >= 3) {
      formatted = "${digits.substring(0, 2)}:${digits.substring(2)}";
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DayHoursCardState extends ConsumerState<DayHoursCard> {
  // We keep the local controllers to prevent cursor jumps and manage local input state
  late List<TextEditingController> fromControllers;
  late List<TextEditingController> toControllers;

  @override
  void initState() {
    super.initState();
    // Read the initial data from Riverpod to initialize controllers
    final data = ref
        .read(availabilityProvider)
        .firstWhere((e) => e.day == widget.day);

    fromControllers = data.ranges
        .map((r) => TextEditingController(text: r['from']))
        .toList();
    toControllers = data.ranges
        .map((r) => TextEditingController(text: r['to']))
        .toList();
  }

  @override
  void dispose() {
    for (var c in fromControllers) {
      c.dispose();
    }
    for (var c in toControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncWithRiverpod() {
    final newRanges = List.generate(
      fromControllers.length,
      (i) => {"from": fromControllers[i].text, "to": toControllers[i].text},
    );

    ref
        .read(availabilityProvider.notifier)
        .updateDay(widget.day, ranges: newRanges);
  }

  int _toMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  bool _isRangeValid(String from, String to) {
    if (from.length < 5 || to.length < 5) return true;
    return _toMinutes(to) > _toMinutes(from);
  }

  @override
  Widget build(BuildContext context) {
    // Watch current day state (specifically the 'enabled' property)
    final data = ref
        .watch(availabilityProvider)
        .firstWhere((e) => e.day == widget.day);
    final notifier = ref.read(availabilityProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.day,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: data.enabled,
                onChanged: (v) => notifier.updateDay(widget.day, enabled: v),
              ),
            ],
          ),
          const SizedBox(height: 8),

          IgnorePointer(
            ignoring: !data.enabled,
            child: Opacity(
              opacity: data.enabled ? 1.0 : 0.4,
              child: Column(
                children: [
                  ...List.generate(fromControllers.length, (index) {
                    final fromCtrl = fromControllers[index];
                    final toCtrl = toControllers[index];
                    final isValid = _isRangeValid(fromCtrl.text, toCtrl.text);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _hourBox(fromCtrl, isValid)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text("to"),
                              ),
                              Expanded(child: _hourBox(toCtrl, isValid)),
                              if (fromControllers.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      fromControllers.removeAt(index).dispose();
                                      toControllers.removeAt(index).dispose();
                                    });
                                    _syncWithRiverpod();
                                  },
                                ),
                            ],
                          ),
                          if (!isValid)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                "Shift end must be later than start",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (fromControllers.length < 2)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          fromControllers.add(
                            TextEditingController(text: "09:00"),
                          );
                          toControllers.add(
                            TextEditingController(text: "17:00"),
                          );
                        });
                        _syncWithRiverpod();
                      },
                      icon: const Icon(Icons.add, color: Colors.teal),
                      label: const Text(
                        "Add more hours",
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hourBox(TextEditingController controller, bool isValid) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _TimeInputFormatter(),
      ],
      onChanged: (_) {
        setState(() {}); // Updates local validation UI
        _syncWithRiverpod(); // Syncs to Riverpod
      },
      decoration: InputDecoration(
        counterText: "",
        hintText: "00:00",
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isValid ? Colors.grey.shade400 : Colors.red,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isValid ? Colors.teal : Colors.red,
            width: 2,
          ),
        ),
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 15),
    );
  }
}
