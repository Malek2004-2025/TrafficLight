import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the real-time traffic management application.
/// Implements Adaptive Neon Clarity design system optimized for automotive environments.
class AppTheme {
  AppTheme._();

  // Primary color palette - Adaptive Neon Clarity
  static const Color primaryLight =
      Color(0xFF00E5FF); // Cyan accent for critical traffic light status
  static const Color primaryDark =
      Color(0xFF00E5FF); // Consistent across themes for recognition

  // Background colors - OLED optimized
  static const Color backgroundLight =
      Color(0xFF1A1A1A); // Deep charcoal for light mode (actually dark)
  static const Color backgroundDark =
      Color(0xFF1A1A1A); // Deep charcoal background

  // Surface colors
  static const Color surfaceLight = Color(0xFF2A2A2A); // Card backgrounds
  static const Color surfaceDark =
      Color(0xFF2A2A2A); // Consistent surface elevation

  // Accent and status colors
  static const Color accentColor = Color(0xFFFF6B35); // Emergency orange
  static const Color successColor = Color(0xFF00C853); // Traffic light green
  static const Color warningColor = Color(0xFFFFD600); // Traffic light amber
  static const Color errorColor = Color(0xFFFF1744); // Traffic light red

  // Text colors - High contrast for automotive visibility
  static const Color textPrimaryLight =
      Color(0xFFFFFFFF); // High contrast white
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFFB0BEC5); // Muted blue-grey
  static const Color textSecondaryDark = Color(0xFFB0BEC5);

  // Overlay and divider colors
  static const Color overlayColor = Color(0xCC000000); // Semi-transparent black
  static const Color dividerLight = Color(0x1FFFFFFF);
  static const Color dividerDark = Color(0x1FFFFFFF);

  // Shadow colors - Subtle elevation
  static const Color shadowLight = Color(0x33000000); // 20% opacity
  static const Color shadowDark = Color(0x33000000);

  // ✅ Méthode corrigée _buildTextTheme
  static TextTheme _buildTextTheme({required bool isLight}) {
    return TextTheme(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isLight ? textPrimaryLight : textPrimaryDark,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: isLight ? textPrimaryLight : textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isLight ? textPrimaryLight : textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isLight ? textSecondaryLight : textSecondaryDark,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isLight ? textSecondaryLight : textSecondaryDark,
      ),
    );
  }

  /// Light theme (actually dark theme optimized for automotive use)
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryLight,
      onPrimary: Color(0xFF000000),
      primaryContainer: primaryLight.withAlpha((0.3 * 255).toInt()),
      onPrimaryContainer: textPrimaryLight,
      secondary: surfaceLight,
      onSecondary: textPrimaryLight,
      secondaryContainer: surfaceLight,
      onSecondaryContainer: textPrimaryLight,
      tertiary: accentColor,
      onTertiary: textPrimaryLight,
      tertiaryContainer: accentColor.withAlpha((0.3 * 255).toInt()),
      onTertiaryContainer: textPrimaryLight,
      error: errorColor,
      onError: textPrimaryLight,
      surface: surfaceLight,
      onSurface: textPrimaryLight,
      onSurfaceVariant: textSecondaryLight,
      outline: dividerLight,
      outlineVariant: dividerLight.withAlpha((0.5 * 255).toInt()),
      shadow: shadowLight,
      scrim: overlayColor,
      inverseSurface: textPrimaryLight,
      onInverseSurface: backgroundLight,
      inversePrimary: primaryLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    cardColor: surfaceLight,
    dividerColor: dividerLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      foregroundColor: textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryLight,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceLight,
      elevation: 2.0,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: surfaceLight, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      selectedItemColor: primaryLight,
      unselectedItemColor: textSecondaryLight,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Color(0xFF000000),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF000000),
        backgroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.25,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: primaryLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.25,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.25,
        ),
      ),
    ),
    textTheme: _buildTextTheme(isLight: true),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: surfaceLight,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: surfaceLight, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: surfaceLight, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textSecondaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSecondaryLight.withAlpha((0.6 * 255).toInt()),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: textSecondaryLight,
      suffixIconColor: textSecondaryLight,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryLight,
      unselectedLabelColor: textSecondaryLight,
      indicatorColor: primaryLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: surfaceLight,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: shadowLight,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: surfaceLight,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimaryLight,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceLight,
      modalBackgroundColor: surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      elevation: 8.0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceLight,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: Color(0xFF000000),
      primaryContainer: primaryDark.withAlpha((0.3 * 255).toInt()),
      onPrimaryContainer: textPrimaryDark,
      secondary: surfaceDark,
      onSecondary: textPrimaryDark,
      secondaryContainer: surfaceDark,
      onSecondaryContainer: textPrimaryDark,
      tertiary: accentColor,
      onTertiary: textPrimaryDark,
      tertiaryContainer: accentColor.withAlpha((0.3 * 255).toInt()),
      onTertiaryContainer: textPrimaryDark,
      error: errorColor,
      onError: textPrimaryDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      outline: dividerDark,
      outlineVariant: dividerDark.withAlpha((0.5 * 255).toInt()),
      shadow: shadowDark,
      scrim: overlayColor,
      inverseSurface: textPrimaryDark,
      onInverseSurface: backgroundDark,
      inversePrimary: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    cardColor: surfaceDark,
    dividerColor: dividerDark,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2.0,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: surfaceDark, width: 1),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      elevation: 8.0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: Color(0xFF000000),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    ),
    textTheme: _buildTextTheme(isLight: false),
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.25,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.25,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
    ),
  );
}
