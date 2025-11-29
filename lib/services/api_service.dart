import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _storage = const FlutterSecureStorage();
  
  // API Base URL - hardcoded for physical device
  static const String _baseUrl = '192.168.1.11:5003';
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<void> saveTokens(String token, String refreshToken) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }

  // Helper to get full URL
  Uri _getUri(String endpoint) {
    // Construct full URL
    String fullPath = _baseUrl.endsWith('/') ? '$_baseUrl$endpoint' : '$_baseUrl/$endpoint';
    
    // Add http:// if not present
    if (!fullPath.startsWith('http')) {
      fullPath = 'http://$fullPath';
    }
    return Uri.parse(fullPath);
  }

  // Generic POST request with Auth
  Future<http.Response> postAuthenticated(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = _getUri(endpoint);
    
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  // Generic GET request with Auth
  Future<http.Response> getAuthenticated(String endpoint) async {
    final token = await getToken();
    final url = _getUri(endpoint);

    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }

  // Generic GET request without Auth (for public endpoints)
  Future<http.Response> get(String endpoint) async {
    final url = _getUri(endpoint);
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // Generic PUT request with Auth
  Future<http.Response> putAuthenticated(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = _getUri(endpoint);
    
    return await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  // Generic DELETE request with Auth
  Future<http.Response> deleteAuthenticated(String endpoint) async {
    final token = await getToken();
    final url = _getUri(endpoint);

    return await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
  }
}

