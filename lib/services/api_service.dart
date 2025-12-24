import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _storage = const FlutterSecureStorage();
  
  /// API Base URL (configure via `.env` using `API_BASE_URL`)
  ///
  /// Examples:
  /// - Phone over USB (recommended): `http://127.0.0.1:5003` + `adb reverse tcp:5003 tcp:5003`
  /// - Same Wi‑Fi LAN: `http://192.168.1.11:5002` (backend must bind `0.0.0.0:5002`)
  static String get _baseUrl {
    final env = dotenv.env['API_BASE_URL'];
    if (env != null && env.trim().isNotEmpty) return env.trim();
    // Default to adb-reverse friendly URL.
    return 'http://127.0.0.1:5003';
  }
  
  // Timeout duration for HTTP requests (10 seconds)
  static const Duration _timeoutDuration = Duration(seconds: 10);
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  Future<void> saveTokens(String token, String refreshToken) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// Refresh access token using refresh token
  /// Returns true if successful, false otherwise
  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final url = _getUri('api/Auth/refreshToken');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'RefreshToken': refreshToken}),
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final newToken = responseBody['token'] as String;
        final newRefreshToken = responseBody['refreshToken'] as String;
        
        await saveTokens(newToken, newRefreshToken);
        return true;
      } else {
        // Refresh token expired or invalid - clear tokens
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await logout();
      return false;
    }
  }

  // Helper to get full URL
  Uri _getUri(String endpoint) {
    var base = _baseUrl;
    if (!base.startsWith('http://') && !base.startsWith('https://')) {
      base = 'http://$base';
    }

    final baseUri = Uri.parse(base.endsWith('/') ? base : '$base/');
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return baseUri.resolve(normalizedEndpoint);
  }

  // Generic POST request with Auth (with auto-refresh on 401)
  Future<http.Response> postAuthenticated(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = _getUri(endpoint);
    
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(_timeoutDuration);

    // If 401, try to refresh token and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getToken();
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body),
        ).timeout(_timeoutDuration);
      }
    }

    return response;
  }

    Future<http.Response> post(String endpoint , Map<String, dynamic> body ) async {
    final url = _getUri(endpoint);
    return await http.post(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    ).timeout(_timeoutDuration);
  }

  // Generic GET request with Auth (with auto-refresh on 401)
  Future<http.Response> getAuthenticated(String endpoint) async {
    final token = await getToken();
    final url = _getUri(endpoint);

    var response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).timeout(_timeoutDuration);

    // If 401, try to refresh token and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getToken();
        response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $newToken',
          },
        ).timeout(_timeoutDuration);
      }
    }

    return response;
  }

  // Generic GET request without Auth (for public endpoints)
  Future<http.Response> get(String endpoint) async {
    final url = _getUri(endpoint);
    return await http.get(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    ).timeout(_timeoutDuration);
  }

  // Generic PUT request with Auth (with auto-refresh on 401)
  Future<http.Response> putAuthenticated(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = _getUri(endpoint);
    
    var response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(_timeoutDuration);

    // If 401, try to refresh token and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getToken();
        response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body),
        ).timeout(_timeoutDuration);
      }
    }

    return response;
  }

  // Generic DELETE request with Auth (with auto-refresh on 401)
  Future<http.Response> deleteAuthenticated(String endpoint) async {
    final token = await getToken();
    final url = _getUri(endpoint);

    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    ).timeout(_timeoutDuration);

    // If 401, try to refresh token and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getToken();
        response = await http.delete(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $newToken',
          },
        ).timeout(_timeoutDuration);
      }
    }

    return response;
  }

  // Generic PATCH request with Auth (with auto-refresh on 401)
  Future<http.Response> patchAuthenticated(String endpoint, Map<String, dynamic> body) async {
    final token = await getToken();
    final url = _getUri(endpoint);
    
    var response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(_timeoutDuration);

    // If 401, try to refresh token and retry once
    if (response.statusCode == 401) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        final newToken = await getToken();
        response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body),
        ).timeout(_timeoutDuration);
      }
    }

    return response;
  }
}

