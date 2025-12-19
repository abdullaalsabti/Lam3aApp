import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/car_brand.dart';
import '../services/api_service.dart';
import '../dummy_garage_json.dart';

// Provider to fetch and cache brands from backend
final brandsProvider = FutureProvider<List<CarBrand>>((ref) async {
  try {
    final response = await ApiService().get('api/ModelBrand');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((b) => CarBrand.fromJson(b)).toList();
    } else {
      // Fallback to dummy data if API fails
      return dummyJson.map((b) => CarBrand.fromJson(b)).toList();
    }
  } catch (e) {
    // Fallback to dummy data on error
    return dummyJson.map((b) => CarBrand.fromJson(b)).toList();
  }
});










