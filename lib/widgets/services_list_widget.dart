import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/provider_service.dart';
import 'package:lamaa/widgets/service_widget.dart';

class ServicesListWidget extends StatelessWidget {
  final List<ProviderService> services;
  final ColorScheme scheme;
  final Function(ProviderService) onEdit;
  final Function(ProviderService) onDelete;

  const ServicesListWidget({
    super.key,
    required this.services,
    required this.scheme,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header with count
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${services.length} ${services.length == 1 ? 'Service' : 'Services'}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Services List
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = services[index];
                return ServiceWidget(
                  service,
                  onEdit: () => onEdit(service),
                  onDelete: () => onDelete(service),
                );
              },
              childCount: services.length,
            ),
          ),
        ),
      ],
    );
  }
}

