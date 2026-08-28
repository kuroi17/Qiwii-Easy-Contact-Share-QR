import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized TextStyle tokens for Qiwii
class AppTextStyles {
  // Brand — Titan One logo and prominent brand display
  static TextStyle brand({
    double fontSize = 22,
    Color color = AppColors.ink,
    double letterSpacing = 0.5,
  }) =>
      GoogleFonts.titanOne(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Display — screen titles, hero headlines
  static const TextStyle display = TextStyle(
    color: AppColors.ink,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.8,
  );

  // Title — section/card headers
  static const TextStyle title = TextStyle(
    color: AppColors.ink,
    fontSize: 17,
    fontWeight: FontWeight.w700,
  );

  // Body — default readable text
  static const TextStyle body = TextStyle(
    color: AppColors.ink2,
    fontSize: 15,
    height: 1.5,
  );

  // Caption — secondary, timestamps, hints
  static const TextStyle caption = TextStyle(
    color: AppColors.ink3,
    fontSize: 12,
    height: 1.4,
  );

  // Label — status pills, uppercase chips
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // On dark canvas
  static const TextStyle displayDark = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.6,
  );

  static const TextStyle bodyDark = TextStyle(
    color: AppColors.darkSubtitle,
    fontSize: 15,
    height: 1.5,
  );
}
