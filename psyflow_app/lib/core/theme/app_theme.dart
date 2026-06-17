import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4A90A4);
  static const gradientStart = Color(0xFF4A90A4);
  static const gradientEnd = Color(0xFF8B7EC8);
  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A2B3C);
  static const textSecondary = Color(0xFF6B7A8D);
  static const psychologist = Color(0xFF4A90A4);
  static const patient = Color(0xFF8B7EC8);
  static const accentLight = Color(0xFFB3A8E0);
  static const error = Color(0xFFE57373);
  static const success = Color(0xFF4CAF50);
  // Cores nomeadas (antes hardcoded nos widgets)
  static const cardRed = Color(0xFFE57373);
  static const cardGreen = Color(0xFF4CAF82);
  static const cardOrange = Color(0xFFFFB74D);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  );
}
