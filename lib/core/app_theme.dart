import 'package:flutter/material.dart';

/// TrueCircle global theme
/// Brand colors: Purple logo with blue shades, Kesari AppBar, Coral background, Black87 text
/// Single source of truth for colors, typography, and component styles.
/// Apply this in MaterialApp.theme so all current and future pages inherit it.
class AppTheme {
  // TrueCircle Brand Colors
  static const Color truecirclePurple = Color(0xFF6A5ACD);    // Purple (logo primary)
  static const Color truecircleBlue = Color(0xFF4169E1);      // Blue shade (logo accent)
  static const Color kesariOrange = Color(0xFFFF8C00);        // Kesari/Saffron (AppBar)
  static const Color coralBackground = Color(0xFFFF7F7F);     // Coral (background)
  static const Color textBlack87 = Color(0xDD000000);         // Black87 (text)

  static ThemeData light([Color seed = truecirclePurple]) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: coralBackground, // Coral background
      // Typography - Black87 text
      textTheme: Typography.blackMountainView.apply(
        bodyColor: textBlack87,
        displayColor: textBlack87,
      ),
      // AppBar - Kesari/Saffron color
      appBarTheme: AppBarTheme(
        backgroundColor: kesariOrange, // Kesari AppBar
        surfaceTintColor: Colors.transparent,
        foregroundColor: Colors.white, // White text on kesari background
        elevation: 2,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
      // Buttons - Purple primary buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: truecirclePurple,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: truecirclePurple,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: textBlack87),
      // Inputs - White background with purple focus
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: textBlack87.withValues(alpha: 0.6)),
        labelStyle: TextStyle(color: textBlack87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: truecirclePurple, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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
      // Tabs - Purple active, blue accent for inactive
      tabBarTheme: TabBarThemeData(
        labelColor: truecirclePurple,
        unselectedLabelColor: truecircleBlue.withValues(alpha: 0.7),
        indicatorColor: truecirclePurple,
        dividerColor: Colors.grey.shade300,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      // Dividers
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
      // ListTiles - Purple icons, black87 text, white background
      listTileTheme: ListTileThemeData(
        iconColor: truecirclePurple,
        textColor: textBlack87,
        tileColor: Colors.white,
      ),
      // SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      // FAB - Purple background
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: truecirclePurple,
        foregroundColor: Colors.white,
      ),
      // Bottom Navigation - Kesari background
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: kesariOrange,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
