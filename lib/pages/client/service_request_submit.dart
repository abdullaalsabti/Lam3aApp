import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/providers/client_serviceRequest_provider.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/widgets/order_summary/order_map_section.dart';
import 'package:lamaa/widgets/order_summary/location_info_row.dart';
import 'package:lamaa/widgets/order_summary/order_item_card.dart';
import 'package:lamaa/widgets/order_summary/order_summary_row.dart';
import 'package:lamaa/widgets/order_summary/payment_info_section.dart';
import 'dart:convert';
import 'dart:async';
import '../../providers/vehicles_provider.dart';
import '../../models/provider.dart';
import '../../enums/payment_method.dart';

class ServiceRequestSubmit extends ConsumerStatefulWidget {
  const ServiceRequestSubmit({super.key});

  @override
  ConsumerState<ServiceRequestSubmit> createState() => _ServiceRequestSubmitState();
}

class _ServiceRequestSubmitState extends ConsumerState<ServiceRequestSubmit> {
  final API_KEY = "AIzaSyByCDOzdRCx0cJhxim3I-d8p0wm2--705Q";
  bool _isSubmitting = false;
  String? _errorMessage;
  ProviderServiceInfo? _selectedProvider;
  double? _servicePrice;

  @override
  void initState() {
    super.initState();
    _loadProviderInfo();
  }

  Future<void> _loadProviderInfo() async {
    final request = ref.read(serviceRequestProvider);
    if (request.providerId == null || request.category == null || request.pickUpTime == null) {
      return;
    }

    try {
      final startDateUtc = request.pickUpTime!.toUtc().toIso8601String();
      final encodedStartDate = Uri.encodeQueryComponent(startDateUtc);
      final response = await ApiService().getAuthenticated(
        'api/client/AvailableProviders?serviceCategoryId=${request.category!.id}&startDate=$encodedStartDate',
      );

      if (response.statusCode == 200) {
        final List<dynamic> providersData = jsonDecode(response.body);
        for (var providerData in providersData) {
          if (providerData['Id']?.toString() == request.providerId ||
              providerData['id']?.toString() == request.providerId) {
            setState(() {
              _selectedProvider = ProviderServiceInfo.fromJson(providerData);
              _servicePrice = _selectedProvider!.price;
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error loading provider info: $e');
    }
  }

  String _generateOrderNumber() {
    // Generate a random 6-digit order number
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  String _formatAddress() {
    final request = ref.read(serviceRequestProvider);
    if (request.address == null) return '';
    
    final parts = <String>[];
    if (request.address!.streetName != null && request.address!.streetName!.isNotEmpty) {
      parts.add(request.address!.streetName!);
    }
    if (request.address!.houseNumber != null && request.address!.houseNumber!.isNotEmpty) {
      parts.add('Bld #${request.address!.houseNumber}');
    }
    parts.add('Amman, Jordan');
    
    return parts.join(', ');
  }

  String _getVehicleName() {
    final request = ref.read(serviceRequestProvider);
    if (request.carPlateNumber == null) return 'Unknown Vehicle';
    
    // Try to get vehicle details from provider
    final vehiclesAsync = ref.read(vehiclesProvider);
    return vehiclesAsync.when(
      data: (vehicles) {
        final vehicle = vehicles.firstWhere(
          (v) => v.plateNumber == request.carPlateNumber,
          orElse: () => vehicles.first,
        );
        return '${vehicle.brand} ${vehicle.model}';
      },
      loading: () => request.carPlateNumber!,
      error: (_, __) => request.carPlateNumber!,
    );
  }

  Future<void> _submitServiceRequest() async {
    final request = ref.read(serviceRequestProvider);
    
    if (request.address == null || request.address!.coordinates == null ||
        request.carPlateNumber == null || request.providerId == null ||
        request.category == null || request.pickUpTime == null) {
      _showError('Please complete all required fields');
      return;
    }

    if (_selectedProvider == null) {
      _showError('Provider information not found');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final scheduledStartTimeUtc = request.pickUpTime!.toUtc().toIso8601String();
      
      final requestBody = {
        'serviceId': _selectedProvider!.serviceId,
        'providerId': request.providerId,
        'vehiclePlateNumber': request.carPlateNumber,
        'scheduledStartTime': scheduledStartTimeUtc,
        'paymentMethod': request.paymentMethod?.name ?? 'Cash',
        'serviceAddress': {
          'street': request.address!.streetName ?? '',
          'buildingNumber': request.address!.houseNumber ?? '',
          'landmark': request.address!.landmark ?? '',
          'coordinates': request.address!.coordinates!.toJson(),
        },
      };

      final response = await ApiService().postAuthenticated(
        'api/client/ServiceRequest',
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ref.read(serviceRequestProvider.notifier).clear();
        
        if (mounted) {
          // Navigate to home screen first, then show success dialog
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/main_page',
            (route) => false,
            arguments: {'showSuccessDialog': true}, // Pass flag to show dialog
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        _showError(errorBody['message']?.toString() ?? 'Failed to submit service request');
      }
    } catch (e) {
      _showError('Error submitting request: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showPaymentMethodDialog() {
    final request = ref.read(serviceRequestProvider);
    final currentMethod = request.paymentMethod ?? PaymentMethod.cash;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Method',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 24),
            ...PaymentMethod.values.map((method) {
              final isSelected = method == currentMethod;
              return InkWell(
                onTap: () {
                  ref.read(serviceRequestProvider.notifier).setPaymentMethod(method);
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          method.toDisplayString(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w500,
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(serviceRequestProvider);
    final scheme = Theme.of(context).colorScheme;
    final orderNumber = _generateOrderNumber();
    final price = _servicePrice ?? request.category?.averagePrice ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Color(0xFF157B72)),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Order Summary',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.grey[900],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '#$orderNumber',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Section
            if (request.address?.coordinates != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: OrderMapSection(
                  latitude: request.address!.coordinates?.latitude,
                  longitude: request.address!.coordinates?.longitude,
                  apiKey: API_KEY,
                ),
              ),

            // Service Provider & Delivery Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (_selectedProvider != null)
                    LocationInfoRow(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      label: 'Service Provider',
                      value: _selectedProvider!.name,
                      trailing: Icon(
                        Icons.two_wheeler,
                        color: scheme.primary,
                        size: 24,
                      ),
                    ),
                  
                  if (request.address != null)
                    LocationInfoRow(
                
                      icon: Icons.radio_button_checked,
                      iconColor: const Color(0xFF10B981),
                      label: 'Delivery Location',
                      value: _formatAddress(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Order Item Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OrderItemCard(
                plateNumber: request.carPlateNumber,
                serviceName: request.category?.name ?? 'Service',
                vehicleName: _getVehicleName(),
              ),
            ),

            const SizedBox(height: 16),

            // Order Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: OrderSummaryRow(
                label: 'Order Total',
                value: '${price.toStringAsFixed(0)} JOD',
                isTotal: true,
              ),
            ),

            const SizedBox(height: 16),

            // Payment Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PaymentInfoSection(
                paymentMethod: request.paymentMethod?.toDisplayString() ?? 'Cash',
                amount: '${price.toStringAsFixed(0)} JOD',
                onTap: _showPaymentMethodDialog,
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitServiceRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Confirm',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
