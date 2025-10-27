import 'package:flutter/material.dart';
import 'package:lamaa/theme/color_scheme.dart';
import 'package:lamaa/theme/text_style.dart';
import 'package:lamaa/theme/widgets/elevated_button_theme.dart';
import 'package:lamaa/theme/widgets/input_decoration_theme.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextStyles.lightTextTheme,
    inputDecorationTheme: inputDecorationThemeLight,
    elevatedButtonTheme: elevatedButtonThemeLight,
  );
}
