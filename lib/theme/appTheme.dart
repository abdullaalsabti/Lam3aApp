import 'package:flutter/material.dart';
import 'package:lamaa/theme/colorScheme.dart';
import 'package:lamaa/theme/textStyle.dart';
import 'package:lamaa/theme/widgets/elevatedButtonTheme.dart';
import 'package:lamaa/theme/widgets/inputDecorationTheme.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTextStyles.lightTextTheme,
    inputDecorationTheme: inputDecorationThemeLight,
    elevatedButtonTheme: elevatedButtonThemeLight,
  );
}
