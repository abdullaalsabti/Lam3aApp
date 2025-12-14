import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/enums/car_colors.dart';
import 'package:lamaa/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({super.key, 
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getColorFromString(String colorStr) {
    try {
      // Map backend color strings to CarColors enum
      final colorMap = {
        'Black': CarColors.black,
        'White': CarColors.white,
        'Silver': CarColors.silver,
        'Blue': CarColors.blue,
        'Red': CarColors.red,
        'Gray': CarColors.grey,
        'Green': CarColors.green,
      };

      final carColor = colorMap[colorStr] ?? CarColors.black;
      return getColor(carColor);
    } catch (e) {
      return Colors.grey;
    }
  }

  IconData _getCarTypeIcon(String carType) {
    switch (carType.toLowerCase()) {
      case 'sedan':
        return Icons.directions_car;
      case 'suv':
        return Icons.airport_shuttle;
      case 'bike':
        return Icons.two_wheeler;
      default:
        return Icons.directions_car;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getColorFromString(vehicle.color),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getCarTypeIcon(vehicle.carType), color: Colors.white),
        ),
        title: Text(
          '${vehicle.brand} ${vehicle.model}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Plate: ${vehicle.plateNumber}',
          style: GoogleFonts.poppins(),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              color: scheme.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
