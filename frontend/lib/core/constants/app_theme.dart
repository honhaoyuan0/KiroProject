import 'package:flutter/material.dart';

/// Application theme configuration with purple and white color scheme
class AppTheme {
  // Primary Colors (Twitch-inspired purple theme)
  static const Color primaryPurple = Color(0xFF9146FF);
  static const Color lightPurple = Color(0xFFB19CD9);
  static const Color darkPurple = Color(0xFF6441A4);
  static const Color accentPurple = Color(0xFF772CE8);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFF5F5F5);
  
  // Text Colors - Updated to use only purple variations
  static const Color textPrimary = Color(0xFF6441A4);        // Dark purple for primary text
  static const Color textSecondary = Color(0xFF9146FF);      // Main purple for secondary text
  static const Color textLight = Color(0xFFB19CD9);          // Light purple for light text
  
  // Status Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  
  // Chart Colors - Purple variations only
  static const List<Color> chartColors = [
    primaryPurple,        // #9146FF - Main purple
    darkPurple,          // #6441A4 - Dark purple
    lightPurple,         // #B19CD9 - Light purple
    accentPurple,        // #772CE8 - Accent purple
    Color(0xFF7C3AED),   // Violet
    Color(0xFF8B5CF6),   // Purple-400
    Color(0xFFA855F7),   // Purple-500
    Color(0xFFC084FC),   // Purple-300
    Color(0xFF5B21B6),   // Purple-800
    Color(0xFF6D28D9),   // Purple-700
    Color(0xFF9333EA),   // Purple-600
    Color(0xFFDDD6FE),   // Purple-200
  ];

  /// Main theme data for the application
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
        primary: primaryPurple,
        secondary: lightPurple,
        surface: cardBackground,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: cardBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryPurple,
        unselectedLabelColor: textSecondary,
        indicatorColor: primaryPurple,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPurple,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: textLight,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Custom decoration for cards with purple accent
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Gradient decoration for special cards
  static BoxDecoration get gradientCardDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [primaryPurple.withOpacity(0.1), lightPurple.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: primaryPurple.withOpacity(0.2)),
    );
  }

  /// Chart theme configuration
  static Map<String, dynamic> get chartTheme {
    return {
      'primaryColor': primaryPurple,
      'backgroundColor': cardBackground,
      'gridColor': textLight.withOpacity(0.3),
      'textColor': textSecondary,
      'colors': chartColors,
    };
  }
}