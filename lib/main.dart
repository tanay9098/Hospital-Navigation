import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hospital_nav/providers/navigation_provider.dart';
import 'package:hospital_nav/providers/simulation_provider.dart';
import 'package:hospital_nav/providers/pdr_provider.dart';
import 'package:hospital_nav/providers/settings_provider.dart';
import 'package:hospital_nav/screens/map_screen.dart';
import 'package:hospital_nav/screens/language_selection_screen.dart';
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
          seedColor: const Color(0xFF1A73E8), // Google Blue
          primary: const Color(0xFF1A73E8),
          secondary: const Color(0xFFE8F0FE),
          surface: const Color(0xFFF8F9FA),
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
      home: Consumer2<NavigationProvider, SettingsProvider>(
        builder: (context, navProvider, settingsProvider, child) {
          if (navProvider.isLoading || !settingsProvider.isInitialized) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('nav loading: ${navProvider.isLoading}'),
                    Text('settings init: ${settingsProvider.isInitialized}'),
                  ],
                ),
              ),
            );
          }
          if (settingsProvider.selectedLanguageCode.isEmpty) {
            return const LanguageSelectionScreen();
          }
          return const MapScreen();
        },
      ),
    );
  }
}
