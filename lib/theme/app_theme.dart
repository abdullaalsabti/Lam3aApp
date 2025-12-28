import 'package:flutter/material.dart';
import 'package:lamaa/theme/color_scheme.dart';
import 'package:lamaa/theme/text_style.dart';
import 'package:lamaa/widgets/elevated_button_theme.dart';
import 'package:lamaa/widgets/input_decoration_theme.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextStyles.lightTextTheme,
    inputDecorationTheme: inputDecorationThemeLight,
    elevatedButtonTheme: elevatedButtonThemeLight,
    appBarTheme: const AppBarTheme(
      iconTheme: IconThemeData(
        color: Colors.white, // White back button and icons
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.white, // White action icons
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF23918C), // Primary teal
      unselectedItemColor: Color(0XFF6B7A8F), // Gray
      selectedLabelStyle: TextStyle(fontSize: 12),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 8,
    ),
  );
}
