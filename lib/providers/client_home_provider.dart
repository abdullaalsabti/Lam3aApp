import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_home.dart';
import '../services/api_service.dart';

// Provider to fetch and cache client home data
final clientHomeProvider = FutureProvider<ClientHomeData>((ref) async {
  try {
    final response = await ApiService().getAuthenticated('api/client/Home');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ClientHomeData.fromJson(data);
    } else {
      print('Failed to load home data: Status ${response.statusCode}');
      throw Exception('Failed to load home data: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading home data: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Error loading home data: $e');
  }
});



