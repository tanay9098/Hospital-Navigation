import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../config/app_config.dart';
import '../providers/navigation_provider.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final provider = context.read<NavigationProvider>();
    await provider.init();
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hospital cross icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital,
                  size: 60,
                  color: AppTheme.primary,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fade(duration: 400.ms),

              const SizedBox(height: 28),

              Text(
                AppConfig.hospitalName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ).animate().slideY(
                    begin: 0.3,
                    duration: 500.ms,
                    delay: 300.ms,
                    curve: Curves.easeOut,
                  ).fade(delay: 300.ms),

              const SizedBox(height: 8),

              const Text(
                'Indoor Navigation System',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.2,
                ),
              ).animate().fade(delay: 500.ms, duration: 400.ms),

              const SizedBox(height: 60),

              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                  strokeWidth: 2.5,
                ),
              ).animate().fade(delay: 700.ms),

              const SizedBox(height: 16),

              const Text(
                'Loading hospital map…',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ).animate().fade(delay: 700.ms),
            ],
          ),
        ),
      ),
    );
  }
}
