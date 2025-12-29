import 'package:flutter/material.dart';
import 'package:lamaa/widgets/location_map_card.dart';

class OrderMapSection extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final String apiKey;

  const OrderMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.apiKey,
  });

  @override
  Widget build(BuildContext context) {
    if (latitude == null || longitude == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Icon(Icons.map, size: 48, color: Colors.grey),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: LocationMapCard(
        latitude: latitude,
        longitude: longitude,
        loading: false,
        apiKey: apiKey,
      ),
    );
  }
}

