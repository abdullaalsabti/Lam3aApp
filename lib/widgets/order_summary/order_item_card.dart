import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderItemCard extends StatelessWidget {
  final String serviceName;
  final String vehicleName;
  final String? plateNumber;
  final String? vehicleImage;

  const OrderItemCard({
    super.key,
    required this.serviceName,
    this.plateNumber,
    required this.vehicleName,
    this.vehicleImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Vehicle Image/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: vehicleImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      vehicleImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.directions_car,
                    color: Color(0xFF10B981),
                    size: 32,
                  ),
          ),
          const SizedBox(width: 12),
          // Service and Vehicle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicleName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if(plateNumber!= null)
                Text(
                  "plate number : $plateNumber",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Checkmark
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}



