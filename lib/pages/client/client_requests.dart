import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/service_requests_provider.dart';
import '../../enums/service_status.dart';
import 'dart:convert';
import '../../services/api_service.dart';

class ClientRequestsPage extends ConsumerStatefulWidget {
  const ClientRequestsPage({super.key});

  @override
  ConsumerState<ClientRequestsPage> createState() => _ClientRequestsPageState();
}

class _ClientRequestsPageState extends ConsumerState<ClientRequestsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      final response = await ApiService().putAuthenticated(
        'client/ServiceRequest/cancel/$requestId',
        {},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Request cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
          ref.invalidate(serviceRequestsProvider);
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData['message'] ?? 'Failed to cancel request'),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList(ServiceStatus.orderPlaced, isUpcoming: true),
          _buildRequestsList(null, isUpcoming: false),
        ],
      ),
    );
  }

  Widget _buildRequestsList(ServiceStatus? status, {required bool isUpcoming}) {
    final requestsAsync = ref.watch(serviceRequestsProvider(status));

    return requestsAsync.when(
      data: (requests) {
        // Filter upcoming vs past
        final now = DateTime.now();
        final filteredRequests = requests.where((req) {
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
          onRefresh: () async {
            ref.invalidate(serviceRequestsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              final request = filteredRequests[index];
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
                      if (request.provider != null)
                        Text(
                          'Provider: ${request.provider!.firstName} ${request.provider!.lastName}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Date: ${DateFormat('MMM dd, yyyy at HH:mm').format(request.requestedDateTime)}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      if (request.vehicle != null)
                        Text(
                          'Vehicle: ${request.vehicle!.brand} ${request.vehicle!.model}',
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      if (isUpcoming &&
                          (request.status == ServiceStatus.orderPlaced ||
                           request.status == ServiceStatus.providerOnTheWay))
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _cancelRequest(request.id),
                              child: const Text('Cancel'),
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
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(serviceRequestsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
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
