import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_request.dart';
import '../services/api_service.dart';
import '../enums/service_status.dart';

// Provider to fetch all provider orders (without status filter)
final providerOrdersProvider = FutureProvider<List<ProviderServiceRequest>>((ref) async {
  try {
    final response = await ApiService().getAuthenticated(
      'provider/ProviderOrder/getOrders',
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((r) => ProviderServiceRequest.fromJson(r)).toList();
    } else {
      throw Exception('Failed to load provider orders: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading provider orders: $e');
  }
});

// Provider to categorize orders into upcoming, current, and past
final categorizedProviderOrdersProvider = Provider<({
  List<ProviderServiceRequest> upcoming,
  List<ProviderServiceRequest> current,
  List<ProviderServiceRequest> past,
})>((ref) {
  final ordersAsync = ref.watch(providerOrdersProvider);
  
  return ordersAsync.when(
    data: (orders) {
      final upcoming = <ProviderServiceRequest>[];
      final current = <ProviderServiceRequest>[];
      final past = <ProviderServiceRequest>[];
      
      for (final order in orders) {
        switch (order.status) {
          case ServiceStatus.accepted:
            upcoming.add(order);
            break;
          case ServiceStatus.providerOnTheWay:
          case ServiceStatus.providerArrived:
          case ServiceStatus.washingStarted:
          case ServiceStatus.paying:
            current.add(order);
            break;
          case ServiceStatus.completed:
          case ServiceStatus.cancelled:
          case ServiceStatus.rejected:
            past.add(order);
            break;
          case ServiceStatus.pending:
            // Pending orders are typically shown in available requests, not here
            // But if they appear, we can add them to upcoming
            upcoming.add(order);
            break;
          default:
            // Handle any other statuses
            past.add(order);
        }
      }
      
      // Sort by scheduled start time (most recent first for past, upcoming first for upcoming/current)
      upcoming.sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));
      current.sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));
      past.sort((a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime));
      
      return (upcoming: upcoming, current: current, past: past);
    },
    loading: () => (upcoming: [], current: [], past: []),
    error: (_, __) => (upcoming: [], current: [], past: []),
  );
});

// Provider to refresh orders
final providerOrdersRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(providerOrdersProvider);
  };
});

