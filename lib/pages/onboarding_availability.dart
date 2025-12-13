import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:lamaa/widgets/day_hour_card.dart';

import '../widgets/button.dart';

class OnBoardingAvailability extends ConsumerStatefulWidget {
  const OnBoardingAvailability({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OnBoardingAvailabilityState();
}

class _OnBoardingAvailabilityState
    extends ConsumerState<ConsumerStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Set Availability", style: theme.textTheme.titleLarge),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Sunday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Monday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Tuesday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Wednesday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Thursday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Friday'),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: DayHoursCard(day: 'Saturday'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(16.0),
        child: Button(btnText: 'Confirm', onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Schedules saved!')));
        }),
      ),
    );
  }
}
