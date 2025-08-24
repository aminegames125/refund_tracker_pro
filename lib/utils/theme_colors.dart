import 'package:flutter/material.dart';

class ThemeColors {
  // Primary Colors
  static const Color primaryColor = Color(0xFF1E293B);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Border & Divider Colors
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color dividerColor = Color(0xFFF1F5F9);
  
  // Progress Colors
  static const Color progressBackground = Color(0xFFE2E8F0);
  static const Color progressLow = Color(0xFFEF4444);
  static const Color progressMedium = Color(0xFFF59E0B);
  static const Color progressHigh = Color(0xFF10B981);
  
  // Mode-specific Accent Colors
  static const Color perItemAccent = Color(0xFF3B82F6);
  static const Color poolAccent = Color(0xFF10B981);
  static const Color hybridAccent = Color(0xFF8B5CF6);
  static const Color solanaAccent = Color(0xFFF7931E); // Orange for Solana
  static const Color valueAccent = Color(0xFF06B6D4); // Cyan for Value
  
  // Navigation Colors
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF3B82F6);
  static const Color navUnselected = Color(0xFF94A3B8);
  static const Color navIndicator = Color(0xFF3B82F6);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x0A000000);
  static const Color shadowColor = Color(0x1A000000);
  static const Color shadowColorLight = Color(0x0A000000);
  
  // Input Colors
  static const Color inputBackground = Color(0xFFFFFFFF);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color inputFocus = Color(0xFF3B82F6);
  
  // Button Colors
  static const Color buttonPrimary = Color(0xFF3B82F6);
  static const Color buttonSecondary = Color(0xFFF1F5F9);
  static const Color buttonDisabled = Color(0xFFE2E8F0);
  
  // Border Colors
  static const Color borderColorLight = Color(0xFFF1F5F9);
  
  // Amount Colors
  static Color getAmountColor(bool isExpense) {
    return isExpense ? errorColor : successColor;
  }
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF3B82F6),
    Color(0xFF1D4ED8),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  
  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFD97706),
  ];
  
  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  // Mode-specific accent colors
  static Color getModeAccent(dynamic mode) {
    switch (mode.toString()) {
      case 'TrackingMode.perItem':
        return perItemAccent;
      case 'TrackingMode.pool':
        return poolAccent;
      case 'TrackingMode.hybrid':
        return hybridAccent;

      default:
        return perItemAccent;
    }
  }

  // Progress color based on percentage
  static Color getProgressColor(double percentage) {
    if (percentage < 30) return progressLow;
    if (percentage < 70) return progressMedium;
    return progressHigh;
  }

  // Mode-specific gradients
  static List<Color> getModeGradient(dynamic mode) {
    switch (mode.toString()) {
      case 'TrackingMode.perItem':
        return [perItemAccent, const Color(0xFF1D4ED8)];
      case 'TrackingMode.pool':
        return [poolAccent, const Color(0xFF059669)];
      case 'TrackingMode.hybrid':
        return [hybridAccent, const Color(0xFF7C3AED)];

      default:
        return [perItemAccent, const Color(0xFF1D4ED8)];
    }
  }

  // Shadow styles
  static List<BoxShadow> getShadow({double blur = 10, double offset = 2}) {
    return [
      BoxShadow(
        color: cardShadow,
        blurRadius: blur,
        offset: Offset(0, offset),
      ),
    ];
  }

  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusFull = 50.0;
}

