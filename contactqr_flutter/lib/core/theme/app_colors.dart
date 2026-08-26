import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accent (Pumpkin Orange Palette)
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFE85822);
  static const Color primaryLight = Color(0xFFFFF3EB);
  static const Color primarySoft = Color(0xFFFFE8DD);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF521B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Canvas & Surfaces (Porcelain & Pure White)
  static const Color canvas = Color(0xFFF8F9FD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F5F9);
  static const Color cardBorder = Color(0xFFECEFF5);
  static const Color divider = Color(0xFFEDF1F7);

  // Typography & Content
  static const Color textPrimary = Color(0xFF171A1F);
  static const Color textSecondary = Color(0xFF6B7485);
  static const Color textMuted = Color(0xFF9EA7B5);
  static const Color textOnPrimary = Colors.white;

  // Accents & Semantics
  static const Color teal = Color(0xFF00BFA5);
  static const Color tealLight = Color(0xFFE0F7F4);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFE8F8F2);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Dark Canvas (For Scanner & Viewfinder)
  static const Color darkCanvas = Color(0xFF0E1015);
  static const Color darkSurface = Color(0xFF181B22);
  static const Color darkBorder = Color(0xFF262B36);

  // Silky Elevation Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0A101828),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x05101828),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x40FF6B35),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // Legacy mappings for backwards compatibility
  static const Color navy = textPrimary;
  static const Color darkNavy = darkCanvas;
  static const Color darkNavyBorder = darkBorder;
  static const Color ivory = canvas;
  static const Color border = cardBorder;
  static const Color slate = textSecondary;
  static const Color subtitleLight = Color(0xFF9EA7B5);
  static const Color handleBar = Color(0xFFD1D5DB);
  static const Color mint = primaryLight;
}
