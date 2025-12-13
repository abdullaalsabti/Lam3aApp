import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../models/service_category.dart';
import '../models/vehicle.dart';
import '../models/available_provider.dart';
import '../enums/payment_method.dart';
import '../services/api_service.dart';

class ProviderSelectionPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> requestData;

  const ProviderSelectionPage({super.key, required this.requestData});

  @override
  ConsumerState<ProviderSelectionPage> createState() => _ProviderSelectionPageState();
}

class _ProviderSelectionPageState extends ConsumerState<ProviderSelectionPage> {
  List<AvailableProvider>? _providers;
  bool _isLoading = true;
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableProviders();
  }

  Future<void> _loadAvailableProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final category = widget.requestData['category'] as ServiceCategory;
      final requestedDateTime = widget.requestData['requestedDateTime'] as DateTime;

      final response = await ApiService().getAuthenticated(
        'api/client/ServiceRequest/getAvailableProviders?categoryId=${category.id}&requestedDateTime=${requestedDateTime.toIso8601String()}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _providers = data.map((p) => AvailableProvider.fromJson(p)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load providers';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createServiceRequest(AvailableProvider provider) async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final vehicle = widget.requestData['vehicle'] as Vehicle;
      final requestedDateTime = widget.requestData['requestedDateTime'] as DateTime;
      final addressId = widget.requestData['addressId'] as String? ?? '';
      final paymentMethod = widget.requestData['paymentMethod'] as PaymentMethod;

      final body = {
        'serviceProviderId': provider.providerId,
        'serviceId': provider.serviceId,
        'vehiclePlateNumber': vehicle.plateNumber,
        'requestedDateTime': requestedDateTime.toIso8601String(),
        'addressId': addressId,
        'paymentMethod': paymentMethod.name,
      };

      final response = await ApiService().postAuthenticated(
        'api/client/ServiceRequest/create',
        body,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service request created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/client_requests');
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to create service request'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Select provider",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAvailableProviders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _providers == null || _providers!.isEmpty
                  ? Center(
                      child: Text(
                        'No available providers for the selected service and time',
                        style: GoogleFonts.poppins(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _providers!.length,
                      itemBuilder: (context, index) {
                        final provider = _providers![index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      provider.fullName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 20),
                                        Text(
                                          provider.rating.toStringAsFixed(1),
                                          style: GoogleFonts.poppins(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  provider.serviceDescription,
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${provider.estimatedTime} min',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    Text(
                                      '${provider.servicePrice.toStringAsFixed(2)} JOD',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _createServiceRequest(provider),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: scheme.primary,
                                    ),
                                    child: _isSubmitting
                                        ? const CircularProgressIndicator(color: Colors.white)
                                        : Text(
                                            'Select',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
