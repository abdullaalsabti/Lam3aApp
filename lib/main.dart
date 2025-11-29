import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/theme/app_theme.dart';
//pages
import 'pages/extended_signup.dart';
import 'pages/phone_signup.dart';
import 'pages/first_page.dart';
import 'pages/loginSignup_client.dart';
import 'pages/empty_garage.dart';
import 'pages/garage_add.dart';
import 'pages/garage_page.dart';

void main() async {
  // Ensure bindings before any async platform operations or plugin initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Try loading .env file - it should be in the project root (same directory as pubspec.yaml)
    await dotenv.load(fileName: '.env');
    debugPrint('Loaded .env successfully. API_BASE_URL: ${dotenv.env['API_BASE_URL']}');
  } catch (e, st) {
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

      initialRoute: '/first_page',
      routes: {
        '/first_page': (context) => const FirstPage(),
        '/login_page': (context) => const LoginClient(),
        '/phone_signup': (context) => const PhoneSignup(),
        '/extended_signup': (context) => const ExtendedSignUp(),
        '/empty_garage': (context) => const EmptyGarage(),
        '/garage': (context) => const GaragePage(),
        '/garage_add': (context) => const GarageAdd(),
      },
    );
  }
}
