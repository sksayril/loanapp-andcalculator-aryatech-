import 'package:flutter/material.dart';
import 'package:emi_calculatornew/disclaimer_screen.dart';
import 'package:emi_calculatornew/services/disclaimer_prefs.dart';

class SplashScreen extends StatefulWidget {
  final WidgetBuilder nextScreenBuilder;

  const SplashScreen({
    super.key,
    required this.nextScreenBuilder,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  void _startSplashTimer() {
    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final hasAgreed = await DisclaimerPrefs.isAgreed();

    if (!mounted) return;

    if (hasAgreed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: widget.nextScreenBuilder),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DisclaimerScreen(
          nextScreenBuilder: widget.nextScreenBuilder,
          splashAfterAgreeBuilder: (ctx) => SplashScreen(
            nextScreenBuilder: widget.nextScreenBuilder,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F), // Blue background
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F5FF), // Light airy blue (top)
              Color(0xFFB8E6D3), // Gentle pale teal-green (bottom)
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'assets/notesimages/km_20260118-1_1440p_60f_20260118_172002.gif',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to logo if GIF fails to load
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/notesimages/loansathloggo.jpeg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text(
                        'Loan Sathi',
                        style: TextStyle(
                          fontSize: 32,
                          color: Color(0xFF1E3A5F),
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
