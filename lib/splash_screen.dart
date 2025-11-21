import 'dart:async';
import 'package:flutter/material.dart';
import 'package:emi_calculatornew/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Navigate after 4 seconds (time-based splash screen)
    _navigationTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Center(
          child: Image.asset(
            'assets/notesimages/9434215cc0cb4dc09b93812a620bcf08.gif',
            fit: BoxFit.contain, // Maintain aspect ratio and fit within screen
            alignment: Alignment.center,
            filterQuality: FilterQuality.none, // No quality reduction
            errorBuilder: (context, error, stackTrace) {
              // Fallback if GIF doesn't load
              return const Center(
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
