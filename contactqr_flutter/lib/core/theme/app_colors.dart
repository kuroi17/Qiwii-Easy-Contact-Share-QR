import 'package:flutter/material.dart';

/// ContactQR Orange Ember Design System
/// Accent: #FF6B2C (Warm Burnt Orange)
/// Canvas: #FFFFFF (Pure White)
class AppColors {
  // ─── Canvas & Surface ────────────────────────────────────────────────────
  static const Color canvas = Color(0xFFFFFFFF);       // Pure White
  static const Color surface = Color(0xFFF5F5F5);      // Near-White Mist
  static const Color surface2 = Color(0xFFEDEDEC);     // Cool Ash

  // ─── Accent (Orange Ember) ────────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B2C);       // Orange Ember — THE one bold color
  static const Color accentTint = Color(0xFFFFF0E8);   // Ember Glow — pill backgrounds

  // ─── Ink (Typography) ────────────────────────────────────────────────────
  static const Color ink = Color(0xFF111111);          // Near-Black
  static const Color ink2 = Color(0xFF555555);         // Medium Graphite
  static const Color ink3 = Color(0xFFA0A0A0);         // Light Graphite / Captions

  // ─── Border ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE8E8E8);       // Hairline Gray

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1A9E5C);      // Emerald
  static const Color error = Color(0xFFE53535);        // Signal Red
  static const Color warning = Color(0xFFF59E0B);      // Amber

  // ─── Dark Canvas (QR/Scanner screens) ────────────────────────────────────
  static const Color darkCanvas = Color(0xFF0E1015);   // Matte Black
  static const Color darkSurface = Color(0xFF1A1C23);  // Graphite
  static const Color darkBorder = Color(0xFF2C2F3A);   // Subtle divider on dark
  static const Color darkSubtitle = Color(0xFF8A8F9E); // Muted text on dark

  // ─── Legacy aliases (kept to avoid breaking any untouched code) ───────────
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
