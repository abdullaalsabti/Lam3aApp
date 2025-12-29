import 'package:flutter/material.dart';

class LocationMapCard extends StatefulWidget {
  const LocationMapCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.loading,
    required this.apiKey,
  });

  final double? latitude;
  final double? longitude;
  final bool loading;
  final String apiKey;

  @override
  State<LocationMapCard> createState() => _LocationMapCardState();
}

class _LocationMapCardState extends State<LocationMapCard> {
  String get locationImage {
    if (widget.latitude == null || widget.longitude == null) return '';
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.latitude},${widget.longitude}'
        '&zoom=16'
        '&size=600x300'
        '&maptype=roadmap'
        '&markers=color:red%7Clabel:A%7C${widget.latitude},${widget.longitude}'
        '&key=${widget.apiKey}';
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(Icons.map, size: 60, color: Colors.grey),
    );

    if (widget.loading) {
      content = Container(
        height: 160,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (widget.latitude != null && widget.longitude != null) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          locationImage,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
          // Add a key to force rebuild when coordinates change
          key: ValueKey('${widget.latitude}_${widget.longitude}'),
          // Add error handling
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 160,
              width: double.infinity,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
            );
          },
        ),
      );
    }

    return content;
  }
}
