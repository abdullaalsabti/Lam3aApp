import 'package:flutter/material.dart';
import 'package:lamaa/theme/color_scheme.dart';
import 'package:lamaa/theme/text_style.dart';

final elevatedButtonThemeLight = ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightColorScheme.primary,
    foregroundColor: Colors.white,
    elevation: 10,
    shadowColor: Colors.black,
    textStyle: AppTextStyles.lightTextTheme.titleMedium,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
  ),
);
