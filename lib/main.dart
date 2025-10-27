import 'package:flutter/material.dart';
import 'package:lamaa/theme/app_theme.dart';
import 'pages/first_page.dart';

void main() {
  final themeMode = ThemeMode.system;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      home: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FirstPage(),
    );
  }
}
