import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/screens/map_screen.dart';
import 'package:hospital_nav/screens/language_selection_screen.dart';
import 'package:hospital_nav/screens/splash_screen.dart';
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SimulationProvider()),
        ChangeNotifierProvider(create: (_) => PdrProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const HospitalNavApp(),
    ),
  );
}

class HospitalNavApp extends StatelessWidget {
  const HospitalNavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Deep Indigo
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF818CF8),
          surface: Colors.white,
          background: const Color(0xFFF8FAFC), // Light Slate
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3C4043),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
