import 'package:flutter/material.dart';
import 'package:lamaa/theme/text_style.dart';

import '../color_scheme.dart';

final inputDecorationThemeLight = InputDecorationTheme(
  filled: false,
  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  hintStyle: AppTextStyles.lightTextTheme.labelSmall,
  labelStyle: AppTextStyles.lightTextTheme.labelMedium,
  floatingLabelBehavior: FloatingLabelBehavior.always,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: AppColors.lightColorScheme.onTertiary, // subtle outline
      width: 1.2,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: AppColors.lightColorScheme.primary, //  primary
      width: 1.4,
    ),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: AppColors.lightColorScheme.error, width: 1.2),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: AppColors.lightColorScheme.error.withAlpha(150),
      width: 1.4,
    ),
  ),
  suffixIconColor: AppColors.lightColorScheme.surface,
  prefixIconColor: AppColors.lightColorScheme.surface,
);
