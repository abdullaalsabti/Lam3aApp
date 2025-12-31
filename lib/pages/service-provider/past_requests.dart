import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/models/service_request.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/widgets/provider_request_card.dart';
import 'package:lamaa/providers/provider_orders_provider.dart';
import 'package:lamaa/enums/service_status.dart';

class PastRequests extends ConsumerStatefulWidget {
  const PastRequests({super.key});

  @override
  ConsumerState<PastRequests> createState() => _PastRequestsState();
}

class _PastRequestsState extends ConsumerState<PastRequests> {
  final String API_KEY = "AIzaSyByCDOzdRCx0cJhxim3I-d8p0wm2--705Q";
  
  // Track which request is being processed
  String? _updatingStatusRequestId;

  @override
  void initState() {
    super.initState();
    // Refresh orders when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(providerOrdersRefreshProvider).call();
    });
  }

  Future<void> _updateOrderStatus(String requestId, ServiceStatus newStatus) async {
    setState(() {
      _updatingStatusRequestId = requestId;
    });

    try {
      // Backend expects query parameter, not body - use empty body
      final response = await ApiService().putAuthenticated(
        'provider/ProviderOrder/$requestId/status?newStatus=${newStatus.toApiString()}',
        {},
      );

      if (response.statusCode == 200) {
        // Refresh orders after successful update
        ref.invalidate(providerOrdersProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to ${newStatus.toDisplayString()}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Failed to update status';
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
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
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _updatingStatusRequestId = null;
        });
      }
    }
  }

  Widget _buildOrdersList(List<ProviderServiceRequest> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(providerOrdersProvider);
        await ref.read(providerOrdersProvider.future);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return ProviderRequestCard(
            req: order,
            apiKey: API_KEY,
            showStatusBadge: true,
            isUpdatingStatus: _updatingStatusRequestId == order.requestId,
            onStatusUpdate: (newStatus) => _updateOrderStatus(order.requestId, newStatus),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorizedOrders = ref.watch(categorizedProviderOrdersProvider);
    final ordersAsync = ref.watch(providerOrdersProvider);

    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
      
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Current'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
            ),
      
            const SizedBox(height: 16),
      
            // Tab content
            Expanded(
              child: ordersAsync.when(
                data: (_) => TabBarView(
                  children: [
                    _buildOrdersList(categorizedOrders.upcoming),
                    _buildOrdersList(categorizedOrders.current),
                    _buildOrdersList(categorizedOrders.past),
                  ],
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
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
                        'Error loading orders',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.invalidate(providerOrdersProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
