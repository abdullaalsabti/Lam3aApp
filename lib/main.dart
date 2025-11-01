import 'package:flutter/material.dart';
import 'package:lamaa/theme/app_theme.dart';
import 'pages/first_page.dart';
import 'pages/login_client.dart';
import 'package:lamaa/pages/signup_client.dart';

void main() {
  final themeMode = ThemeMode.system;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      home: FirstPage(),
      initialRoute: '/first_page',
      routes: {
        '/first_page': (context) => const FirstPage(),
        '/login_page' : (context) => const LoginClient(),
        '/signup_page' : (context) => const SignupClient()
      },
    ),
  );
}
