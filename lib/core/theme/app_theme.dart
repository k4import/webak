import 'package:flutter/material.dart';

class AppTheme {
  // Colors - Light Theme (Enhanced for pest control app)
  static const Color primary = Color(0xFF2E7D32); // Green for nature/environment
  static const Color secondary = Color(0xFFFF8F00); // Orange for warning/action
  static const Color accent = Color(0xFF1976D2); // Blue for trust/professionalism
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Colors - Dark Theme (Enhanced)
  static const Color primaryDark = Color(0xFF66BB6A); // Lighter green for dark mode
  static const Color secondaryDark = Color(0xFFFFB74D); // Softer orange
  static const Color accentDark = Color(0xFF42A5F5); // Lighter blue
  static const Color successDark = Color(0xFF81C784);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color warningDark = Color(0xFFFFB74D);
  static const Color infoDark = Color(0xFF42A5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color dividerDark = Color(0xFF2E2E2E);

  // Spacing (Enhanced with more options)
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Border & Radius (Modern design)
  static const Color border = Color(0xFFE0E0E0);
  static const double borderRadius = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusSmall = 8.0;
  static const double elevation = 4.0;
  static const double elevationLow = 2.0;
  static const double elevationHigh = 8.0;

  // Typography (Enhanced with better hierarchy)
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.25,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        background: background,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: elevation,
          textStyle: button,
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          textStyle: button,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: button,
          minimumSize: const Size(120, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textSecondary),
        labelStyle: const TextStyle(color: textSecondary),
      ),
      cardTheme: CardThemeData(
        elevation: elevationLow,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        margin: const EdgeInsets.symmetric(vertical: sm),
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        disabledColor: Colors.grey[100],
        selectedColor: primary.withOpacity(0.15),
        secondarySelectedColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: border),
        ),
        labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: primary, fontWeight: FontWeight.w600),
        deleteIconColor: textSecondary,
      ),
      textTheme: TextTheme(
        headlineLarge: h1,
        headlineMedium: h2,
        headlineSmall: h3,
        titleLarge: h4,
        bodyLarge: body1,
        bodyMedium: body2,
        bodySmall: caption,
        labelLarge: button,
      ),
      fontFamily: 'Cairo',
    );
  }


  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        error: errorDark,
        background: backgroundDark,
        surface: surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryDark,
        onBackground: textPrimaryDark,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
          color: textPrimaryDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: elevation,
          textStyle: button.copyWith(color: Colors.white),
          minimumSize: const Size(120, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          textStyle: button.copyWith(color: primaryDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: BorderSide(color: primaryDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: xl, vertical: lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: button.copyWith(color: primaryDark),
          minimumSize: const Size(120, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorDark, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: errorDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
        filled: true,
        fillColor: surfaceDark,
        hintStyle: const TextStyle(color: textSecondaryDark),
        labelStyle: const TextStyle(color: textSecondaryDark),
      ),
      cardTheme: CardThemeData(
        elevation: elevationLow,
        color: surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        margin: const EdgeInsets.symmetric(vertical: sm),
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceDark,
        disabledColor: Colors.grey[800],
        selectedColor: primaryDark.withOpacity(0.15),
        secondarySelectedColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
          side: const BorderSide(color: dividerDark),
        ),
        labelStyle: const TextStyle(color: textPrimaryDark, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: primaryDark, fontWeight: FontWeight.w600),
        deleteIconColor: textSecondaryDark,
      ),
      textTheme: TextTheme(
        headlineLarge: h1.copyWith(color: textPrimaryDark),
        headlineMedium: h2.copyWith(color: textPrimaryDark),
        headlineSmall: h3.copyWith(color: textPrimaryDark),
        titleLarge: h4.copyWith(color: textPrimaryDark),
        bodyLarge: body1.copyWith(color: textPrimaryDark),
        bodyMedium: body2.copyWith(color: textPrimaryDark),
        bodySmall: caption.copyWith(color: textSecondaryDark),
        labelLarge: button.copyWith(color: textPrimaryDark),
      ),
      fontFamily: 'Cairo',
    );
  }

}
