import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_request.dart';
import '../enums/service_status.dart';
import '../services/api_service.dart';

// Provider to fetch and cache service requests from backend
final serviceRequestsProvider = FutureProvider.family<List<ServiceRequest>, ServiceStatus?>((ref, status) async {
  try {
    String endpoint = 'api/client/ServiceRequest/getRequests';
    if (status != null) {
      endpoint += '?status=${status.name}';
    }
    
    final response = await ApiService().getAuthenticated(endpoint);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((r) => ServiceRequest.fromJson(r)).toList();
    } else {
      print('Failed to load service requests: Status ${response.statusCode}');
      throw Exception('Failed to load service requests: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading service requests: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Error loading service requests: $e');
  }
});

// Provider to refresh service requests (invalidate cache)
final serviceRequestsRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(serviceRequestsProvider);
  };
});
