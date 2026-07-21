import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xff3D6B7D);

  static const secondary = Color(0xffE5B96B);

  static const background = Color(0xffF7F7F5);

  static const surface = Colors.white;

  static const error = Colors.red;

  static const text = Color(0xff333333);

  static const textPrimary = Color(0xff333333);

  static const textSecondary = Color(0xff666666);

  static const success = Color(0xff2E7D32);

  static const patient = Color(0xff6C63FF);

  static const psychologist = Color(0xff00A86B);

  static const accentLight = Color(0xffE5B96B);

  static const gradientEnd = Color(0xff00A86B);

  static const gradientStart = Color(0xff6C63FF);

  static const cardOrange = Color(0xFFFF9800);

  static const cardGreen = Color(0xFF4CAF50);

  static const cardRed = Color(0xFFF44336);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
      ),

      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}