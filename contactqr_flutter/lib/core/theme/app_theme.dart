import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.teal,
        primary: AppColors.teal,
        secondary: AppColors.navy,
        surface: AppColors.ivory,
      ),
      fontFamilyFallback: const ['Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial'],
    );
  }
}
