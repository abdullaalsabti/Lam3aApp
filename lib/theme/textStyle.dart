import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lamaa/theme/colorScheme.dart';

class AppTextStyles {
  static final lightTextTheme = TextTheme(
    titleLarge: GoogleFonts.poppins(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: AppColors.lightColorScheme.onSecondaryContainer,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.2,
      color: AppColors.lightColorScheme.onSecondaryContainer,
    ),
    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.lightColorScheme.onSecondaryContainer,
    ),
    labelMedium: GoogleFonts.poppins(
      color: AppColors.lightColorScheme.outlineVariant, // darker gray
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
    labelSmall: GoogleFonts.poppins(
      color: AppColors.lightColorScheme.onTertiary, // soft gray
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  );

  // static final darkTextTheme = TextTheme(
  //   titleLarge: GoogleFonts.poppins(
  //     fontSize: 26,
  //     fontWeight: FontWeight.w700,
  //     height: 1.2,
  //     color: AppColors.darkColorScheme.onPrimary,
  //   ),
  //   titleMedium: GoogleFonts.poppins(
  //     fontSize: 18,
  //     fontWeight: FontWeight.w600,
  //     height: 1.2,
  //     color: AppColors.lightColorScheme.onPrimary,
  //   ),
  //   bodyMedium: GoogleFonts.poppins(
  //     fontSize: 14,
  //     fontWeight: FontWeight.w400,
  //     height: 1.4,
  //     color: AppColors.lightColorScheme.onPrimary,
  //   ),
  //   labelMedium: GoogleFonts.poppins(
  //     color: AppColors.lightColorScheme.onSurface, // darker gray
  //     fontSize: 16,
  //     fontWeight: FontWeight.w500,
  //   ),
  //   labelSmall: GoogleFonts.poppins(
  //     color: AppColors.lightColorScheme.onTertiary, // soft gray
  //     fontSize: 12,
  //     fontWeight: FontWeight.w300,
  //   ),
  // );
}
