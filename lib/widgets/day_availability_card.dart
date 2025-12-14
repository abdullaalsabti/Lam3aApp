import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/pages/service-provider/provider_availability.dart';

class DayAvailabilityCard extends StatelessWidget {
  final String day;
  final DayAvailabilityState state;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddSlot;
  final void Function(int idx) onRemoveSlot;
  final void Function(int idx) onPickStart;
  final void Function(int idx) onPickEnd;

  const DayAvailabilityCard({
    required this.day,
    required this.state,
    required this.onToggle,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onPickStart,
    required this.onPickEnd,
  });

  String _formatLabel(TimeOfDay? t) {
    if (t == null) return '--:--';
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(day, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                Switch(value: state.enabled, onChanged: onToggle),
              ],
            ),
            if (state.enabled) ...[
              const SizedBox(height: 8),
              ...List.generate(state.slots.length, (i) {
                final slot = state.slots[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onPickStart(i),
                          child: Text(_formatLabel(slot.start)),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('to'),
                      ),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => onPickEnd(i),
                          child: Text(_formatLabel(slot.end)),
                        ),
                      ),
                      if (state.slots.length > 1)
                        IconButton(
                          onPressed: () => onRemoveSlot(i),
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                );
              }),
              TextButton.icon(
                onPressed: onAddSlot,
                icon: const Icon(Icons.add),
                label: Text('Add more hours', style: GoogleFonts.poppins()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}