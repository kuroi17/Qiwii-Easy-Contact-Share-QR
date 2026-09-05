import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized TextStyle tokens for Qiwii
class AppTextStyles {
  // Brand — Modern bold brand display (Plus Jakarta Sans)
  static TextStyle brand({
    double fontSize = 22,
    Color color = AppColors.ink,
    double letterSpacing = -0.5,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Display — screen titles, hero headlines (Plus Jakarta Sans)
  static TextStyle display({
    double fontSize = 28,
    Color color = AppColors.ink,
    double height = 1.15,
    double letterSpacing = -0.6,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Display on Dark Canvas (Plus Jakarta Sans)
  static TextStyle displayDark({
    double fontSize = 26,
    Color color = Colors.white,
    double height = 1.15,
    double letterSpacing = -0.6,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Card Header / Action Titles in Plus Jakarta Sans
  static TextStyle cardTitle({
    double fontSize = 21,
    Color color = Colors.white,
    double letterSpacing = -0.4,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: letterSpacing,
      );

  // Title — standard section/list headers (Plus Jakarta Sans)
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

  static const TextStyle bodyDark = TextStyle(
    color: AppColors.darkSubtitle,
    fontSize: 15,
    height: 1.5,
  );
}
