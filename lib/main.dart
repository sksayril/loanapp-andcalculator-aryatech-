import 'package:emi_calculatornew/cibil_score_screen.dart';
import 'package:emi_calculatornew/screens/gst_calculator_modern.dart';
import 'package:emi_calculatornew/screens/ppf_calculator_modern.dart';
import 'package:emi_calculatornew/screens/sip_calculator_modern.dart';
import 'package:emi_calculatornew/screens/swp_calculator_modern.dart';
import 'package:emi_calculatornew/screens/lumpsum_calculator_modern.dart';
import 'package:emi_calculatornew/screens/goal_calculator_modern.dart';
import 'package:emi_calculatornew/splash_screen.dart';
import 'package:emi_calculatornew/screens/vat_calculator_modern.dart';
import 'package:emi_calculatornew/screens/fixed_deposit_calculator_modern.dart';
import 'package:emi_calculatornew/screens/recurring_deposit_calculator_modern.dart';
import 'package:emi_calculatornew/screens/house_rent_calculator_modern.dart';
import 'package:emi_calculatornew/cash_calculator_screen.dart';
import 'package:emi_calculatornew/live_data_screen.dart';
import 'package:emi_calculatornew/profile_screen.dart';
import 'package:emi_calculatornew/screens/create_loan_profile_screen.dart';
import 'package:emi_calculatornew/screens/view_loan_profiles_screen.dart';
import 'package:emi_calculatornew/screens/loan_eligibility_screen.dart';
import 'package:emi_calculatornew/screens/income_tax_calculator_modern.dart';
import 'package:emi_calculatornew/screens/emi_calculator_modern.dart';
import 'package:emi_calculatornew/screens/calculation_history_screen.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/screens/home_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/personal_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/business_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/education_loan_calculator_screen.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/providers/language_provider.dart';
import 'package:emi_calculatornew/providers/language_provider.dart' as lang;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emi_calculatornew/screens/profile_setup_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:emi_calculatornew/services/ad_helper.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();
  
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Loan Sathi',
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
      home: const SplashScreen(), // Always start with splash screen
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
      // Index 0: Home - All calculators and tools
      HomeScreen(
        onInstantLoanTap: () => _onItemTapped(1),
      ),
      // Index 1: Loans - All loan categories (Personal, Home, Car, Education, etc.)
      const LiveDataScreen(),
      // Index 2: Wallet - Cash counter and calculations
      const CashCalculatorScreen(),
      // Index 3: Profile - User profile settings
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

  // Convert screen index to bottom nav index
  int _getBottomNavIndex(int screenIndex) {
    // Map screen indices to bottom nav indices
    // Bottom nav: Home(0), Loans(1), Profile(2) - Search commented out
    switch (screenIndex) {
      case 0: return 0; // Home
      case 1: return 1; // Loans
      case 2: return 1; // Wallet (maps to Loans position, not shown in nav)
      case 3: return 2; // Profile
      default: return 0;
    }
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
                // Logo - smaller size for app bar
                Image.asset(
                  'assets/notesimages/loansathloggo.jpeg',
                  height: 40,
                  width: 40,
                  fit: BoxFit.contain, // Show full logo maintaining aspect ratio
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback icon if logo doesn't load
                    return Icon(
                      Icons.account_balance,
                      size: 40,
                      color: themeProvider.textPrimary,
                    );
                  },
                ),
                const SizedBox(width: 12),
                // App Name
                Text(
                  localizations?.appName ?? 'Loan Sathi',
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
              _onItemTapped(3); // Navigate to Profile
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, -6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, -3),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: const Color(0xFF1E3A5F).withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, -2),
              spreadRadius: 3,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom > 0 
              ? MediaQuery.of(context).padding.bottom + 8 
              : 8,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Background container to cover entire bottom area with gradient - extends fully to bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.98),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: const Color(0xFF1E3A5F).withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 0),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
                // SafeArea for content only
                SafeArea(
                  top: false,
                  bottom: false,
                  child: SizedBox(
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
                      selectedIndex: _getBottomNavIndex(_selectedIndex),
                      itemCount: 3,
                    ),
                    child: Container(
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            const Color(0xFFF8F9FA),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 25,
                            offset: const Offset(0, -5),
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, -3),
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: const Color(0xFF1E3A5F).withOpacity(0.12),
                            blurRadius: 15,
                            offset: const Offset(0, -2),
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 0),
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 6,
                          bottom: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Home - All calculators, CIBIL check, tools
                            _buildNavItem(Icons.home_outlined, 'Home', 0),
                            // Loans - Personal, Home, Car, Education loans, etc.
                            _buildNavItem(Icons.attach_money_outlined, 'Loans', 1),
                            // Search icon (COMMENTED OUT)
                            // _buildNavItem(Icons.search_outlined, '', 2),
                            // Profile - User settings and profile
                            _buildNavItem(Icons.person_outline, 'Profile', 3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Animated selected item with rounded rectangle background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  bottom: 24,
                  left: _getSelectedItemPosition(),
                  child: _buildAnimatedSelectedItem(),
                ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
            leading: const Icon(Icons.home_rounded, color: Color(0xFF5DADE2)),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.flash_on, color: Color(0xFF5DADE2)),
            title: const Text('Loans'),
            subtitle: const Text('Personal, Home, Car & More'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1); // Navigate to Loans
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF5DADE2)),
            title: const Text('Wallet'),
            subtitle: const Text('Cash Counter'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2); // Navigate to Wallet
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF5DADE2)),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3); // Navigate to Profile
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
    final bottomNavIndex = _getBottomNavIndex(_selectedIndex);
    final itemWidth = availableWidth / 3; // 3 items in bottom nav (Search commented out)
    final buttonWidth = 80.0; // Width of selected button
    
    return padding + (itemWidth * bottomNavIndex) + (itemWidth / 2) - (buttonWidth / 2);
  }

  // Build animated selected item with rounded rectangle
  Widget _buildAnimatedSelectedItem() {
    final icon = _getIconForIndex(_selectedIndex);
    final label = _getLabelForIndex(_selectedIndex);
    
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2), // Scale from 0.8 to 1.0
          child: Opacity(
            opacity: value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFE1BEE7), // Light purple background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFF7C4DFF), // Dark purple icon
                    size: 20,
                  ),
                  if (label.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF7C4DFF), // Dark purple text
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.attach_money_outlined;
      case 2:
        return Icons.search_outlined;
      case 3:
        return Icons.person_outline;
      default:
        return Icons.home_outlined;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'Home'; // All calculators and tools
      case 1:
        return 'Loans'; // All loan types (Personal, Home, Car, etc.)
      case 2:
        return ''; // Search (no label, just icon)
      case 3:
        return 'Profile'; // User profile
      default:
        return '';
    }
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _onItemTapped(index);
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Show outline icon for inactive items, hide for selected (it's in animated button)
              if (!isSelected)
                Icon(
                  icon,
                  color: const Color(0xFF7C4DFF), // Dark purple for inactive icons
                  size: 24,
                ),
              // Hide label for inactive items (only show in selected button)
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

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isAdLoading = false;
  
  // Apply Now button visibility for Loans section
  bool _isApplyNowActive = false;
  bool _isCheckingApplyNow = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Load rewarded ad on init
    _loadRewardedAd();
    // Check Apply Now status
    _checkApplyNowStatus();

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
    _rewardedAd?.dispose();
    super.dispose();
  }

  // Load Rewarded Ad
  Future<void> _loadRewardedAd() async {
    if (_isAdLoading) return;
    
    setState(() {
      _isAdLoading = true;
    });
    
    print('→ Loading rewarded ad for Check Full Report...');
    _rewardedAd = await AdHelper.loadRewardedAd();
    
    if (_rewardedAd != null && mounted) {
      setState(() {
        _isRewardedAdLoaded = true;
        _isAdLoading = false;
      });
      
      print('✓ Rewarded ad loaded successfully');
      
      // Set full screen content callback
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('Rewarded ad showed full screen content');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('Rewarded ad dismissed');
          ad.dispose();
          setState(() {
            _isRewardedAdLoaded = false;
          });
          _loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('✗ Rewarded ad failed to show: ${error.message}');
          ad.dispose();
          setState(() {
            _isRewardedAdLoaded = false;
            _isAdLoading = false;
          });
          _loadRewardedAd(); // Load next ad
        },
        onAdImpression: (ad) {
          print('Rewarded ad impression');
        },
      );
    } else {
      print('✗ Failed to load rewarded ad');
      if (mounted) {
        setState(() {
          _isRewardedAdLoaded = false;
          _isAdLoading = false;
        });
      }
    }
  }

  // Check Apply Now status from API
  Future<void> _checkApplyNowStatus() async {
    try {
      final status = await LoanApiService.checkApplyNowStatus();
      if (mounted) {
        setState(() {
          _isApplyNowActive = status.isActive;
          _isCheckingApplyNow = false;
        });
      }
    } catch (e) {
      print('Error checking Apply Now status: $e');
      // Default to showing section if API fails
      if (mounted) {
        setState(() {
          _isApplyNowActive = true;
          _isCheckingApplyNow = false;
        });
      }
    }
  }

  // Show Rewarded Ad and Navigate
  void _showRewardedAdAndNavigate() async {
    print('→ Attempting to show rewarded ad...');
    print('  Ad loaded: $_isRewardedAdLoaded');
    print('  Ad object: ${_rewardedAd != null}');
    
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      print('✓ Showing rewarded ad now');
      
      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('✓ User earned reward: ${reward.amount} ${reward.type}');
            // Navigate after user watches the ad
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
              );
            }
          },
        );
      } catch (e) {
        print('✗ Error showing rewarded ad: $e');
        // If ad fails to show, navigate anyway
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
          );
        }
      }
    } else {
      print('⚠ Rewarded ad not ready, loading ad first...');
      // If ad is not loaded, show loading dialog and try to load ad
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      // Try to load ad one more time
      await _loadRewardedAd();
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (_rewardedAd != null && _isRewardedAdLoaded && mounted) {
        print('✓ Ad loaded on retry, showing now');
        
        try {
          await _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              print('✓ User earned reward: ${reward.amount} ${reward.type}');
              // Navigate after user watches the ad
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
                );
              }
            },
          );
        } catch (e) {
          print('✗ Error showing rewarded ad on retry: $e');
          // If ad fails to show, navigate anyway
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
            );
          }
        }
      } else {
        print('⚠ Could not load ad, navigating without ad');
        // Navigate even if ad fails to load
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
          );
        }
      }
    }
  }

  // Show confirmation dialog before rewarded ad (COMMENTED OUT)
  /* Future<void> _showRewardedAdConfirmationDialogForCibil() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gift icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 50,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 20),
              // Title
              const Text(
                'Unlock Premium Features',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Body text
              Text(
                'Watch a short video to continue using the free version.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Watch Video button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _showRewardedAdAndNavigateToCibil();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Watch Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // No Thanks button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'No, Thanks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  } */

  // Show rewarded ad and then navigate to CIBIL score screen (COMMENTED OUT)
  /* Future<void> _showRewardedAdAndNavigateToCibil() async {
    if (!mounted) return;
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Load the rewarded ad
      final rewardedAd = await AdHelper.loadRewardedAd();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (rewardedAd != null) {
        // Show the rewarded ad
        rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            // After ad is dismissed, navigate to CIBIL screen
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
              );
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Rewarded ad failed to show: $error');
            ad.dispose();
            // Navigate to CIBIL screen even if ad fails to show
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
              );
            }
          },
          onAdShowedFullScreenContent: (ad) {
            print('Rewarded ad showed successfully');
          },
        );

        // Show the ad with reward callback
        rewardedAd.show(
          onUserEarnedReward: (ad, reward) {
            print('User earned reward: ${reward.amount} ${reward.type}');
          },
        );
      } else {
        // If ad failed to load, just navigate to CIBIL screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if still open
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
        );
      }
    }
  } */

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CIBIL Score Checker Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: GestureDetector(
              onTap: () {
                // Direct navigation - ad dialog commented out
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CibilScoreScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? themeProvider.cardBackground
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? themeProvider.borderColor
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Credit Health header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Credit Health',
                          style: TextStyle(
                            color: themeProvider.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: Colors.green.shade600,
                                size: 11,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Excellent',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Lottie animation - slightly shifted to left
                    Padding(
                      padding: const EdgeInsets.only(left: 54, right: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 200,
                          height: 200,
                          alignment: Alignment.center,
                          child: Lottie.asset(
                            'assets/lottiegif/Credit Lottie.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            animate: true,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Info text
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          'Your credit score is higher than 85% of users. Keep it up!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeProvider.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Check Full Report button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _showRewardedAdAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A5F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Check Full Report',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Powered by CIBIL
                    Center(
                      child: Text(
                        'Powered by CIBIL',
                        style: TextStyle(
                          color: themeProvider.textSecondary.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Loans Section (only show if isActive is true)
          if (!_isCheckingApplyNow && _isApplyNowActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<LanguageProvider>(
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
                  const SizedBox(height: 16),
                  // Grid of loan cards (2 columns)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeLoanCalculatorScreen(),
                              ),
                            );
                          },
                          child: _buildLoanCard(
                            'Home Loan',
                            'From 8.4% p.a.',
                            Icons.home_outlined,
                            const Color(0xFF1E3A5F),
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
                                builder: (context) => const PersonalLoanCalculatorScreen(),
                              ),
                            );
                          },
                          child: _buildLoanCard(
                            'Personal Loan',
                            'Instant Approval',
                            Icons.person_outline,
                            const Color(0xFF7C4DFF),
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
                                builder: (context) => const BusinessLoanCalculatorScreen(),
                              ),
                            );
                          },
                          child: _buildLoanCard(
                            'Business Loan',
                            'Expand now',
                            Icons.store_outlined,
                            const Color(0xFFFF6B35),
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
                                builder: (context) => const EducationLoanCalculatorScreen(),
                              ),
                            );
                          },
                          child: _buildLoanCard(
                            'Education',
                            'Study abroad',
                            Icons.school_outlined,
                            const Color(0xFF00BFA5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Bike Loan and Instant Cash cards removed
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
                              builder: (context) => const GstCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'GST Calculator',
                          'Calculate GST',
                          Icons.calculate,
                          Colors.purple.shade600,
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
                              builder: (context) => const EmiCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'EMI Calculator',
                          'Calculate EMI',
                          Icons.calculate_outlined,
                          Colors.teal.shade600,
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
                              builder: (context) => const PpfCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'PPF Calculator',
                          'Plan your savings',
                          Icons.account_balance,
                          Colors.purple.shade600,
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
                              builder: (context) => const SipCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'SIP Calculator',
                          'Invest systematically',
                          Icons.trending_up,
                          Colors.blue.shade600,
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
                              builder: (context) => const FixedDepositCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Fixed Deposit',
                          'Secure returns',
                          Icons.account_balance,
                          Colors.orange.shade600,
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
                              builder: (context) => const RecurringDepositCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Recurring Deposit',
                          'Monthly savings',
                          Icons.savings,
                          Colors.green.shade600,
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
                              builder: (context) => const SipCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'SIP',
                          'Systematic Investment',
                          Icons.auto_graph,
                          Colors.deepPurple.shade600,
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
                              builder: (context) => const SwpCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'SWP',
                          'Systematic Withdrawal',
                          Icons.money_off_csred,
                          Colors.green.shade600,
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
                              builder: (context) => const LumpsumCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Lumpsum',
                          'One-time investment',
                          Icons.stacked_line_chart,
                          Colors.amber.shade700,
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
                              builder: (context) => const GoalCalculatorModern(),
                            ),
                          );
                        },
                        child: _buildBusinessCalculatorCard(
                          'Goal Calculator',
                          'Plan your goals',
                          Icons.flag_circle,
                          Colors.indigo.shade600,
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
                    builder: (context) => const IncomeTaxCalculatorModern(),
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
                    builder: (context) => const VatCalculatorModern(),
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
                    builder: (context) => const HouseRentCalculatorModern(),
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
    IconData icon,
    String amountRange,
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
            icon: icon,
            amountRange: amountRange,
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

  Widget _buildLoanCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.themeMode == ThemeMode.dark
              ? themeProvider.borderColor
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at top
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCalculatorCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconBgColor,
  ) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.themeMode == ThemeMode.dark
              ? themeProvider.borderColor
              : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon at top
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconBgColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              color: themeProvider.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Enhanced Loan Profile Card with Interactive Animations
class _LoanProfileCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String amountRange;
  final VoidCallback onTap;

  const _LoanProfileCard({
    required this.title,
    required this.icon,
    required this.amountRange,
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    
    // Responsive sizing
    final isVerySmallScreen = screenWidth < 320;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth < 600;
    
    // Card height - increased slightly to prevent overflow
    double cardHeight = isVerySmallScreen ? 190.0 : (isSmallScreen ? 210.0 : 230.0);
    
    // Responsive font and icon sizes - reduced to fit better
    final iconSize = isVerySmallScreen ? 24.0 : (isSmallScreen ? 28.0 : 32.0);
    final titleSize = isVerySmallScreen ? 13.0 : (isSmallScreen ? 15.0 : 17.0);
    final amountSize = isVerySmallScreen ? 10.0 : (isSmallScreen ? 11.0 : 12.0);
    final padding = isVerySmallScreen ? 12.0 : (isSmallScreen ? 14.0 : 16.0);
    
    // Purple color for the theme
    const purpleColor = Color(0xFF7C4DFF);
    const lightPurple = Color(0xFFE1BEE7);

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
            minHeight: 180,
            maxHeight: 250,
          ),
          decoration: BoxDecoration(
            color: themeProvider.themeMode == ThemeMode.dark 
                ? themeProvider.cardBackground 
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: themeProvider.themeMode == ThemeMode.dark
                ? Border.all(color: themeProvider.borderColor)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon at top left
              Icon(
                widget.icon,
                color: purpleColor,
                size: iconSize,
              ),
              
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // "Get Upto" text
                    Text(
                      'Get Upto',
                      style: TextStyle(
                        color: themeProvider.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    
                    // Title in bold purple
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: purpleColor,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    
                    // Amount badge in light purple
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isVerySmallScreen ? 8 : 10,
                        vertical: isVerySmallScreen ? 4 : 5,
                      ),
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.amountRange,
                        style: TextStyle(
                          color: themeProvider.textPrimary,
                          fontSize: amountSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Purple action button with white arrow
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: isVerySmallScreen ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: purpleColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: isVerySmallScreen ? 18 : 20,
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
