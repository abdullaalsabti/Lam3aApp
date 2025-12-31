import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/widgets/provider_request_card.dart';
import 'dart:convert';
import '../../models/service_request.dart';
import '../../services/api_service.dart';
import '../../widgets/availability_slider.dart';

class ProviderAvailableRequestsPage extends ConsumerStatefulWidget {
  const ProviderAvailableRequestsPage({super.key});

  @override
  ConsumerState<ProviderAvailableRequestsPage> createState() =>
      _ProviderAvailableRequestsPageState();
}

class _ProviderAvailableRequestsPageState
    extends ConsumerState<ProviderAvailableRequestsPage> {
  final String API_KEY = "AIzaSyByCDOzdRCx0cJhxim3I-d8p0wm2--705Q";

  List<ProviderServiceRequest>? _requests;
  bool _isLoading = true;
  String? _error;

  // Availability state
  bool? _availability;
  bool _isLoadingAvailability = false;

  // Track which request is being processed
  String? _acceptingRequestId;
  String? _rejectingRequestId;

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
      final response = await ApiService().getAuthenticated(
        'provider/ProviderOrder/getOrders?status=Pending',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _requests = data
              .map((r) => ProviderServiceRequest.fromJson(r))
              .toList();
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
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptRequest(String requestId) async {
    setState(() {
      _acceptingRequestId = requestId;
    });

    try {
      final response = await ApiService().putAuthenticated(
        'provider/ProviderOrder/$requestId/accept',
        {},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Request accepted successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadRequests();
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Failed to accept request'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _acceptingRequestId = null;
        });
      }
    }
  }

  Future<void> _rejectRequest(String requestId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reject Request?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to reject this service request?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              'Reject',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _rejectingRequestId = requestId;
    });

    try {
      final response = await ApiService().putAuthenticated(
        'provider/ProviderOrder/$requestId/reject',
        {'reason': null},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Request rejected'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadRequests();
        }
      } else {
        final errorData = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Failed to reject request'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _rejectingRequestId = null;
        });
      }
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
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _availability = false;
          _isLoadingAvailability = false;
        });
      }
    }
  }

  Future<void> _updateAvailability(bool availability) async {
    setState(() {
      _isLoadingAvailability = true;
    });

    try {
      final endpoint =
          'provider/ProviderProfile/availability?availability=$availability';
      final response = await ApiService().patchAuthenticated(endpoint, {});

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _availability = availability;
            _isLoadingAvailability = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                availability ? 'You are now online' : 'You are now offline',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
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
              behavior: SnackBarBehavior.floating,
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
            content: Text('Error updating availability: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Available Requests",
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
      ),
      body: Column(
        children: [
      //     Row(
      //       children: [
      //           Icon(Icons.person, size: 50, color: scheme.primary),
      //           Text("Hello ${ref.read(signupProvider).fName} ${ref.read(signupProvider).lName}")
      //       ],
      //     ),
        


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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading requests...',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadRequests,
                            icon: const Icon(Icons.refresh),
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
                : _requests == null || _requests!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Available Requests',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'New service requests will appear here',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          OutlinedButton.icon(
                            onPressed: _loadRequests,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadRequests,
                    color: scheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests!.length,
                      itemBuilder: (context, index) {
                        final request = _requests![index];
                        return ProviderRequestCard(
                          req: request,
                          apiKey: API_KEY,
                          onAccept: () => _acceptRequest(request.requestId),
                          onReject: () => _rejectRequest(request.requestId),
                          isAccepting: _acceptingRequestId == request.requestId,
                          isRejecting: _rejectingRequestId == request.requestId,
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
