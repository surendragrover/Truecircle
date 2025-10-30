import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TrueCircle Professional Emotional Wellness Theme
/// Years of Thought, Ultimate User Experience 🌈✨
/// The theme users have been waiting for years
class AppTheme {
  // TrueCircle Logo-Inspired Joyful Palette - Colors that inspire happiness
  static const Color primaryTrueCircle = Color(
    0xFF6366F1,
  ); // Logo Primary - Blue (peace and trust)
  static const Color joyfulTeal = Color(
    0xFF14B8A6,
  ); // Logo Teal - Green-blue (hope and freshness)
  static const Color hopePurple = Color(
    0xFF8B5CF6,
  ); // Logo Purple - Purple (creativity and peace)
  static const Color warmGold = Color(
    0xFFF4AB37,
  ); // Logo Gold - Golden (joy and energy)
  static const Color deepPurple = Color(
    0xFF2A145D,
  ); // Logo Deep Purple - Deep purple (depth and stability)

  // Life's Additional Colors
  static const Color sunriseOrange = Color(0xFFFF8A65); // Sunrise Orange
  static const Color springGreen = Color(0xFF66BB6A); // Spring Green
  static const Color skyBlue = Color(0xFF42A5F5); // Sky Blue
  static const Color blossomPink = Color(
    0xFFEC407A,
  ); // Blossom Pink (love and compassion)
  static const Color peacefulLavender = Color(
    0xFFAB47BC,
  ); // Peaceful Lavender (mental peace)

  // Background & Surface Colors
  static const Color joyfulBackground = Color(
    0xFFFFF8F3,
  ); // Joyful background (light pink-white)
  static const Color hopeBackground = Color(
    0xFFF0F9FF,
  ); // Hope background (light blue-white)
  static const Color peacefulSurface = Color(
    0xFFFFFFFF,
  ); // Peaceful surface (pure white)
  static const Color warmTextDark = Color(
    0xFF2D1B69,
  ); // Warm dark text (deep purple)
  static const Color gentleTextLight = Color(
    0xFF64748B,
  ); // Gentle light text (light blue-slate)

  static ThemeData light([Color seed = primaryTrueCircle]) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryTrueCircle, // Primary blue - peace and trust
          secondary: joyfulTeal, // Joyful teal - hope and freshness
          tertiary: hopePurple, // Hope purple - creativity
          surface: peacefulSurface, // Peaceful white surface
          surfaceContainer:
              joyfulBackground, // Joyful light background (instead of background)
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: warmTextDark, // Warm dark text
          outline: gentleTextLight,
          surfaceContainerHighest:
              hopeBackground, // Hope light background (instead of surfaceVariant)
          primaryContainer: hopePurple.withValues(
            alpha: 0.1,
          ), // Light purple container
          secondaryContainer: joyfulTeal.withValues(
            alpha: 0.1,
          ), // Light teal container
          tertiaryContainer: warmGold.withValues(
            alpha: 0.1,
          ), // Light golden container
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: joyfulBackground, // Joyful light background
      // Typography - vibrant and calming text
      textTheme: Typography.blackMountainView
          .apply(
            bodyColor: warmTextDark, // Warm dark text
            displayColor: warmTextDark,
          )
          .copyWith(
            headlineLarge: TextStyle(
              color: warmTextDark,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: warmTextDark,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: TextStyle(
              color: warmTextDark,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: TextStyle(
              color: warmTextDark,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: TextStyle(color: warmTextDark),
            bodyMedium: TextStyle(color: warmTextDark),
            labelLarge: TextStyle(color: gentleTextLight),
          ),

      // AppBar - joyful top bar
      appBarTheme: AppBarTheme(
        backgroundColor: peacefulSurface, // Peaceful white surface
        surfaceTintColor: Colors.transparent,
        foregroundColor: warmTextDark, // Warm dark text
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: warmTextDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: warmTextDark),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      // Cards - White cards on coral background
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),
      // Rainbow Buttons 🌈
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTrueCircle,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: primaryTrueCircle.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: joyfulTeal, // Joyful teal button
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: warmTextDark), // Warm icons
      // Beautiful Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: peacefulSurface, // Peaceful white surface
        hintStyle: TextStyle(
          color: gentleTextLight.withValues(alpha: 0.7),
        ), // Gentle hint
        labelStyle: TextStyle(color: gentleTextLight), // Gentle label
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTrueCircle, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        selectedColor: scheme.primaryContainer,
        disabledColor: scheme.surfaceContainerLowest,
        secondarySelectedColor: scheme.secondaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onSecondaryContainer),
        brightness: Brightness.light,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      // Vibrant Tabs 🌈
      tabBarTheme: TabBarThemeData(
        labelColor: skyBlue, // Sky blue - endless possibilities
        unselectedLabelColor: gentleTextLight, // Gentle light
        indicatorColor: joyfulTeal, // Joyful teal
        dividerColor: Colors.grey.shade200,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),

      // Beautiful Dividers
      dividerTheme: DividerThemeData(
        color: gentleTextLight.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // Joyful ListTiles 🌈
      listTileTheme: ListTileThemeData(
        iconColor: springGreen, // Spring green - renewal
        textColor: warmTextDark, // Warm dark text
        tileColor: peacefulSurface, // Peaceful white surface
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Modern SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: warmTextDark, // Warm dark background
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Golden Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: warmGold, // Golden - joy and energy
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Joyful Bottom Navigation 🌈
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: peacefulSurface, // Peaceful white surface
        selectedItemColor: primaryTrueCircle, // Primary blue
        unselectedItemColor: gentleTextLight, // Gentle light
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
