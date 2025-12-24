import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../models/service_request.dart';
import '../../enums/service_status.dart';
import '../../services/api_service.dart';

class ProviderMyRequestsPage extends ConsumerStatefulWidget {
  const ProviderMyRequestsPage({super.key});

  @override
  ConsumerState<ProviderMyRequestsPage> createState() => _ProviderMyRequestsPageState();
}

class _ProviderMyRequestsPageState extends ConsumerState<ProviderMyRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ServiceRequest>? _requests;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Backend uses ProviderOrderController:
      // GET /api/provider/ProviderOrder/getOrders
      final response = await ApiService().getAuthenticated(
        'api/provider/ProviderOrder/getOrders',
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

  Future<void> _updateStatus(String requestId, ServiceStatus newStatus) async {
    try {
      // Backend: PUT /api/provider/ProviderOrder/{requestId}/status?newStatus=...
      final encoded = Uri.encodeQueryComponent(newStatus.name);
      final response = await ApiService().putAuthenticated(
        'api/provider/ProviderOrder/$requestId/status?newStatus=$encoded',
        {},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Status updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadRequests();
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to update status'),
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

  ServiceStatus? _getNextStatus(ServiceStatus currentStatus) {
    switch (currentStatus) {
      case ServiceStatus.orderPlaced:
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "My Requests",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: scheme.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
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
                        onPressed: _loadRequests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsList(true),
                    _buildRequestsList(false),
                  ],
                ),
    );
  }

  Widget _buildRequestsList(bool isUpcoming) {
    if (_requests == null) {
      return const Center(child: Text('No requests'));
    }

    final now = DateTime.now();
    final filteredRequests = _requests!.where((req) {
      if (isUpcoming) {
        return req.requestedDateTime.isAfter(now) &&
               req.status != ServiceStatus.completed &&
               req.status != ServiceStatus.cancelled;
      } else {
        return req.requestedDateTime.isBefore(now) ||
               req.status == ServiceStatus.completed ||
               req.status == ServiceStatus.cancelled;
      }
    }).toList();

    if (filteredRequests.isEmpty) {
      return Center(
        child: Text(
          isUpcoming ? 'No upcoming requests' : 'No past requests',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredRequests.length,
        itemBuilder: (context, index) {
          final request = filteredRequests[index];
          final nextStatus = _getNextStatus(request.status);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        request.category?.name ?? 'Service',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Chip(
                        label: Text(
                          request.status.toDisplayString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getStatusColor(request.status),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (request.vehicle != null)
                    Text(
                      'Vehicle: ${request.vehicle!.brand} ${request.vehicle!.model}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${DateFormat('MMM dd, yyyy at HH:mm').format(request.requestedDateTime)}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  if (request.service != null)
                    Text(
                      'Price: ${request.service!.price.toStringAsFixed(2)} JOD',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (isUpcoming && nextStatus != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _updateStatus(request.id, nextStatus),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                          ),
                          child: Text('Mark as ${nextStatus.toDisplayString()}'),
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

  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.orderPlaced:
        return Colors.blue;
      case ServiceStatus.providerOnTheWay:
        return Colors.orange;
      case ServiceStatus.providerArrived:
        return Colors.purple;
      case ServiceStatus.washingStarted:
        return Colors.indigo;
      case ServiceStatus.paying:
        return Colors.amber;
      case ServiceStatus.completed:
        return Colors.green;
      case ServiceStatus.cancelled:
        return Colors.red;
    }
  }
}
