import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailingIcon;
  final bool isTotal;

  const OrderSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.trailingIcon,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailingIcon != null) ...[
                trailingIcon!,
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
                  color: Colors.grey[900],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

