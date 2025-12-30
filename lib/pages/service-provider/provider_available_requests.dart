import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../models/service_request.dart';
import '../../services/api_service.dart';
import '../../widgets/availability_slider.dart';

class ProviderAvailableRequestsPage extends ConsumerStatefulWidget {
  const ProviderAvailableRequestsPage({super.key});

  @override
  ConsumerState<ProviderAvailableRequestsPage> createState() => _ProviderAvailableRequestsPageState();
}

class _ProviderAvailableRequestsPageState extends ConsumerState<ProviderAvailableRequestsPage> {
  List<ServiceRequest>? _requests;
  bool _isLoading = true;
  String? _error;
  
  // Availability state
  bool? _availability;
  bool _isLoadingAvailability = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _fetchAvailability();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Backend uses ProviderOrderController:
      // GET /api/provider/ProviderOrder/getOrders?status=Pending
      final response = await ApiService().getAuthenticated(
        'provider/ProviderOrder/getOrders?status=Pending',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _requests = data.map((r) => ServiceRequest.fromJson(r)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load requests';
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

  Future<void> _acceptRequest(String requestId) async {
    try {
      // Backend: PUT /api/provider/ProviderOrder/{requestId}/accept
      final response = await ApiService().putAuthenticated(
        'provider/ProviderOrder/$requestId/accept',
        {},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request accepted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadRequests();
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to accept request'),
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
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    try {
      // Backend: PUT /api/provider/ProviderOrder/{requestId}/reject
      // Body: { reason?: string }
      final response = await ApiService().putAuthenticated(
        'provider/ProviderOrder/$requestId/reject',
        {'reason': null},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadRequests();
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to reject request'),
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
    }
  }

  Future<void> _fetchAvailability() async {
    setState(() {
      _isLoadingAvailability = true;
    });

    try {
      final response = await ApiService().getAuthenticated(
        'provider/ProviderProfile/availability',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _availability = data['availability'] as bool? ?? false;
            _isLoadingAvailability = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _availability = false;
            _isLoadingAvailability = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load availability status'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availability = false;
          _isLoadingAvailability = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAvailability(bool availability) async {
    setState(() {
      _isLoadingAvailability = true;
    });

    try {
      // ASP.NET Core binds simple types from query string by default
      final endpoint = 'provider/ProviderProfile/availability?availability=$availability';
      final response = await ApiService().patchAuthenticated(
        endpoint,
        {},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _availability = availability;
            _isLoadingAvailability = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                availability
                    ? 'You are now online'
                    : 'You are now offline',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _isLoadingAvailability = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorData['message'] ??
                    errorData['error'] ??
                    'Failed to update availability',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAvailability = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Available Requests",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: Column(
        children: [
          // Availability Slider at the top
          if (_availability != null)
            AvailabilitySlider(
              isAvailable: _availability!,
              isLoading: _isLoadingAvailability,
              onToggle: _updateAvailability,
            ),
          // Main content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadRequests,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _requests == null || _requests!.isEmpty
                        ? Center(
                            child: Text(
                              'No available requests',
                              style: GoogleFonts.poppins(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadRequests,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _requests!.length,
                              itemBuilder: (context, index) {
                          final request = _requests![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.category?.name ?? 'Service',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (request.vehicle != null)
                                    Text(
                                      'Vehicle: ${request.vehicle!.brand} ${request.vehicle!.model} - ${request.vehicle!.plateNumber}',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Date: ${DateFormat('MMM dd, yyyy at HH:mm').format(request.requestedDateTime)}',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                  if (request.address != null)
                                    Text(
                                      'Location: ${request.address!.street}',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  if (request.service != null)
                                    Text(
                                      'Price: ${request.service!.price.toStringAsFixed(2)} JOD',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: scheme.primary,
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _rejectRequest(request.id),
                                          child: const Text('Reject'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _acceptRequest(request.id),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          child: const Text('Accept'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
