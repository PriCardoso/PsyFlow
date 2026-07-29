import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  static const String _fontFamily = 'Inter';

  static TextTheme get textTheme => const TextTheme(
        displayLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
        ),
        headlineLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
        ),
        titleLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          height: 1.45,
        ),
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),
      );

  static TextStyle get displayLarge => textTheme.displayLarge!;
  static TextStyle get displayMedium => textTheme.displayMedium!;
  static TextStyle get displaySmall => textTheme.displaySmall!;
  static TextStyle get headlineLarge => textTheme.headlineLarge!;
  static TextStyle get headlineMedium => textTheme.headlineMedium!;
  static TextStyle get headlineSmall => textTheme.headlineSmall!;
  static TextStyle get titleLarge => textTheme.titleLarge!;
  static TextStyle get titleMedium => textTheme.titleMedium!;
  static TextStyle get titleSmall => textTheme.titleSmall!;
  static TextStyle get labelLarge => textTheme.labelLarge!;
  static TextStyle get labelMedium => textTheme.labelMedium!;
  static TextStyle get labelSmall => textTheme.labelSmall!;
  static TextStyle get bodyLarge => textTheme.bodyLarge!;
  static TextStyle get bodyMedium => textTheme.bodyMedium!;
  static TextStyle get bodySmall => textTheme.bodySmall!;

  static TextStyle withColor(TextStyle style, Color color) => style.copyWith(color: color);
  static TextStyle withWeight(TextStyle style, FontWeight weight) => style.copyWith(fontWeight: weight);
  static TextStyle withSize(TextStyle style, double size) => style.copyWith(fontSize: size);
}

extension AppTextStyleExtensions on TextStyle {
  TextStyle get primary => copyWith(color: AppColors.textPrimary);
  TextStyle get secondary => copyWith(color: AppColors.textSecondary);
  TextStyle get muted => copyWith(color: AppColors.textMuted);
  TextStyle get onPrimary => copyWith(color: Colors.white);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get success => copyWith(color: AppColors.success);
  TextStyle get warning => copyWith(color: AppColors.warning);

  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  TextStyle size(double size) => copyWith(fontSize: size);
}