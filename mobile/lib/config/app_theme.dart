import 'package:flutter/material.dart';

/// Design tokens and Material theme for PES Hospital Navigation.
class AppTheme {
  AppTheme._();

  // ── Brand colours ────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0);        // deep blue
  static const Color primaryLight = Color(0xFF1E88E5);   // lighter blue
  static const Color primaryDark = Color(0xFF0D47A1);    // darker blue
  static const Color accent = Color(0xFF00ACC1);         // teal accent
  static const Color emergency = Color(0xFFD32F2F);      // red for emergency
  static const Color success = Color(0xFF388E3C);        // green for arrival
  static const Color warning = Color(0xFFF57C00);        // orange for caution
  static const Color surface = Color(0xFFF5F7FA);        // off-white background
  static const Color cardBg = Color(0xFFFFFFFF);

  // ── Step type colours ─────────────────────────────────────────────────
  static const Color stepStart = Color(0xFF1565C0);
  static const Color stepWalk = Color(0xFF546E7A);
  static const Color stepElevator = Color(0xFF00838F);
  static const Color stepStairs = Color(0xFF558B2F);
  static const Color stepTransit = Color(0xFF6A1B9A);
  static const Color stepArrival = Color(0xFF2E7D32);

  // ── Typography ────────────────────────────────────────────────────────
  static const String fontFamily = 'Roboto';

  // ── Material theme ────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          surface: surface,
          error: emergency,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: surface,
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
        ),
        cardTheme: CardTheme(
          color: cardBg,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCDD5E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCDD5E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle:
              const TextStyle(color: Color(0xFF9AA5B4), fontSize: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFE3F2FD),
          labelStyle: const TextStyle(
            color: primary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(color: Color(0xFFBBDEFB)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE0E7EF),
          thickness: 1,
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: const Color(0xFF263238),
          contentTextStyle: const TextStyle(color: Colors.white),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primary,
          unselectedItemColor: Color(0xFF78909C),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
      );

  // ── Text styles ────────────────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1A2332),
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A2332),
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A2332),
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF2D3748),
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFF4A5568),
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF718096),
  );
}
