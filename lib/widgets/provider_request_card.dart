import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lamaa/models/service_request.dart';
import 'package:lamaa/widgets/location_map_card.dart';
import 'package:lamaa/enums/service_status.dart';

class ProviderRequestCard extends StatelessWidget {
  const ProviderRequestCard({
    super.key,
    required this.req,
    this.onAccept,
    this.onReject,
    this.onStatusUpdate,
    this.isAccepting = false,
    this.isRejecting = false,
    this.isUpdatingStatus = false,
    this.apiKey,
    this.showStatusBadge = false,
  });

  final ProviderServiceRequest req;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final Function(ServiceStatus)? onStatusUpdate;
  final bool isAccepting;
  final bool isRejecting;
  final bool isUpdatingStatus;
  final String? apiKey;
  final bool showStatusBadge;

  String _formatDateTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    return '${dateFormat.format(localTime)} at ${timeFormat.format(localTime)}';
  }

  String _formatDuration() {
    final duration = req.scheduledEndTime.difference(req.scheduledStartTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  String _formatAddress() {
    final parts = <String>[];
    if (req.address.streetName != null && req.address.streetName!.isNotEmpty) {
      parts.add(req.address.streetName!);
    }
    if (req.address.houseNumber != null && req.address.houseNumber!.isNotEmpty) {
      parts.add('Bld #${req.address.houseNumber}');
    }
    if (req.address.landmark != null && req.address.landmark!.isNotEmpty) {
      parts.add('Near ${req.address.landmark}');
    }
    if (parts.isEmpty) {
      return 'Location provided';
    }
    return parts.join(', ');
  }

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.pending:
        return Colors.orange;
      case ServiceStatus.accepted:
        return Colors.blue;
      case ServiceStatus.providerOnTheWay:
        return Colors.purple;
      case ServiceStatus.providerArrived:
        return Colors.indigo;
      case ServiceStatus.washingStarted:
        return Colors.teal;
      case ServiceStatus.paying:
        return Colors.amber;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.cancelled:
      case ServiceStatus.rejected:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  ServiceStatus? _getNextStatus(ServiceStatus currentStatus) {
    switch (currentStatus) {
      case ServiceStatus.accepted:
        return ServiceStatus.providerOnTheWay;
      case ServiceStatus.providerOnTheWay:
        return ServiceStatus.providerArrived;
      case ServiceStatus.providerArrived:
        return ServiceStatus.washingStarted;
      case ServiceStatus.washingStarted:
        return ServiceStatus.paying;
      case ServiceStatus.paying:
        return ServiceStatus.completed;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPending = req.status == ServiceStatus.pending;
    final nextStatus = _getNextStatus(req.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Service Name and Price
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    req.serviceName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${req.price.toStringAsFixed(0)} JOD',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      'Service Fee',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Status Badge (if not pending)
          if (showStatusBadge && !isPending)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(req.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getStatusColor(req.status).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: _getStatusColor(req.status),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      req.status.toDisplayString(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(req.status),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Map Preview (if API key is provided)
          if (apiKey != null && req.address.coordinates != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: LocationMapCard(
                latitude: req.address.coordinates!.latitude,
                longitude: req.address.coordinates!.longitude,
                loading: false,
                apiKey: apiKey!,
              ),
            ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client Name
                if (req.clientName.isNotEmpty)
                  _InfoRow(
                    icon: Icons.person,
                    iconColor: Colors.blue,
                    label: 'Client',
                    value: req.clientName,
                  ),

                const SizedBox(height: 12),

                // Vehicle Plate Number
                _InfoRow(
                  icon: Icons.directions_car,
                  iconColor: Colors.orange,
                  label: 'Vehicle',
                  value: req.vehiclePlateNumber,
                ),

                const SizedBox(height: 12),

                // Location
                _InfoRow(
                  icon: Icons.location_on,
                  iconColor: Colors.red,
                  label: 'Location',
                  value: _formatAddress(),
                  isMultiline: true,
                ),

                const SizedBox(height: 12),

                // Scheduled Time
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: Colors.purple,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled Time',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDateTime(req.scheduledStartTime),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                          ),
                          Text(
                            'Duration: ${_formatDuration()}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Divider(color: Colors.grey.shade200),

                const SizedBox(height: 16),

                // Action Buttons
                if (isPending && onAccept != null && onReject != null)
                  // Pending: Show Accept/Reject buttons
                  Row(
                    children: [
                      // Reject Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isRejecting || isAccepting ? null : onReject,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isRejecting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.close, color: Colors.red.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Reject',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Accept Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: isAccepting || isRejecting ? null : onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: scheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isAccepting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Accept',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  )
                else if (!isPending && nextStatus != null && onStatusUpdate != null)
                  // Non-pending with next status: Show Update Status button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isUpdatingStatus ? null : () => onStatusUpdate!(nextStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(nextStatus),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: isUpdatingStatus
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                      label: Text(
                        isUpdatingStatus
                            ? 'Updating...'
                            : 'Update to ${nextStatus.toDisplayString()}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else if (!isPending)
                  // Completed/Cancelled/Rejected: Show status only
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(req.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(req.status).withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        req.status.toDisplayString(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(req.status),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool isMultiline;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[900],
                ),
                maxLines: isMultiline ? 2 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
