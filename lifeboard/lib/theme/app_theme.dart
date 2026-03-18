import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Core Colors
  static const Color bg = Color(0xFF080C12);
  static const Color surface = Color(0xFF0D1420);
  static const Color surface2 = Color(0xFF121A28);
  static const Color surface3 = Color(0xFF1A2436);
  static const Color border = Color(0x12FFFFFF);

  // Accent Colors
  static const Color green = Color(0xFF4FFFB0);
  static const Color purple = Color(0xFF7C6FFF);
  static const Color pink = Color(0xFFFF6F91);
  static const Color orange = Color(0xFFFFB347);
  static const Color blue = Color(0xFF4FC3F7);
  static const Color yellow = Color(0xFFFFE066);

  // Text
  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8A9BB5);
  static const Color textMuted = Color(0xFF4A5A70);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: green,
        secondary: purple,
        surface: surface,
        background: bg,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmMonoTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
          displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textPrimary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textSecondary),
          bodySmall: TextStyle(color: textMuted),
          labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textMuted, letterSpacing: 0.8),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textMuted),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: green.withOpacity(0.15),
        iconTheme: const MaterialStatePropertyAll(
          IconThemeData(color: textMuted, size: 22),
        ),
        labelTextStyle: const MaterialStatePropertyAll(
          TextStyle(fontSize: 10, color: textMuted, letterSpacing: 0.5),
        ),
        elevation: 0,
        height: 65,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface3,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected) ? Colors.black : textMuted),
        trackColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected) ? green : surface3),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((s) =>
            s.contains(MaterialState.selected) ? green : surface3),
        checkColor: const MaterialStatePropertyAll(Colors.black),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: const BorderSide(color: textMuted),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: green,
        linearTrackColor: surface3,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: green,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface2,
        selectedColor: green.withOpacity(0.15),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}

// Gradients
class AppGradients {
  static const LinearGradient greenPurple = LinearGradient(
    colors: [AppTheme.green, AppTheme.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkOrange = LinearGradient(
    colors: [AppTheme.pink, AppTheme.orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bluePurple = LinearGradient(
    colors: [AppTheme.blue, AppTheme.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient cardGlow(Color color) => LinearGradient(
    colors: [color.withOpacity(0.15), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Text Styles
class AppText {
  static TextStyle get displayHero => GoogleFonts.syne(
    fontSize: 52,
    fontWeight: FontWeight.w800,
    color: AppTheme.textPrimary,
    letterSpacing: -2,
    height: 1.0,
  );

  static TextStyle get displayLarge => GoogleFonts.syne(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    color: AppTheme.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle get heading => GoogleFonts.syne(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppTheme.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get cardTitle => GoogleFonts.syne(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppTheme.textMuted,
    letterSpacing: 0.8,
  );

  static TextStyle get statNumber => GoogleFonts.syne(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    height: 1.0,
  );

  static TextStyle get label => GoogleFonts.dmMono(
    fontSize: 11,
    color: AppTheme.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle get mono => GoogleFonts.dmMono(
    fontSize: 13,
    color: AppTheme.textPrimary,
  );
}
