import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/widgets/day_availability_card.dart';
import '../../services/api_service.dart';

class ProviderAvailabilityPage extends StatefulWidget {
  const ProviderAvailabilityPage({super.key});

  @override
  State<ProviderAvailabilityPage> createState() => _ProviderAvailabilityPageState();
}

class _ProviderAvailabilityPageState extends State<ProviderAvailabilityPage> {
  final Map<String, DayAvailabilityState> _days = {
    'Sunday': DayAvailabilityState(),
    'Monday': DayAvailabilityState(),
    'Tuesday': DayAvailabilityState(),
    'Wednesday': DayAvailabilityState(),
    'Thursday': DayAvailabilityState(),
    'Friday': DayAvailabilityState(),
    'Saturday': DayAvailabilityState(),
  };

  bool _isSubmitting = false;

  Future<void> _pickTime({
    required String day,
    required int slotIndex,
    required bool isStart,
  }) async {
    final slot = _days[day]!.slots[slotIndex];
    final initial = isStart ? slot.start : slot.end;

    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          slot.start = picked;
        } else {
          slot.end = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    // Backend TimeSpan expects "HH:mm:ss"
    return '$hh:$mm:00';
  }

  Future<void> _saveAvailability() async {
    // Validate at least one day enabled and each enabled day has valid slots
    final enabledDays = _days.entries.where((e) => e.value.enabled).toList();
    if (enabledDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable at least one day.')),
      );
      return;
    }

    for (final entry in enabledDays) {
      final day = entry.key;
      final state = entry.value;
      final validSlots = state.slots.where((s) => s.start != null && s.end != null).toList();
      if (validSlots.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one time slot for $day.')),
        );
        return;
      }

      for (final slot in validSlots) {
        final startMins = slot.start!.hour * 60 + slot.start!.minute;
        final endMins = slot.end!.hour * 60 + slot.end!.minute;
        if (endMins <= startMins) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid slot on $day: end time must be after start time.')),
          );
          return;
        }
      }
    }

    final availabilityPayload = enabledDays.map((entry) {
      final day = entry.key;
      final state = entry.value;
      final slots = state.slots
          .where((s) => s.start != null && s.end != null)
          .map((s) => {
                'start': _formatTimeOfDay(s.start!),
                'end': _formatTimeOfDay(s.end!),
              })
          .toList();

      return {
        'day': day,
        'timeSlots': slots,
      };
    }).toList();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await ApiService().putAuthenticated(
        'api/provider/ProviderProfile/editAvailability',
        {
          'availability': availabilityPayload,
        },
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/provider_available_requests');
      } else {
        String msg = 'Failed to save availability';
        try {
          final body = jsonDecode(response.body);
          msg = body['message'] ?? body['error'] ?? msg;
        } catch (_) {}
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Set Availability',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: scheme.primary,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Set the times and days you are available to work',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ..._days.entries.map((entry) => DayAvailabilityCard(
                day: entry.key,
                state: entry.value,
                onToggle: (v) => setState(() => entry.value.enabled = v),
                onAddSlot: () => setState(() => entry.value.slots.add(TimeSlotRange())),
                onRemoveSlot: (idx) => setState(() => entry.value.slots.removeAt(idx)),
                onPickStart: (idx) => _pickTime(day: entry.key, slotIndex: idx, isStart: true),
                onPickEnd: (idx) => _pickTime(day: entry.key, slotIndex: idx, isStart: false),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveAvailability,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23918C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Save and Continue',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class DayAvailabilityState {
  bool enabled = false;
  List<TimeSlotRange> slots = [TimeSlotRange()];
}

class TimeSlotRange {
  TimeOfDay? start;
  TimeOfDay? end;
}

