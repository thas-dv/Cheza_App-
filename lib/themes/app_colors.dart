import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0B0F2A);
  static const Color backgroundDark = Color(0xFF090B1A);
  static const Color deepIndigo = Color(0xFF1A1443);
  static const Color bacgroundRed = Color(0xFFB23B3B);
  // Neon Accents
  static const Color neonBlue = Color(0xFF00C2FF);
  static const Color neonPurple = Color(0xFF7B4DFF);
  static const Color neonPink = Color(0xFFB44CFF);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B3C7);

  // Gradient principal EXACT image
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7B4DFF), Color(0xFFB44CFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Glow Blue Gradient (lumière DJ)
  static const LinearGradient blueGlow = LinearGradient(
    colors: [Color(0xFF00C2FF), Color(0xFF7B4DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
