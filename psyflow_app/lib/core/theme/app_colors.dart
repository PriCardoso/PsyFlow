import 'package:flutter/material.dart';

/// Design System Color Palette for PsyFlow Multidisciplinary Care Platform
class AppColors {
  // Brand Base Colors
  static const Color primary = Color(0xFF2C5E7A);
  static const Color primaryDark = Color(0xFF1B3B4D);
  static const Color primaryLight = Color(0xFF4A89AC);
  static const Color secondary = Color(0xFFE5B96B);
  static const Color secondaryLight = Color(0xFFFFF3D6);
  static const Color accent = Color(0xFF6C63FF);
  static const Color accentLight = Color(0xFFE5B96B);

  // Legacy & Specific Card Color Aliases
  static const Color gradientStart = Color(0xFF6C63FF);
  static const Color gradientEnd = Color(0xFF00A86B);
  static const Color cardOrange = Color(0xFFFF9800);
  static const Color cardGreen = Color(0xFF4CAF50);
  static const Color cardRed = Color(0xFFF44336);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F9FC);
  static const Color backgroundDark = Color(0xFF121824);
  static const Color surface = Colors.white;
  static const Color surfaceDark = Color(0xFF1E2638);
  static const Color surfaceVariant = Color(0xFFEDF2F7);

  // Text Colors
  static const Color text = Color(0xFF333333);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textMuted = Color(0xFF718096);
  static const Color textOnPrimary = Colors.white;

  // Status & Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFED6C02);
  static const Color warningBg = Color(0xFFFFF4E5);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0288D1);
  static const Color infoBg = Color(0xFFE1F5FE);

  // Role Accent Colors
  static const Color patient = Color(0xFF6C63FF);
  static const Color psychologist = Color(0xFF00A86B);
  static const Color professional = Color(0xFF00A86B);

  // Multidisciplinary Specialty Accents
  static const Color psychology = Color(0xFF00A86B); // Emerald
  static const Color occupationalTherapy = Color(0xFF6C63FF); // Deep Indigo
  static const Color psychopedagogy = Color(0xFFFB8C00); // Warm Amber
  static const Color speechTherapy = Color(0xFF0288D1); // Cyan
  static const Color neuropsychology = Color(0xFF8E24AA); // Purple
  static const Color psychiatry = Color(0xFFD81B60); // Rose Crimson
  static const Color multidisciplinary = Color(0xFF00897B); // Teal

  // Mood Scale Colors (1 to 5)
  static const Color moodVeryBad = Color(0xFFE53935);
  static const Color moodBad = Color(0xFFFB8C00);
  static const Color moodNeutral = Color(0xFFFDD835);
  static const Color moodGood = Color(0xFF7CB342);
  static const Color moodVeryGood = Color(0xFF43A047);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C5E7A), Color(0xFF3D7E9E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00A86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Helper to return specialty accent color dynamically
  static Color getSpecialtyColor(String? specialtyKey) {
    switch (specialtyKey?.toLowerCase()) {
      case 'psychology':
      case 'psicologia':
        return psychology;
      case 'occupational_therapy':
      case 'terapia_ocupacional':
        return occupationalTherapy;
      case 'psychopedagogy':
      case 'psicopedagogia':
        return psychopedagogy;
      case 'speech_therapy':
      case 'fonoaudiologia':
        return speechTherapy;
      case 'neuropsychology':
      case 'neuropsicologia':
        return neuropsychology;
      case 'psychiatry':
      case 'psiquiatria':
        return psychiatry;
      default:
        return primary;
    }
  }
}
