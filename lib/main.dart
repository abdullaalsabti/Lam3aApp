import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/pages/client/main_page.dart';
import 'package:lamaa/pages/service-provider/onboarding_services.dart';
import 'package:lamaa/pages/service-provider/provider_main_page.dart';
import 'package:lamaa/theme/app_theme.dart';
//pages
import 'pages/both/extended_signup.dart';
import 'pages/both/phone_signup.dart';
import 'pages/both/first_page.dart';
import 'pages/both/splash_screen.dart';
import 'pages/both/loginSignup.dart';
import 'pages/client/garage_add.dart';
import 'pages/client/garage_page.dart';
import 'pages/client/service_selection.dart';
import 'pages/client/date_time_selection.dart';
import 'pages/client/provider_selection.dart';
import 'pages/client/client_requests.dart';
import 'pages/client/client_home.dart';

import 'pages/service-provider/provider_availability.dart';
import 'pages/service-provider/provider_available_requests.dart';
import 'pages/service-provider/provider_my_requests.dart';
import 'models/service_category.dart';

void main() async {
  // Ensure bindings before any async platform operations or plugin initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try loading .env file - it should be in the project root (same directory as pubspec.yaml)
    await dotenv.load(fileName: '.env');
    debugPrint('Loaded .env successfully. API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Using default API_BASE_URL: 192.168.1.11:5003');
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,

      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/first_page': (context) => const FirstPage(),
        '/login_page': (context) => const LoginClient(),
        '/phone_signup': (context) => const PhoneSignup(),
        '/extended_signup': (context) => const ExtendedSignup(),
        '/main_page': (context) => const MainPage(),
        '/garage': (context) => const GaragePage(),
        '/garage_add': (context) => const GarageAdd(),
        '/service_selection': (context) => const ServiceSelectionPage(),
        '/date_time_selection': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as ServiceCategory;
          return DateTimeSelectionPage(category: args);
        },
        '/provider_selection': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ProviderSelectionPage(requestData: args);
        },
        '/client_requests': (context) => const ClientRequestsPage(),
        '/provider_services': (context) => const OnBoardingServices(isOnboarding: true), // Signup flow
        '/provider_add_service': (context) => const OnBoardingServices(isOnboarding: false), // Logged-in flow
        '/client_home': (context) => const ClientHomePage(),
        '/provider_availability': (context) => const ProviderAvailabilityPage(),
        '/provider_available_requests': (context) => const ProviderAvailableRequestsPage(),
        '/provider_my_requests': (context) => const ProviderMyRequestsPage(),
        '/provider_main': (context) => const ProviderMainPage(),
      },
    );
  }
}
