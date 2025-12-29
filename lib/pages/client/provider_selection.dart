import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/service_request.dart';
import 'package:lamaa/pages/client/service_request_submit.dart';
import 'package:lamaa/providers/client_serviceRequest_provider.dart';
import 'dart:convert';
import '../../models/service_category.dart';
import '../../models/vehicle.dart';
import '../../models/provider.dart';
import '../../enums/payment_method.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_widget.dart';

class ProviderSelectionPage extends ConsumerStatefulWidget {

  const ProviderSelectionPage({super.key});

  @override
  ConsumerState<ProviderSelectionPage> createState() => _ProviderSelectionPageState();
}

class _ProviderSelectionPageState extends ConsumerState<ProviderSelectionPage> {
  List<ProviderServiceInfo>? _providers;
  bool _isLoading = true;
  String? _error;
  String? _selectedProviderId;
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
      final request = ref.read(serviceRequestProvider);
      final requestedDateTime = request.pickUpTime;
      final category = request.category;
      print("category is ${category!.id} and requested date time is $requestedDateTime");
      // Backend expects: GET /api/client/AvailableProviders?serviceCategoryId=...&startDate=...
      final startDateUtc = requestedDateTime!.toUtc().toIso8601String();
      final encodedStartDate = Uri.encodeQueryComponent(startDateUtc);

      final response = await ApiService().getAuthenticated(
        'api/client/AvailableProviders?serviceCategoryId=${category.id}&startDate=$encodedStartDate',
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = jsonDecode(response.body);
          
          final providers = <ProviderServiceInfo>[];
          for (var i = 0; i < data.length; i++) {
            try {
              final provider = ProviderServiceInfo.fromJson(data[i]);
              providers.add(provider);
            } catch (parseError) {
              print("Error parsing provider $i: $parseError");
              print("Raw data: ${data[i]}");
            }
          }
          
          setState(() {
            _providers = providers;
            _isLoading = false;
          });
        } catch (jsonError) {
          setState(() {
            _isLoading = false;
          });
        }
      } else {
     
        try {
          final errorBody = jsonDecode(response.body);
          setState(() {
            _error = errorBody['message']?.toString() ?? 'Failed to load providers';
            _isLoading = false;
          });
        } catch (_) {
          setState(() {
            _error = 'Failed to load providers (Status: ${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e, stackTrace) {
      setState(() {
        _error = 'Error loading providers: ${e.toString()}';
        _isLoading = false;
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
          "Select Provider",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAvailableProviders,
        color: scheme.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadAvailableProviders,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _providers == null || _providers!.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No available providers',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No providers are available for the selected service and time slot.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _providers!.length,
                        itemBuilder: (context, index) {
                          final provider = _providers![index];
                          final isSelected = _selectedProviderId == provider.serviceProviderId;
                          
                          return ProviderServiceInfoCard(
                            info: provider,
                            isLoading: isSelected && _isSubmitting,
                            onSelect: () {
                              // TODO: Implement service request creation
                              // Backend ServiceRequestController is currently empty
                              ref.watch(serviceRequestProvider.notifier).setProvider(provider.serviceProviderId);
                              Navigator.of(context).push(MaterialPageRoute(builder: (builder)=>ServiceRequestSubmit() ));
                            },
                          );
                        },
                      ),
      ),
    );
  }
}
