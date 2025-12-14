import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:lamaa/enums/role.dart';
import 'package:lamaa/providers/client_home_provider.dart';
import 'package:lamaa/providers/service_requests_provider.dart';
import 'package:lamaa/providers/sign_up_providers.dart';
import 'package:lamaa/providers/vehicles_provider.dart';
import 'package:lamaa/services/api_service.dart';

/// Service class for handling authentication business logic
class AuthService {
  final ApiService _apiService = ApiService();

  /// Login with email and password
  Future<AuthResult> login({
    required String email,
    required String password,
    required Role role,
    required WidgetRef ref,
  }) async {
    try {
      final response = await _apiService.post(
        'api/Auth/login',
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'] as String;
        final refreshToken = responseBody['refreshToken'] as String;

        // Validate role from JWT token
        final roleValidation = _validateRole(token, role);
        if (!roleValidation.isValid) {
          return AuthResult.error(roleValidation.errorMessage!);
        }

        // Save tokens
        await _apiService.saveTokens(token, refreshToken);

        // Clear cached data
        _clearCachedData(role, ref);

        // Update signup provider
        final selectedRole = ref.read(signupProvider).role;
        ref.read(signupProvider.notifier).reset();
        ref.read(signupProvider.notifier).updateRole(selectedRole);

        return AuthResult.success(selectedRole);
      } else {
        return AuthResult.error(_extractErrorMessage(response));
      }
    } catch (e) {
      return AuthResult.error(_extractNetworkErrorMessage(e));
    }
  }

  /// Register new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required Role role,
    required WidgetRef ref,
  }) async {
    try {
      final response = await _apiService.post(
        'api/Auth/register',
        {
          'email': email,
          'password': password,
          'role': role.index,
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final userId = responseBody['userId']?.toString() ?? '';
        final message = responseBody['message'] ?? 'Registration successful';

        // Save credentials to signup provider for auto-login
        ref.read(signupProvider.notifier).updateEmail(email);
        ref.read(signupProvider.notifier).updatePassword(password);
        ref.read(signupProvider.notifier).updateUserId(userId);
        ref.read(signupProvider.notifier).updatePhone('+962700000000');

        return AuthResult.success(role, message: message);
      } else {
        return AuthResult.error(_extractErrorMessage(response));
      }
    } catch (e) {
      return AuthResult.error(_extractNetworkErrorMessage(e));
    }
  }

  /// Auto-login after registration
  Future<AuthResult> loginAfterSignup({
    required WidgetRef ref,
  }) async {
    try {
      final signupData = ref.read(signupProvider);
      final loginEmail = signupData.email;
      final loginPassword = signupData.password;

      if (loginEmail.isEmpty || loginPassword.isEmpty) {
        return AuthResult.error(
          'Error: Email or password not saved. Please try again.',
        );
      }

      final response = await _apiService.post(
        'api/Auth/login',
        {'email': loginEmail, 'password': loginPassword},
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'] as String;
        final refreshToken = responseBody['refreshToken'] as String;

        // Save tokens
        await _apiService.saveTokens(token, refreshToken);

        // Clear cached data
        ref.invalidate(vehiclesProvider);
        ref.invalidate(clientHomeProvider);
        ref.invalidate(serviceRequestsProvider);

        return AuthResult.success(signupData.role);
      } else {
        return AuthResult.error(_extractErrorMessage(response));
      }
    } catch (e) {
      return AuthResult.error(_extractNetworkErrorMessage(e));
    }
  }

  /// Validate role from JWT token
  RoleValidationResult _validateRole(String token, Role expectedRole) {
    try {
      final decodedToken = JwtDecoder.decode(token);
      
      // Check both simple name and .NET claim name
      final jwtRole = decodedToken['role'] ?? 
                     decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? '';
      
      final expectedRoleName = expectedRole.name.toLowerCase();
      final actualRoleName = jwtRole.toString().toLowerCase();

      if (actualRoleName != expectedRoleName) {
        return RoleValidationResult(
          isValid: false,
          errorMessage: 'Role Mismatch! You are not ${expectedRole.name}',
        );
      }

      return RoleValidationResult(isValid: true);
    } catch (e) {
      return RoleValidationResult(
        isValid: false,
        errorMessage: 'Invalid token format',
      );
    }
  }

  /// Clear cached data based on role
  void _clearCachedData(Role role, WidgetRef ref) {
    if (role == Role.client) {
      ref.invalidate(vehiclesProvider);
      ref.invalidate(clientHomeProvider);
    }
  }

  /// Extract error message from API response
  String _extractErrorMessage(http.Response response) {
    try {
      final errorBody = jsonDecode(response.body);
      return errorBody['message'] ?? 
             errorBody['error'] ?? 
             errorBody['Message'] ?? 
             _getStatusCodeMessage(response.statusCode);
    } catch (e) {
      return _getStatusCodeMessage(response.statusCode);
    }
  }

  /// Get error message based on status code
  String _getStatusCodeMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Invalid email or password';
      case 409:
        return 'Email is already registered';
      case 400:
        return 'Invalid request. Please check your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  /// Extract network error message
  String _extractNetworkErrorMessage(dynamic error) {
    final errorString = error.toString();
    
    if (errorString.contains('Connection timed out')) {
      return 'Connection timed out. Please check if the server is running.';
    } else if (errorString.contains('Failed host lookup')) {
      return 'Cannot reach server. Please check your network connection.';
    } else if (errorString.contains('SocketException')) {
      return 'Network error. Please check your connection.';
    }
    
    return 'Network error. Please check your internet connection.';
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool isSuccess;
  final Role? role;
  final String? errorMessage;
  final String? successMessage;

  AuthResult._({
    required this.isSuccess,
    this.role,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthResult.success(Role role, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      role: role,
      successMessage: message,
    );
  }

  factory AuthResult.error(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}

/// Role validation result
class RoleValidationResult {
  final bool isValid;
  final String? errorMessage;

  RoleValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

