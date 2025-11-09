import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lamaa/pages/signup_client.dart';
import 'package:lamaa/theme/app_theme.dart';

import 'pages/first_page.dart';
import 'pages/login_client.dart';

void main() async {
  // Add this to ensure Flutter bindings are initialized
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

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
        '/signup_page': (context) => const SignupClient(),
      },
    );
  }
}
