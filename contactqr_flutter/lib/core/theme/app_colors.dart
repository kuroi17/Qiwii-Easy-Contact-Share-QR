import 'package:flutter/material.dart';

/// ContactQR / Qiwii Orange Ember Design System
/// Inspired by modern warm-minimalist card interfaces
/// Accent: #FF7A1A (Vibrant Warm Orange)
/// Canvas: #FAF1E8 (Warm Sand / Almond Cream)
class AppColors {
  // ─── Canvas & Surface (Warm Sand Cream matching modern card UI) ───────────
  static const Color canvas = Color(0xFFFAF1E8);       // Warm Almond Cream
  static const Color surface = Color(0xFFF2E6DA);      // Warm Mist Surface
  static const Color surface2 = Color(0xFFE9DCCE);     // Warm Ash
  static const Color cardWhite = Color(0xFFFFFFFF);    // Crisp Card White

  // ─── Accent & Card Oranges (Image 1 Palette) ──────────────────────────────
  static const Color accent = Color(0xFFFF7A1A);       // Vibrant Warm Orange
  static const Color accentDark = Color(0xFFFF570B);   // Deep Ember
  static const Color accentTint = Color(0xFFFFF0E4);   // Soft Glow Cream

  static const List<Color> orangeGradient = [
    Color(0xFFFF8828),
    Color(0xFFFF570B),
  ];

  static const List<Color> orangeGradientSecondary = [
    Color(0xFFFF7718),
    Color(0xFFE84E00),
  ];

  // ─── Ink (Typography) ────────────────────────────────────────────────────
  static const Color ink = Color(0xFF181512);          // Deep Charcoal Espresso
  static const Color ink2 = Color(0xFF5A524C);         // Warm Medium Graphite
  static const Color ink3 = Color(0xFF9E948C);         // Warm Muted Caption

  // ─── Border ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFEADBCE);       // Warm Hairline Border

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1A9E5C);      // Emerald
  static const Color error = Color(0xFFE53535);        // Signal Red
  static const Color warning = Color(0xFFF59E0B);      // Amber

  // ─── Dark Canvas (QR/Scanner screens) ────────────────────────────────────
  static const Color darkCanvas = Color(0xFF0E1015);   // Matte Black
  static const Color darkSurface = Color(0xFF1A1C23);  // Graphite
  static const Color darkBorder = Color(0xFF2C2F3A);   // Subtle divider on dark
  static const Color darkSubtitle = Color(0xFF8A8F9E); // Muted text on dark

  // ─── Legacy aliases ───────────────────────────────────────────────────────
  static const Color navy = ink;
  static const Color darkNavy = darkSurface;
  static const Color darkNavyBorder = darkBorder;
  static const Color teal = accent;
  static const Color mint = accentTint;
  static const Color ivory = canvas;
  static const Color slate = ink2;
  static const Color amber = warning;
  static const Color subtitleLight = darkSubtitle;
  static const Color handleBar = Color(0xFFCCD0D5);
}
