import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/models/client_orders.dart';
import '../services/api_service.dart';
import '../enums/service_status.dart';

// Provider to fetch all client orders (without status filter)
final clientOrdersProvider = FutureProvider<List<ClientOrder>>((ref) async {
  try {
    final response = await ApiService().getAuthenticated('client/ServiceRequest');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((r) => ClientOrder.fromJson(r)).toList();
    } else {
      throw Exception('Failed to load client orders: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading client orders: $e');
  }
});

// Provider to categorize orders into upcoming and past
final categorizedClientOrdersProvider = Provider<({
  List<ClientOrder> upcoming,
  List<ClientOrder> past,
})>((ref) {
  final ordersAsync = ref.watch(clientOrdersProvider);
  
  return ordersAsync.when(
    data: (orders) {
      final upcoming = <ClientOrder>[];
      final past = <ClientOrder>[];
      final now = DateTime.now();
      
      for (final order in orders) {
        // Check if order is in the past (scheduled end time has passed)
        final isPast = order.scheduledEndTime.isBefore(now) ||
            order.status == ServiceStatus.completed ||
            order.status == ServiceStatus.cancelled ||
            order.status == ServiceStatus.rejected;
        
        if (isPast) {
          past.add(order);
        } else {
          upcoming.add(order);
        }
      }
      
      // Sort upcoming by scheduled start time (earliest first)
      upcoming.sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));
      // Sort past by scheduled start time (most recent first)
      past.sort((a, b) => b.scheduledStartTime.compareTo(a.scheduledStartTime));
      
      return (upcoming: upcoming, past: past);
    },
    loading: () => (upcoming: [], past: []),
    error: (_, __) => (upcoming: [], past: []),
  );
});

// Provider to refresh orders
final clientOrdersRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(clientOrdersProvider);
  };
});

