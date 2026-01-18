import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emi_calculatornew/main.dart';
import 'package:emi_calculatornew/onboarding_screen.dart';
import 'package:emi_calculatornew/screens/profile_setup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkOnboardingAndNavigate();
  }

  Future<void> _checkOnboardingAndNavigate() async {
    // Wait for splash screen to display (3 seconds)
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check onboarding status
    final prefs = await SharedPreferences.getInstance();
    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    final profileSetupCompleted = prefs.getBool('profile_setup_completed') ?? false;
    
    if (!mounted) return;
    
    // Navigate based on onboarding status
    if (!onboardingCompleted) {
      // First time - show onboarding screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else if (!profileSetupCompleted) {
      // Onboarding done but profile setup not completed
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
      );
    } else {
      // Both completed - go to home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A), // Purple background matching Loan King logo
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF6A1B9A), // Purple background
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo centered in the middle
              Image.asset(
                'assets/notesimages/loankinglogo.jpeg',
                fit: BoxFit.contain, // Maintain aspect ratio and fit within screen
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
                width: 200, // Set a reasonable width
                height: 200, // Set a reasonable height
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if logo doesn't load
                  return const Text(
                    'Loan King',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40), // Space between logo and spinner
              // Spinner loader centered below the logo
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
