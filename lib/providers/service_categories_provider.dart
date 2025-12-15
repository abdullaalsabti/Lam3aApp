import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_category.dart';
import '../services/api_service.dart';

// Provider to fetch and cache service categories from backend
final serviceCategoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  try {
    final response = await ApiService().get('api/provider/Services/categories');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((c) => ServiceCategory.fromJson(c)).toList();
    } else {
      print('Failed to load service categories: Status ${response.statusCode}');
      throw Exception('Failed to load service categories: ${response.statusCode}');
    }
  } catch (e, stackTrace) {
    print('Error loading service categories: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Error loading service categories: $e');
  }
});





