import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryGold = Color(0xFFB8860B);
  static const Color primaryNavy = Color(0xFF2C3E50);
  static const Color silver = Color(0xFF95A5A6);
  static const Color lightGray = Color(0xFFECF0F1);
  static const Color error = Color(0xFFE74C3C);
  static const Color success = Color(0xFF27AE60);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGold, primaryNavy],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FA), lightGray],
  );
}
