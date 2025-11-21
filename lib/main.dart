import 'package:emi_calculatornew/cibil_score_screen.dart';
import 'package:emi_calculatornew/gst_calculator_screen.dart';
import 'package:emi_calculatornew/ppf_calculator_screen.dart';
import 'package:emi_calculatornew/sip_calculator_screen.dart';
import 'package:emi_calculatornew/swp_calculator_screen.dart';
import 'package:emi_calculatornew/lumpsum_calculator_screen.dart';
import 'package:emi_calculatornew/goal_calculator_screen.dart';
import 'package:emi_calculatornew/splash_screen.dart';
import 'package:emi_calculatornew/vat_calculator_screen.dart';
import 'package:emi_calculatornew/fixed_deposit_calculator_screen.dart';
import 'package:emi_calculatornew/recurring_deposit_calculator_screen.dart';
import 'package:emi_calculatornew/house_rent_calculator_screen.dart';
import 'package:emi_calculatornew/cash_calculator_screen.dart';
import 'package:emi_calculatornew/live_data_screen.dart';
import 'package:emi_calculatornew/profile_screen.dart';
import 'package:emi_calculatornew/screens/create_loan_profile_screen.dart';
import 'package:emi_calculatornew/screens/view_loan_profiles_screen.dart';
import 'package:emi_calculatornew/screens/loan_eligibility_screen.dart';
import 'package:emi_calculatornew/screens/income_tax_calculator_screen.dart';
import 'package:emi_calculatornew/screens/emi_calculator_screen.dart';
import 'package:emi_calculatornew/screens/calculation_history_screen.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/providers/language_provider.dart';
import 'package:emi_calculatornew/providers/language_provider.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emi_calculatornew/onboarding_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showOnboarding = true;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getBool('onboarding_completed') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !completed;
        _isLoadingPrefs = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    if (_isLoadingPrefs) {
      return const SizedBox.shrink();
    }

    return MaterialApp(
      title: 'Loan Trix',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      // Always use English for Material widgets to avoid localization errors
      locale: const Locale('en', ''),
      localizationsDelegates: const [
        lang.AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
      ],
      home: _showOnboarding ? const OnboardingScreen() : const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final PageController _pageController;
  bool _isPageChanging = false;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _screens = [
      HomeScreen(
        onInstantLoanTap: () => _onItemTapped(1),
      ),
      const LiveDataScreen(),
      const CashCalculatorScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    // Prevent multiple rapid taps
    if (_isPageChanging) return;
    
    // If already on the selected page, don't do anything
    if (_selectedIndex == index) return;
    
    // Update selected index immediately for responsive UI
    setState(() {
      _selectedIndex = index;
      _isPageChanging = true;
    });
    
    // Navigate to the selected page with smooth animation
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    ).then((_) {
      if (mounted) {
        setState(() {
          _isPageChanging = false;
        });
      }
    }).catchError((error) {
      // Handle any errors during navigation
      if (mounted) {
        setState(() {
          _isPageChanging = false;
        });
      }
    });
  }
  
  // Helper method to navigate directly to a specific page
  void navigateToPage(int index) {
    _onItemTapped(index);
  }

  Widget _buildToolbarIcon({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final themeProvider = ThemeProvider.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: themeProvider.borderColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: themeProvider.textPrimary,
            size: 20,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            final localizations = lang.AppLocalizations.of(context);
            return Row(
              children: [
                // Logo
                Image.asset(
                  'assets/notesimages/logo.jpeg',
                  height: 48,
                  width: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                // App Name
                Text(
                  localizations?.appName ?? 'Loan Trix',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          _buildToolbarIcon(
            context: context,
            icon: Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          _buildToolbarIcon(
            context: context,
            icon: Icons.person_outline,
            tooltip: 'Profile',
            onTap: () {
              _onItemTapped(3);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          if (!_isPageChanging) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: SizedBox(
        height: 90,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Curved navigation bar with notch
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _CurvedBottomNavBarClipper(
                  selectedIndex: _selectedIndex,
                  itemCount: 4,
                ),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: themeProvider.cardBackground,
                    border: Border.all(
                      color: themeProvider.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -3),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(Icons.home_rounded, 'Home', 0),
                        _buildNavItem(Icons.flash_on, 'Loans', 1),
                        _buildNavItem(Icons.account_balance_wallet, 'Wallet', 2),
                        _buildNavItem(Icons.person, 'Profile', 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Floating selected item with animation
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: 30,
              left: _getSelectedItemPosition(),
              child: _buildFloatingSelectedItem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF5DADE2), Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Color(0xFF5DADE2)),
                ),
                SizedBox(height: 10),
                Text(
                  'Loan APP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage your loans',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Color(0xFF5DADE2)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate, color: Color(0xFF5DADE2)),
            title: const Text('Loan APP'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF5DADE2)),
            title: const Text('Loan History'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF5DADE2)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3); // Navigate to Profile (index 3)
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF5DADE2)),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF5DADE2)),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }


  // Calculate position of selected item for floating effect
  double _getSelectedItemPosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 20.0;
    final availableWidth = screenWidth - (padding * 2);
    final itemWidth = availableWidth / 4;
    final circleWidth = 56.0; // Width of floating circle
    
    return padding + (itemWidth * _selectedIndex) + (itemWidth / 2) - (circleWidth / 2);
  }

  // Build floating selected item
  Widget _buildFloatingSelectedItem() {
    final icon = _getIconForIndex(_selectedIndex);
    final label = _getLabelForIndex(_selectedIndex);
    final floatingThemeProvider = Provider.of<ThemeProvider>(context);
    // Use brand color in light mode, lighter blue in dark mode for better visibility
    final labelColor = floatingThemeProvider.isDarkMode 
        ? const Color(0xFF7BC4E8) // Lighter blue for dark mode
        : const Color(0xFF5DADE2); // Original blue for light mode
    
    return GestureDetector(
      onTap: () => _onItemTapped(_selectedIndex),
      child: Container(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF5DADE2),
                    const Color(0xFF4A9FD8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.9),
                  width: 4,
                ),
                boxShadow: [
                  // Outer shadow for depth
                  BoxShadow(
                    color: const Color(0xFF5DADE2).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: 2,
                  ),
                  // Inner shadow for 3D effect
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                    spreadRadius: -1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home_rounded;
      case 1:
        return Icons.flash_on;
      case 2:
        return Icons.account_balance_wallet;
      case 3:
        return Icons.person;
      default:
        return Icons.home_rounded;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Loans';
      case 2:
        return 'Wallet';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    final navThemeProvider = Provider.of<ThemeProvider>(context);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onItemTapped(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hide icon when selected (it's floating above)
              if (!isSelected) ...[
                Icon(
                  icon,
                  color: navThemeProvider.textSecondary,
                  size: 22,
                ),
                const SizedBox(height: 1),
              ],
              // Label for unselected items only (selected item label is in floating widget)
              if (label.isNotEmpty && !isSelected) ...[
                Text(
                  label,
                  style: TextStyle(
                    color: navThemeProvider.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onInstantLoanTap,
  });

  final VoidCallback onInstantLoanTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Create staggered animations for each card
    _fadeAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.5 + (index * 0.15),
            curve: Curves.easeOut,
          ),
        ),
      );
    });

    _slideAnimations = List.generate(3, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.5 + (index * 0.15),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    _scaleAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.5 + (index * 0.15),
            curve: Curves.elasticOut,
          ),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CIBIL Score Checker Card
          Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C3E50), // Changed to solid color
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row( // Added Row for title and arrow
                            children: [
                              Consumer<LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  final localizations = lang.AppLocalizations.of(context);
                                  return Text(
                                    localizations?.cibilScoreCheck ?? 'CIBIL Score Check',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              final localizations = lang.AppLocalizations.of(context);
                              return Text(
                                localizations?.checkCreditScore ?? 'Check your credit score instantly ',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      height: 120,
                      width: 120,
                      child: Lottie.asset(
                        'assets/lottiegif/Credit Lottie.json',
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loan Profile Section with Enhanced Animations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeTransition(
                  opacity: _fadeAnimations[0],
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-0.2, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                      ),
                    ),
                    child: Consumer<LanguageProvider>(
                      builder: (context, languageProvider, _) {
                        final localizations = lang.AppLocalizations.of(context);
                        return Text(
                          localizations?.loanProfile ?? 'Loans',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Always display cards in a horizontal row (one line)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildAnimatedLoanCard(
                        0,
                        '1 Lakh Loan',
                        Colors.pink.shade400,
                        Colors.pink.shade600,
                        '₹1,00,000',
                        'assets/lottiegif/Fake3Dvectorcoin.json',
                        widget.onInstantLoanTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildAnimatedLoanCard(
                        1,
                        '5 Lakh Loan',
                        Colors.deepOrange.shade400,
                        Colors.deepOrange.shade600,
                        '₹5,00,000',
                        'assets/lottiegif/Fake3Dvectorcoin.json',
                        widget.onInstantLoanTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: _buildAnimatedLoanCard(
                        2,
                        '10 Lakh Loan',
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                        '₹10,00,000',
                        'assets/lottiegif/Fake3Dvectorcoin.json',
                        widget.onInstantLoanTap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // EMI Calculator Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    final localizations = lang.AppLocalizations.of(context);
                    return Text(
                      localizations?.businessCalculator ?? 'Advance Calculators',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GstCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'GST\nCalculator',
                          Colors.purple.shade100,
                          Colors.purple.shade400,
                          Icons.calculate,
                          Colors.red.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EmiCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'EMI\nCalculator',
                          Colors.teal.shade100,
                          Colors.teal.shade400,
                          Icons.calculate_outlined,
                          Colors.teal.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PpfCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'PPF\nCalculator',
                          Colors.purple.shade50,
                          Colors.purple.shade400,
                          Icons.account_balance,
                          Colors.purple.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SipCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'SIP\nCalculator',
                          Colors.blue.shade100,
                          Colors.blue.shade400,
                          Icons.trending_up,
                          Colors.blue.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FixedDepositCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Fixed Deposit\nCalculator',
                          Colors.orange.shade100,
                          Colors.orange.shade400,
                          Icons.account_balance,
                          Colors.orange.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecurringDepositCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Recurring Deposit\nCalculator',
                          Colors.teal.shade100,
                          Colors.teal.shade400,
                          Icons.savings,
                          Colors.teal.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Mutual Fund Tools Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mutual Fund Tools',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SipCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Systematic Investment\nPlan',
                          Colors.deepPurple.shade50,
                          Colors.deepPurple.shade300,
                          Icons.auto_graph,
                          Colors.deepPurple.shade200,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SwpCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Systematic Withdrawal\nPlan',
                          Colors.green.shade50,
                          Colors.green.shade400,
                          Icons.money_off_csred,
                          Colors.green.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LumpsumCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Lumpsum\nCalculator',
                          Colors.amber.shade50,
                          Colors.amber.shade400,
                          Icons.stacked_line_chart,
                          Colors.amber.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoalCalculatorScreen(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Goal\nCalculator',
                          Colors.indigo.shade50,
                          Colors.indigo.shade400,
                          Icons.flag_circle,
                          Colors.indigo.shade200,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tax Calculator Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    final localizations = lang.AppLocalizations.of(context);
                    return Text(
                      localizations?.taxCalculator ?? 'Tax Calculator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.textPrimary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Income Tax Calculator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IncomeTaxCalculatorScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              final localizations = lang.AppLocalizations.of(context);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations?.incomeTaxCalculator ?? 'Income Tax Calculator',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations?.calculateTaxLiability ?? 'Calculate your tax liability',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // VAT Calculator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VatCalculatorScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.attach_money,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VAT Calculator',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Calculate Value Added Tax',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // House Rent Calculator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HouseRentCalculatorScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.apartment,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<LanguageProvider>(
                            builder: (context, languageProvider, _) {
                              final localizations = lang.AppLocalizations.of(context);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations?.houseRentCalculator ?? 'House Rent Calculator',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations?.calculateHouseRent ?? 'Estimate yearly rent expenses',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildAnimatedLoanCard(
    int index,
    String title,
    Color primaryColor,
    Color secondaryColor,
    String amountRange,
    String lottieAsset,
    VoidCallback onTap,
  ) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: ScaleTransition(
          scale: _scaleAnimations[index],
          child: _LoanProfileCard(
            title: title,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            amountRange: amountRange,
            lottieAsset: lottieAsset,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  Widget _buildLoanProfileCard(String title, Color color, IconData icon, [String? amountRange]) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(themeProvider.themeMode == ThemeMode.dark ? 0.3 : 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: 0.3,
                ),
              ),
              if (amountRange != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    amountRange,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_forward,
              color: color,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCalculatorCard(
    String title,
    Color bgColor,
    Color buttonColor,
    IconData icon,
    Color iconBgColor,
  ) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: themeProvider.themeMode == ThemeMode.dark
            ? Border.all(color: themeProvider.borderColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              themeProvider.themeMode == ThemeMode.dark ? 0.3 : 0.1
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Click Here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Loan Profile Card with Interactive Animations
class _LoanProfileCard extends StatefulWidget {
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final String amountRange;
  final String lottieAsset;
  final VoidCallback onTap;

  const _LoanProfileCard({
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
    required this.amountRange,
    required this.lottieAsset,
    required this.onTap,
  });

  @override
  State<_LoanProfileCard> createState() => _LoanProfileCardState();
}

class _LoanProfileCardState extends State<_LoanProfileCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconRotationAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOut,
      ),
    );

    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _tapController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _tapController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _tapController.reverse().then((_) {
      widget.onTap();
    });
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _tapController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // More granular responsive sizing
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;
    
    // Calculate card height based on screen size
    double cardHeight;
    if (isVerySmallScreen) {
      cardHeight = screenHeight * 0.22; // 22% of screen height
    } else if (isSmallScreen) {
      cardHeight = screenHeight * 0.24; // 24% of screen height
    } else if (isMediumScreen) {
      cardHeight = 200.0;
    } else {
      cardHeight = 220.0;
    }
    
    // Ensure minimum and maximum heights
    cardHeight = cardHeight.clamp(160.0, 250.0);
    
    // Responsive font and icon sizes
    final iconSize = isVerySmallScreen ? 22.0 : (isSmallScreen ? 24.0 : (isMediumScreen ? 26.0 : 28.0));
    final titleSize = isVerySmallScreen ? 12.0 : (isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0));
    final amountSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : (isMediumScreen ? 12.0 : 13.0));
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Container(
          height: cardHeight,
          padding: EdgeInsets.all(padding),
          constraints: const BoxConstraints(
            minHeight: 160,
            maxHeight: 250,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor,
                widget.secondaryColor,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon with animated rotation and glow effect
              RotationTransition(
                turns: _iconRotationAnimation,
                child: Container(
                  padding: EdgeInsets.all(isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: iconSize + 10,
                    width: iconSize + 10,
                    child: Lottie.asset(
                      widget.lottieAsset,
                      fit: BoxFit.contain,
                      repeat: true,
                    ),
                  ),
                ),
              ),
              
              // Title with subtle animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Amount badge with enhanced styling
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isVerySmallScreen ? 6 : (isSmallScreen ? 8 : 10),
                    vertical: isVerySmallScreen ? 4 : (isSmallScreen ? 5 : 6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 60,
                  ),
                  decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                  child: Text(
                    widget.amountRange,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: amountSize,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Arrow button with enhanced design
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isVerySmallScreen ? 32 : (isSmallScreen ? 36 : 40),
                height: isVerySmallScreen ? 32 : (isSmallScreen ? 36 : 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: RotationTransition(
                  turns: _iconRotationAnimation,
                  child: Icon(
                  Icons.arrow_forward,
                  color: widget.primaryColor,
                  size: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Screen
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'Search Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Search for loans, calculators, and more',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}


// Notifications Screen
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_rounded,
            size: 100,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            'Notifications Screen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Stay updated with your loan reminders',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom clipper for curved bottom navigation bar with notch
class _CurvedBottomNavBarClipper extends CustomClipper<Path> {
  final int selectedIndex;
  final int itemCount;

  _CurvedBottomNavBarClipper({
    required this.selectedIndex,
    required this.itemCount,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final notchRadius = 30.0;
    final cornerRadius = 35.0;
    
    // Calculate position of the notch
    final padding = 20.0;
    final availableWidth = size.width - (padding * 2);
    final itemWidth = availableWidth / itemCount;
    final notchCenterX = padding + (itemWidth * selectedIndex) + (itemWidth / 2);
    
    // Start from top-left corner
    path.moveTo(0, cornerRadius);
    
    // Top-left rounded corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    
    // Top edge until before notch
    if (notchCenterX - notchRadius > cornerRadius) {
      path.lineTo(notchCenterX - notchRadius, 0);
    } else {
      path.lineTo(cornerRadius, 0);
    }
    
    // Create curved notch
    final notchStartX = notchCenterX - notchRadius;
    final notchEndX = notchCenterX + notchRadius;
    
    if (notchStartX > 0 && notchEndX < size.width) {
      // Left curve of notch
      path.quadraticBezierTo(
        notchStartX + notchRadius * 0.5,
        0,
        notchStartX + notchRadius * 0.5,
        notchRadius * 0.3,
      );
      
      // Bottom curve of notch
      path.quadraticBezierTo(
        notchCenterX,
        notchRadius * 0.6,
        notchCenterX,
        notchRadius,
      );
      
      // Right curve of notch
      path.quadraticBezierTo(
        notchCenterX,
        notchRadius * 0.6,
        notchEndX - notchRadius * 0.5,
        notchRadius * 0.3,
      );
      
      path.quadraticBezierTo(
        notchEndX - notchRadius * 0.5,
        0,
        notchEndX,
        0,
      );
    }
    
    // Top edge after notch
    if (notchEndX < size.width - cornerRadius) {
      path.lineTo(size.width - cornerRadius, 0);
    } else {
      path.lineTo(size.width, 0);
    }
    
    // Top-right rounded corner
    if (size.width - cornerRadius > notchEndX) {
      path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    }
    
    // Right edge
    path.lineTo(size.width, size.height);
    
    // Bottom edge
    path.lineTo(0, size.height);
    
    // Left edge
    path.lineTo(0, cornerRadius);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return oldClipper is _CurvedBottomNavBarClipper &&
        oldClipper.selectedIndex != selectedIndex;
  }
}
