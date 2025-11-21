import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import 'splash_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0.0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      imagePath: 'assets/notesimages/INTRO1.png',
      title: 'Start Your Loan Journey',
      subtitle: 'Get approved for your loan within minutes',
    ),
    _OnboardingSlide(
      imagePath: 'assets/notesimages/INTRO2.png',
      title: 'Instant Cash',
      subtitle: 'Get the funds you need, when you need them',
    ),
    _OnboardingSlide(
      imagePath: 'assets/notesimages/INTRO3.png',
      title: 'Quick Application',
      subtitle: 'Apply with basic details and get quick processing',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    final initialProgress = (_currentPage + 1) / _slides.length;
    _previousProgress = initialProgress;
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: initialProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _updateProgress() {
    final targetProgress = (_currentPage + 1) / _slides.length;
    
    _progressController.reset();
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: targetProgress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _previousProgress = targetProgress;
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _updateProgress();
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) => _OnboardingSlideWidget(slide: _slides[index]),
          ),
          // Skip button with SafeArea
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Bottom indicators and next button
          Positioned(
            bottom: 36,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Round dot indicators - above the button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  // Next arrow button with circular progress arc - centered
                  GestureDetector(
                    onTap: _nextPage,
                    child: SizedBox(
                      width: 66,
                      height: 66,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Custom arc at top-right (green) with animation - drawn outside the button
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(66, 66),
                                painter: _ArcPainter(
                                  progress: _progressAnimation.value,
                                  color: const Color(0xFF66BB6A), // Vibrant green color
                                  strokeWidth: 4.5,
                                ),
                              );
                            },
                          ),
                          // Black circle background - perfectly round
                          Container(
                            width: 58,
                            height: 58,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          // White arrow icon
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final String imagePath;
  final String title;
  final String subtitle;

  const _OnboardingSlide({
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardingSlideWidget extends StatelessWidget {
  final _OnboardingSlide slide;

  const _OnboardingSlideWidget({required this.slide});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        slide.imagePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}

// Custom painter for drawing arc at top-right
class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true; // Smooth edges for perfect circle

    final center = Offset(size.width / 2, size.height / 2);
    // Calculate radius for the arc - it should be around the 58px button, so radius is 29 (half of 58) + some padding
    // The outer container is 66px, so we want the arc to be just outside the 58px button
    final buttonRadius = 29.0; // Half of 58px button
    final arcRadius = buttonRadius + 2.0; // Arc is slightly outside the button
    
    // Draw arc starting from top-right position
    // In Flutter, 0 radians is at 3 o'clock, so top-right is at -π/4 (or 7π/4)
    // Arc fills clockwise around the circle
    final startAngle = -math.pi / 4; // Start from top-right (-45 degrees from 3 o'clock)
    final sweepAngle = 2 * math.pi * progress; // Full circle progress
    
    // Only draw if progress > 0
    if (progress > 0) {
      // Draw perfect circular arc around the button
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle,
        false, // Not filled, just stroke
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

