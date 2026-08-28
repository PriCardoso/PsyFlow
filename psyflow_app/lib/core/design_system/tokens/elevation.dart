/// Design System Elevation & Shadow Tokens
import 'package:flutter/material.dart';

class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 4;
  static const double level4 = 8;
  static const double level5 = 16;
  static const double level6 = 24;
  
  // Semantic elevation
  static const double card = level1;
  static const double raisedButton = level1;
  static const double floatingButton = level4;
  static const double appBar = level2;
  static const double bottomSheet = level6;
  static const double modal = level5;
  static const double dropdown = level3;
  static const double snackbar = level4;
  static const double tooltip = level2;
  
  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);   // 10% opacity
  static const Color shadowMedium = Color(0x33000000);  // 20% opacity
  static const Color shadowDark = Color(0x4D000000);    // 30% opacity
  
  static BoxShadow shadow({
    double elevation = level1,
    Color color = shadowMedium,
  }) {
    switch (elevation) {
      case level0:
        return const BoxShadow(color: Colors.transparent);
      case level1:
        return BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        );
      case level2:
        return BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 2),
        );
      case level3:
        return BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 16,
          offset: const Offset(0, 4),
        );
      case level4:
        return BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        );
      case level5:
        return BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 32,
          offset: const Offset(0, 12),
        );
      case level6:
        return BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 48,
          offset: const Offset(0, 16),
        );
      default:
        return BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: elevation * 2,
          offset: Offset(0, elevation / 2),
        );
    }
  }
  
  static List<BoxShadow> shadows({
    double elevation = level1,
    Color color = shadowMedium,
  }) {
    return [shadow(elevation: elevation, color: color)];
  }
}