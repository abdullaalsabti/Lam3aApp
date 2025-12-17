import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/provider_service.dart';

class DeleteServiceDialog extends StatelessWidget {
  final ProviderService service;
  final ColorScheme scheme;
  final Function(String serviceId) onConfirm;

  const DeleteServiceDialog({
    super.key,
    required this.service,
    required this.scheme,
    required this.onConfirm,
  });

  static void show(
    BuildContext context,
    ProviderService service,
    ColorScheme scheme,
    final Function(String serviceId) onConfirm
  ) {
    showDialog(
      context: context,
      builder: (context) => DeleteServiceDialog(
        service: service,
        scheme: scheme,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Delete Service?',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      content: Text(
        'Are you sure you want to delete "${service.categoryName}"? This action cannot be undone.',
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: scheme.onSurface.withOpacity(0.7),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm(service.serviceId!);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Delete',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

