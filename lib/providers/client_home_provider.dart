import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_home.dart';
import '../services/api_service.dart';

// Provider to fetch and cache client home data
final clientHomeProvider = FutureProvider<ClientHomeData>((ref) async {
  try {
    final response = await ApiService().getAuthenticated('client/Home');
    
    if (response.statusCode == 200) {
      print("response is ${response.body}");
      final data = jsonDecode(response.body);
      print("data is ${data}");
      return ClientHomeData.fromJson(data);
    } else {
      throw Exception('Failed to load home data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error loading home data: $e');
  }
});






