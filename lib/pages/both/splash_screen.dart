import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/services/api_service.dart';
import 'package:lamaa/enums/role.dart';
import 'package:lamaa/providers/sign_up_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    try {
      // Add a small delay for splash screen visibility
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      final apiService = ApiService();
      final refreshToken = await apiService.getRefreshToken();

      // No refresh token - go to first page (role selection)
      if (refreshToken == null || refreshToken.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/first_page');
        }
        return;
      }

      // Try to refresh the access token
      final refreshed = await apiService.refreshAccessToken();

      if (!mounted) return;

      if (!refreshed) {
        // Refresh failed - clear tokens and go to first page
        await apiService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/first_page');
        }
        return;
      }

      // Successfully refreshed - get user role and navigate
      await _navigateToHome(apiService);
    } catch (e) {
      // Handle any errors (network timeouts, etc.) - navigate to first page
      debugPrint('Error during auto login: $e');
      if (mounted) {
        final apiService = ApiService();
        await apiService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/first_page');
        }
      }
    }
  }

  Future<void> _navigateToHome(ApiService apiService) async {
    try {
      // Try to get user profile to determine role
      final response = await apiService.getAuthenticated('api/client/ClientProfile/getProfile');
      
      if (response.statusCode == 200) {
        // User is a client
        ref.read(signupProvider.notifier).reset();
        ref.read(signupProvider.notifier).updateRole(Role.client);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main_page');
        }
        return;
      }
    } catch (e) {
      debugPrint('Error getting client profile: $e');
      // If client profile fails, try provider profile
    }

    try {
      final response = await apiService.getAuthenticated('api/provider/ProviderProfile/getProfile');
      
      if (response.statusCode == 200) {
        // User is a provider
        ref.read(signupProvider.notifier).reset();
        ref.read(signupProvider.notifier).updateRole(Role.provider);
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/provider_main');
        }
        return;
      }
    } catch (e) {
      debugPrint('Error getting provider profile: $e');
      // Both failed - clear tokens and go to first page
    }
    
    // If we reach here, both profile checks failed - navigate to first page
    await apiService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/first_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Image.asset(
                'lib/assets/images/lam3a-logo2.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.local_car_wash,
                    size: 100,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),
              
              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

