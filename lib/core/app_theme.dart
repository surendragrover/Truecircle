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

  // Background & Surface Colors - पृष्ठभूमि रंग
  static const Color joyfulBackground = Color(
    0xFFFFF8F3,
  ); // खुशियों की पृष्ठभूमि (हल्का गुलाबी-सफेद)
  static const Color hopeBackground = Color(
    0xFFF0F9FF,
  ); // उम्मीद की पृष्ठभूमि (हल्का नीला-सफेद)
  static const Color peacefulSurface = Color(
    0xFFFFFFFF,
  ); // शांति की सतह (शुद्ध सफेद)
  static const Color warmTextDark = Color(
    0xFF2D1B69,
  ); // गर्म गहरा पाठ (गहरा बैंगनी)
  static const Color gentleTextLight = Color(
    0xFF64748B,
  ); // कोमल हल्का पाठ (हल्का नीला-स्लेटी)

  static ThemeData light([Color seed = primaryTrueCircle]) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryTrueCircle, // मुख्य नीला - शांति और विश्वास
          secondary: joyfulTeal, // खुशी का हरा-नीला - उम्मीद और ताजगी
          tertiary: hopePurple, // उम्मीद का बैंगनी - रचनात्मकता
          surface: peacefulSurface, // शांति की सफेद सतह
          surfaceContainer:
              joyfulBackground, // खुशियों की हल्की पृष्ठभूमि (background के बजाय)
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onTertiary: Colors.white,
          onSurface: warmTextDark, // गर्म गहरा पाठ
          outline: gentleTextLight,
          surfaceContainerHighest:
              hopeBackground, // उम्मीद की हल्की पृष्ठभूमि (surfaceVariant के बजाय)
          primaryContainer: hopePurple.withValues(
            alpha: 0.1,
          ), // हल्का बैंगनी कंटेनर
          secondaryContainer: joyfulTeal.withValues(
            alpha: 0.1,
          ), // हल्का हरा-नीला कंटेनर
          tertiaryContainer: warmGold.withValues(
            alpha: 0.1,
          ), // हल्का सोनहरा कंटेनर
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: joyfulBackground, // खुशियों की हल्की पृष्ठभूमि
      // Typography - जीवंत और शांतिदायक पाठ
      textTheme: Typography.blackMountainView
          .apply(
            bodyColor: warmTextDark, // गर्म गहरा पाठ
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

      // AppBar - खुशियों से भरा शीर्ष बार
      appBarTheme: AppBarTheme(
        backgroundColor: peacefulSurface, // शांति की सफेद सतह
        surfaceTintColor: Colors.transparent,
        foregroundColor: warmTextDark, // गर्म गहरा पाठ
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
          foregroundColor: joyfulTeal, // खुशी का हरा-नीला बटन
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      iconTheme: IconThemeData(color: warmTextDark), // गर्म आइकन
      // सुंदर Input Fields - Beautiful Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: peacefulSurface, // शांति की सफेद सतह
        hintStyle: TextStyle(
          color: gentleTextLight.withValues(alpha: 0.7),
        ), // कोमल संकेत
        labelStyle: TextStyle(color: gentleTextLight), // कोमल लेबल
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
      // जीवंत Tabs - Vibrant Tabs 🌈
      tabBarTheme: TabBarThemeData(
        labelColor: skyBlue, // आकाश नीला - असीम संभावनाएं
        unselectedLabelColor: gentleTextLight, // कोमल हल्का
        indicatorColor: joyfulTeal, // खुशी का हरा-नीला
        dividerColor: Colors.grey.shade200,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),

      // सुंदर विभाजक - Beautiful Dividers
      dividerTheme: DividerThemeData(
        color: gentleTextLight.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // खुशमिजाज ListTiles - Joyful ListTiles 🌈
      listTileTheme: ListTileThemeData(
        iconColor: springGreen, // वसंत हरा - नवजीवन
        textColor: warmTextDark, // गर्म गहरा पाठ
        tileColor: peacefulSurface, // शांति की सफेद सतह
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // आधुनिक SnackBars - Modern SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: warmTextDark, // गर्म गहरी पृष्ठभूमि
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // सुनहरा FAB - Golden Floating Action Button �
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: warmGold, // सोनहरा - खुशी और ऊर्जा
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // खुशमिजाज Bottom Navigation - Joyful Bottom Navigation 🌈
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: peacefulSurface, // शांति की सफेद सतह
        selectedItemColor: primaryTrueCircle, // मुख्य नीला
        unselectedItemColor: gentleTextLight, // कोमल हल्का
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }
}
