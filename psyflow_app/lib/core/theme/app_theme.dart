import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xff3D6B7D);

  static const secondary = Color(0xffE5B96B);

  static const background = Color(0xffF7F7F5);

  static const surface = Colors.white;

  static const error = Colors.red;

  static const text = Color(0xff333333);
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