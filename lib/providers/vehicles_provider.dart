import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';

// Provider to fetch and cache vehicles from backend
final vehiclesProvider = FutureProvider<List<Vehicle>>((ref) async {
  try {
    final response = await ApiService().getAuthenticated('client/Vehicle/getVehicles');
    
    if (response.statusCode == 200) {
      final responseBody = response.body;
      
      final List<dynamic> data = jsonDecode(responseBody);
      
      final vehicles = data.map((v) {
        return Vehicle.fromJson(v);
      }).toList();
      
      return vehicles;
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  } catch (e, stackTrace) {

    throw Exception('Error loading vehicles: $e');
  }
});

// Provider to refresh vehicles (invalidate cache)
final vehiclesRefreshProvider = Provider((ref) {
  return () {
    ref.invalidate(vehiclesProvider);
  };
});

