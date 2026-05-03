import 'package:flutter/material.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/screens/personal_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/home_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/business_loan_calculator_screen.dart';
import 'package:emi_calculatornew/screens/education_loan_calculator_screen.dart';
import 'package:emi_calculatornew/cibil_score_screen.dart';
import 'package:emi_calculatornew/screens/loan_eligibility_screen.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculatornew/services/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:emi_calculatornew/widgets/skeleton_loader.dart';

class InstantLoanCategory {
  const InstantLoanCategory({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.color,
    required this.categoryId,
  });

  final String title;
  final String emoji;
  final String subtitle;
  final Color color;
  final String? categoryId;
}

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({super.key});

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  List<InstantLoanCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _highlightedIndex = 0;

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isAdLoading = false;
  bool _isCardNavigationInProgress = false;

  // Mapping of category names to icons, details and colors
  final Map<String, Map<String, dynamic>> _categoryMetadata = {
    'Personal Loan': {
      'icon': Icons.account_balance_wallet_outlined,
      'interestRate': '10.49% - 14%',
      'processingTime': 'Instant',
      'color': Color(0xFF5E35B1),
    },
    'Home Loan': {
      'icon': Icons.home_outlined,
      'interestRate': '8.50% Onwards',
      'processingTime': '3-5 Days',
      'color': Color(0xFFFF6B35),
    },
    'Business Loan': {
      'icon': Icons.store_outlined,
      'interestRate': '12% - 18%',
      'processingTime': '24 Hours',
      'color': Color(0xFF7C4DFF),
    },
    'Gold Loan': {
      'icon': Icons.savings_outlined,
      'interestRate': '7.5% Fixed',
      'processingTime': '1 Hour',
      'color': Color(0xFFF9A825),
    },
    'Car Loan': {
      'icon': Icons.directions_car_outlined,
      'interestRate': '9.25% - 11%',
      'processingTime': '48 Hours',
      'color': Color(0xFF1E88E5),
    },
    'Education Loan': {
      'icon': Icons.school_outlined,
      'interestRate': '8.5% - 10%',
      'processingTime': '5-7 Days',
      'color': Color(0xFF00BFA5),
    },
  };

  final List<String> _desiredOrder = [
    'Personal Loan',
    'Home Loan',
    'Education Loan',
    'Car Loan',
    'Gold Loan',
    'Business Loan',
  ];

  final List<_InfoGuideCardItem> _infoCards = const [
    _InfoGuideCardItem(
      title: 'Loan Guidance',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF23456B),
    ),
    _InfoGuideCardItem(
      title: 'Personal Loan Info',
      icon: Icons.person_outline,
      color: Color(0xFF7C4DFF),
    ),
    _InfoGuideCardItem(
      title: 'Home Loan Info',
      icon: Icons.home_outlined,
      color: Color(0xFF1E3A5F),
    ),
    _InfoGuideCardItem(
      title: 'Business Loan Info',
      icon: Icons.store_outlined,
      color: Color(0xFFFF6B35),
    ),
    _InfoGuideCardItem(
      title: 'Education Loan Info',
      icon: Icons.school_outlined,
      color: Color(0xFF00BFA5),
    ),
    _InfoGuideCardItem(
      title: 'CIBIL Score Info',
      icon: Icons.credit_score_outlined,
      color: Color(0xFF1E88E5),
    ),
    _InfoGuideCardItem(
      title: 'Eligibility Guide',
      icon: Icons.fact_check_outlined,
      color: Color(0xFF6D4C41),
    ),
    _InfoGuideCardItem(
      title: 'Documents Guide',
      icon: Icons.description_outlined,
      color: Color(0xFF455A64),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadRewardedAd();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadRewardedAd() async {
    if (_isAdLoading) return;
    _isAdLoading = true;

    _rewardedAd = await AdHelper.loadRewardedAd();

    if (!mounted) return;
    setState(() {
      _isRewardedAdLoaded = _rewardedAd != null;
      _isAdLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    // 100% Static categories as requested
    final List<String> staticNames = [
      'Personal Loan',
      'Home Loan',
      'Business Loan',
      'Education Loan',
    ];

    setState(() {
      _categories = staticNames.map((name) {
        final metadata = _categoryMetadata[name]!;
        return InstantLoanCategory(
          title: name,
          emoji: '', 
          subtitle: metadata['interestRate'] as String,
          color: metadata['color'] as Color,
          categoryId: name.toLowerCase().replaceAll(' ', '_'),
        );
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.cardBackground,
        title: Text(
          'Recommended for You',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: themeProvider.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'View All',
              style: TextStyle(
                color: const Color(0xFF7C4DFF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Loan & Credit Information'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _infoCards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.72,
                ),
                itemBuilder: (context, index) {
                  final item = _infoCards[index];
                  return _buildInfoCard(item);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(_InfoGuideCardItem item) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showRewardedAdAndNavigate(item.title),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeProvider.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: themeProvider.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: themeProvider.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            const Positioned(
              top: 2,
              right: 2,
              child: Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a rewarded ad (with load retry), then navigates for the tapped info card.
  Future<void> _showRewardedAdAndNavigate(String title) async {
    if (_isCardNavigationInProgress) return;
    _isCardNavigationInProgress = true;

    Future<void> presentRewardedAd(RewardedAd ad) async {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _isCardNavigationInProgress = false;
          _onInfoCardTap(title);
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (a, error) {
          a.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _isCardNavigationInProgress = false;
          _onInfoCardTap(title);
          _loadRewardedAd();
        },
      );

      try {
        await ad.show(
          onUserEarnedReward: (_, __) {},
        );
      } catch (_) {
        _isCardNavigationInProgress = false;
        _onInfoCardTap(title);
        _loadRewardedAd();
      }
    }

    if (_rewardedAd != null && _isRewardedAdLoaded) {
      await presentRewardedAd(_rewardedAd!);
      return;
    }

    if (!mounted) {
      _isCardNavigationInProgress = false;
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final ad = await AdHelper.loadRewardedAd();

    if (!mounted) {
      _isCardNavigationInProgress = false;
      return;
    }
    Navigator.of(context).pop();

    if (ad != null) {
      setState(() {
        _rewardedAd = ad;
        _isRewardedAdLoaded = true;
      });
      await presentRewardedAd(ad);
    } else {
      _isCardNavigationInProgress = false;
      _onInfoCardTap(title);
      _loadRewardedAd();
    }
  }

  void _onInfoCardTap(String title) {
    switch (title) {
      case 'Loan Guidance':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoanGuidenceScreen(),
          ),
        );
        return;
      case 'Loan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoanListingScreen(
              loanType: 'Loan',
              amountRange: 'All amounts',
              primaryColor: Color(0xFF23456B),
            ),
          ),
        );
        return;
      case 'Personal Loan Info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PersonalLoanInfoScreen()),
        );
        return;
      case 'Home Loan Info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeLoanInfoScreen()),
        );
        return;
      case 'Business Loan Info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BusinessLoanInfoScreen()),
        );
        return;
      case 'Education Loan Info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EducationLoanInfoScreen()),
        );
        return;
      case 'CIBIL Score Info':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CibilScoreScreen()),
        );
        return;
      case 'Eligibility Guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoanEligibilityScreen()),
        );
        return;
      case 'Documents Guide':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DocumentsGuideScreen()),
        );
        return;
      default:
        return;
    }
  }

  Widget _buildLoanListCard(InstantLoanCategory category) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final metadata = _categoryMetadata[category.title];
    final icon = metadata?['icon'] as IconData? ?? Icons.account_balance_wallet_outlined;
    final interestRate = metadata?['interestRate'] as String? ?? 'Contact for details';
    final processingTime = metadata?['processingTime'] as String? ?? 'Varies';
    final isInstant = processingTime.toLowerCase().contains('instant') || processingTime.toLowerCase().contains('hour');
    
    return InkWell(
      onTap: () {
        // Navigate directly to loan listing (ads disabled)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoanListingScreen(
              loanType: category.title,
              amountRange: category.subtitle,
              primaryColor: category.color,
              initialCategoryId: category.categoryId,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: category.color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Loan details
            Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  // Loan title
                  Text(
                    category.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Interest rate
                  Row(
                    children: [
                      Icon(
                        Icons.percent,
                        size: 14,
                        color: themeProvider.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        interestRate,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isInstant)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 12,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Instant',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Processing time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: themeProvider.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        processingTime,
                        style: TextStyle(
                          fontSize: 12,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                      ],
                    ),
                ],
              ),
            ),
            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: themeProvider.textSecondary.withOpacity(0.5),
            ),
          ],
                  ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF7C9CEE), Color(0xFF9EB7F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '⚡',
                  style: TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick processing\nFast disbursal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Pick a loan card below to view offers.\nPaperless application, trusted partners, curated for you.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() => _highlightedIndex = index);
            // Navigate directly to loan listing (ads disabled)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanListingScreen(
                  loanType: category.title,
                  amountRange: category.subtitle,
                  primaryColor: category.color,
                  initialCategoryId: category.categoryId,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Get Upto" header with emoji
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Get Upto',
                      style: TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                // Loan Title in purple
                Text(
                  category.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7C4DFF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                
                // Subtitle badge with purple background
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    category.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                // Purple gradient button with arrow
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF9575CD),
                        Color(0xFF7C4DFF),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C4DFF).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5E35B1).withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  /*
  // ============ COMMENTED OUT - REWARDED ADS DISABLED ============
  // Show confirmation dialog before rewarded ad
  Future<void> _showRewardedAdConfirmationDialog(InstantLoanCategory category) async {
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
                    _showRewardedAdAndNavigate(category);
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
  }

  // Show rewarded ad and then navigate to loan listing
  Future<void> _showRewardedAdAndNavigate(InstantLoanCategory category) async {
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
            // After ad is dismissed, navigate to loan listing
            if (mounted) {
              _navigateToLoanListing(category);
            }
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('Rewarded ad failed to show: $error');
            ad.dispose();
            // Navigate to loan listing even if ad fails to show
            if (mounted) {
              _navigateToLoanListing(category);
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
        // If ad failed to load, just navigate to loan listing
        if (mounted) {
          _navigateToLoanListing(category);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if still open
        _navigateToLoanListing(category);
      }
    }
  }
  */
  // ============ END OF COMMENTED OUT AD CODE ============

  void _navigateToLoanListing(InstantLoanCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanListingScreen(
          loanType: category.title,
          amountRange: 'All amounts',
          primaryColor: category.color,
          initialCategoryId: category.categoryId,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return const SkeletonLoanCard();
      },
    );
  }

  Widget _buildErrorState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Categories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGuideCardItem {
  const _InfoGuideCardItem({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class DocumentsGuideScreen extends StatelessWidget {
  const DocumentsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    const docs = <String>[
      'Aadhaar Card / Voter ID / Passport',
      'PAN Card (mandatory for most loans)',
      'Address Proof (utility bill/rent agreement)',
      'Income Proof (salary slips or ITR)',
      'Bank Statement (last 3 to 6 months)',
      'Passport-size photo',
      'Business proof (for business loan, if applicable)',
    ];

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Documents Guide'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: themeProvider.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: themeProvider.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline, color: Color(0xFF1E3A5F), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    docs[index],
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.textPrimary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoanGuidenceScreen extends StatelessWidget {
  const LoanGuidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Loan Guidance'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _loanGuideSection(
              context,
              title: '📘 Loan Guide',
              points: const [
                'Loans are an important part of modern financial life. Whether it is for personal needs, education, or business, understanding how loans work helps you make better financial decisions.',
                'This guide explains everything in a simple, safe, and educational way.',
              ],
              headerGradient: const [Color(0xFF1E3A5F), Color(0xFF2C5F8D)],
              headerTextColor: Colors.white,
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '💰 What is a Loan?',
              points: const [
                'A loan is an amount of money that you borrow from a bank, financial institution, or lender with the agreement to repay it over time, usually with interest.',
                'In simple terms: You take money now and repay it later in installments.',
                'Key features: Principal amount, repayment period, interest charges, and monthly EMI.',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '📊 What is Interest Rate?',
              points: const [
                'The interest rate is the cost of borrowing money, expressed as a percentage of the loan amount.',
                'Example: If you take ₹10,000 loan at 10% interest, you pay extra ₹1,000 as interest.',
                'Fixed rate: same during tenure, EMI constant.',
                'Floating rate: changes with market, EMI may increase/decrease.',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '🧮 What is EMI (Equated Monthly Installment)?',
              points: const [
                'EMI is the fixed amount you pay every month to repay your loan.',
                'It includes principal + interest.',
                'EMI depends on loan amount, interest rate, and tenure.',
                'Higher tenure = lower EMI (but higher total interest).',
                'Lower tenure = higher EMI (but lower total interest).',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '🔐 Secured vs Unsecured Loan',
              points: const [
                'Secured Loan: requires collateral (home, car, gold). Lower rates, higher amount, asset risk on default.',
                'Unsecured Loan: no collateral (personal loan, credit card loan). Higher rates, lower amount, approval depends on income and credit score.',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '⚖️ Secured vs Unsecured (Comparison)',
              child: _loanComparisonTable(context),
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '⚠️ Before Taking a Loan',
              points: const [
                'Check your repayment ability.',
                'Understand total interest payable.',
                'Avoid unnecessary borrowing.',
                'Compare multiple lenders.',
                'Read all terms and conditions carefully.',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '📉 Common Mistakes to Avoid',
              points: const [
                'Missing EMI payments.',
                'Taking multiple loans at once.',
                'Ignoring interest rates.',
                'Not reading loan terms.',
              ],
            ),
            const SizedBox(height: 12),
            _loanGuideSection(
              context,
              title: '🛡️ Disclaimer (For App Safety)',
              points: const [
                'This content is provided for educational and informational purposes only.',
                'We do not provide loans or financial services.',
                'Users should verify details with official banks or financial institutions before making any financial decision.',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanGuideSection(
    BuildContext context, {
    required String title,
    List<String>? points,
    Widget? child,
    List<Color>? headerGradient,
    Color? headerTextColor,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isHeader = headerGradient != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHeader ? null : themeProvider.cardBackground,
        gradient: isHeader
            ? LinearGradient(
                colors: headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(12),
        border: isHeader ? null : Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: headerTextColor ?? themeProvider.textPrimary,
            ),
          ),
          if (points != null) ...[
            const SizedBox(height: 10),
            ...points.map(
              (point) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: headerTextColor ?? themeProvider.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: headerTextColor ?? themeProvider.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 10),
            child,
          ],
        ],
      ),
    );
  }

  Widget _loanComparisonTable(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final rows = <Map<String, String>>[
      {
        'feature': 'Collateral',
        'secured': 'Required',
        'unsecured': 'Not required',
      },
      {
        'feature': 'Interest Rate',
        'secured': 'Low',
        'unsecured': 'High',
      },
      {
        'feature': 'Risk',
        'secured': 'Asset risk',
        'unsecured': 'No asset risk',
      },
      {
        'feature': 'Approval',
        'secured': 'Easier',
        'unsecured': 'Depends on credit score',
      },
    ];

    return Table(
      border: TableBorder.all(color: themeProvider.borderColor),
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.2),
      },
      children: [
        const TableRow(
          decoration: BoxDecoration(color: Color(0xFFEAF2FF)),
          children: [
            _LoanGuideTableCell('Feature', isHeader: true),
            _LoanGuideTableCell('Secured Loan', isHeader: true),
            _LoanGuideTableCell('Unsecured Loan', isHeader: true),
          ],
        ),
        ...rows.map(
          (row) => TableRow(
            children: [
              _LoanGuideTableCell(row['feature']!),
              _LoanGuideTableCell(row['secured']!),
              _LoanGuideTableCell(row['unsecured']!),
            ],
          ),
        ),
      ],
    );
  }
}

class PersonalLoanInfoScreen extends StatelessWidget {
  const PersonalLoanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Personal Loan Info'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _personalLoanSection(
              context,
              title: '📌 What is a Personal Loan?',
              points: const [
                'A Personal Loan is a type of unsecured loan that you can use for your personal needs such as medical expenses, travel, education, or emergencies.',
                'In simple words: You borrow money without giving any collateral and repay it in monthly installments (EMIs).',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '💡 Key Features of Personal Loan',
              points: const [
                'No collateral required',
                'Quick processing (depending on lender)',
                'Fixed repayment tenure',
                'Flexible usage (no restriction on purpose)',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📊 Personal Loan Interest Rate',
              points: const [
                'Personal loans usually have higher interest rates compared to secured loans because no asset is provided.',
                'Typical range (India): 10% – 36% per year (depends on profile).',
                'Factors affecting interest rate: Credit score, income level, job stability, existing loans.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '🧮 Personal Loan EMI (How You Repay)',
              points: const [
                'You repay the loan through EMIs (Equated Monthly Installments).',
                'EMI includes principal amount and interest.',
                'EMI depends on loan amount, interest rate, and loan tenure.',
                'Longer tenure = lower EMI but higher total interest.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📋 Eligibility Criteria (General)',
              points: const [
                'Age: 18–60 years',
                'Stable income source',
                'Good credit score (650+ recommended)',
                'Valid ID and address proof',
                'Criteria may vary depending on lender.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📄 Documents Required',
              points: const [
                'Identity proof (Aadhaar, PAN)',
                'Address proof',
                'Income proof (salary slip / bank statement)',
                'Employment details',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📈 Benefits of Personal Loan',
              points: const [
                'No need to pledge assets',
                'Can be used for any purpose',
                'Fast approval process',
                'Fixed repayment plan',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '⚠️ Risks & Things to Be Careful About',
              points: const [
                'Higher interest rates',
                'Late payment penalties',
                'Impact on credit score if EMI is missed',
                'Hidden charges (processing fee, etc.)',
                'Always read terms carefully before taking a loan.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📉 Common Mistakes to Avoid',
              points: const [
                'Borrowing more than needed',
                'Ignoring interest rates',
                'Missing EMI payments',
                'Applying to multiple lenders at once',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '📊 Example (Simple Understanding)',
              points: const [
                'Suppose you take: Loan ₹50,000, Interest 12% per year, Tenure 12 months.',
                'You will pay a fixed EMI every month until the loan is fully repaid.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '🛡️ Important Disclaimer (Very Important)',
              points: const [
                'This content is provided for educational purposes only.',
                'We do not provide personal loans, lending services, or financial products.',
                'Users should always verify details with official banks or financial institutions before making any decision.',
              ],
            ),
            const SizedBox(height: 12),
            _personalLoanSection(
              context,
              title: '✅ Final Conclusion',
              points: const [
                'A personal loan can be helpful in emergencies and important situations, but it should be used responsibly.',
              ],
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _personalLoanSection(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool isHighlight = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isHighlight ? Colors.white : themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: isHighlight ? Colors.white : themeProvider.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isHighlight ? Colors.white.withOpacity(0.95) : themeProvider.textSecondary,
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

class HomeLoanInfoScreen extends StatelessWidget {
  const HomeLoanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Home Loan Info'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _homeLoanSection(
              context,
              title: '📌 What is a Home Loan?',
              points: const [
                'A Home Loan is a type of secured loan that is taken to purchase, construct, or renovate a house.',
                'In simple words: You borrow money from a bank to buy a home and repay it in EMIs over a fixed period.',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '🔐 Key Features of Home Loan',
              points: const [
                'Secured loan (property is used as collateral)',
                'Long repayment tenure (up to 30 years)',
                'Lower interest rate compared to personal loan',
                'Large loan amount available',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '💰 Home Loan Interest Rate',
              points: const [
                'Home loans usually have lower interest rates than personal loans.',
                'Typical range (India): 8% – 10.5% per year (approx.).',
                'Fixed Interest Rate: EMI remains constant; no change with market.',
                'Floating Interest Rate: changes with RBI repo rate; EMI may increase or decrease.',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '🧮 Home Loan EMI (Repayment System)',
              points: const [
                'You repay your home loan in monthly EMIs.',
                'EMI includes principal (loan amount) and interest.',
                'EMI depends on loan amount, interest rate, and tenure.',
                'Longer tenure = lower EMI but more total interest.',
                'Shorter tenure = higher EMI but less interest.',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '📋 Eligibility Criteria',
              points: const [
                'Age: 21–65 years',
                'Stable income (job or business)',
                'Good credit score (700+ recommended)',
                'Property documents',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '📄 Documents Required',
              points: const [
                'Identity proof (Aadhaar, PAN)',
                'Address proof',
                'Income proof (salary slips / ITR)',
                'Bank statements',
                'Property papers',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '📈 Benefits of Home Loan',
              points: const [
                'Helps you own a house',
                'Lower interest rate',
                'Tax benefits under income tax laws',
                'Long repayment flexibility',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '⚠️ Risks & Things to Consider',
              points: const [
                'Long-term financial commitment',
                'Interest rate changes (floating loans)',
                'Penalty for late EMI',
                'Property can be seized if not repaid',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '📉 Common Mistakes to Avoid',
              points: const [
                'Taking loan beyond your capacity',
                'Ignoring hidden charges',
                'Not checking property documents',
                'Choosing wrong tenure',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '📊 Example (Simple Understanding)',
              points: const [
                'Suppose you take: Loan ₹20,00,000, Interest 8.5% per year, Tenure 20 years.',
                'You will pay a fixed EMI every month for 20 years until the loan is fully repaid.',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '🛡️ Important Disclaimer (Very Important)',
              points: const [
                'This content is provided for educational and informational purposes only.',
                'We do not provide home loans or financial services.',
                'Users should verify details with official banks or financial institutions before making any financial decisions.',
              ],
            ),
            const SizedBox(height: 12),
            _homeLoanSection(
              context,
              title: '✅ Final Conclusion',
              points: const [
                'A home loan is one of the biggest financial decisions in life.',
              ],
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeLoanSection(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool isHighlight = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isHighlight ? Colors.white : themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: isHighlight ? Colors.white : themeProvider.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isHighlight ? Colors.white.withOpacity(0.95) : themeProvider.textSecondary,
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

class BusinessLoanInfoScreen extends StatelessWidget {
  const BusinessLoanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Business Loan Guidance'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _businessLoanSection(
              context,
              title: '📌 What is a Business Loan?',
              points: const [
                'A Business Loan is a type of loan taken to start, manage, or expand a business.',
                'In simple words: You borrow money to grow your business and repay it in installments over time.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '💼 Types of Business Loans',
              points: const [
                'Term Loan: Fixed amount borrowed and repaid in EMIs over a fixed period.',
                'Working Capital Loan: Used for daily business expenses and cash flow.',
                'Equipment Loan: Used to purchase machinery or equipment.',
                'MSME Loan: Special loans for small and medium businesses.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '🔐 Secured vs Unsecured Business Loan',
              points: const [
                'Secured Business Loan: Requires collateral (property/assets), lower interest, higher loan amount.',
                'Unsecured Business Loan: No collateral, higher interest, based on business performance.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '💰 Business Loan Interest Rate',
              points: const [
                'Interest rates vary based on risk and profile.',
                'Typical range (India): 10% – 24% per year (approx.).',
                'Factors: Business income, credit score, business stability, loan amount and tenure.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '🧮 Business Loan EMI (Repayment)',
              points: const [
                'You repay the loan through EMIs (monthly payments).',
                'EMI includes principal amount and interest.',
                'EMI depends on loan amount, interest rate, and tenure.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '📋 Eligibility Criteria',
              points: const [
                'Age: 21–65 years',
                'Running business (1–3 years old)',
                'Stable income',
                'Good credit score (650+ recommended)',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '📄 Documents Required',
              points: const [
                'Identity proof (Aadhaar, PAN)',
                'Address proof',
                'Business proof (GST, registration)',
                'Bank statements',
                'Income tax returns (ITR)',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '📈 Benefits of Business Loan',
              points: const [
                'Helps expand business',
                'Improves cash flow',
                'No need to use personal savings',
                'Flexible repayment options',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '⚠️ Risks & Things to Consider',
              points: const [
                'Interest cost',
                'EMI burden on business',
                'Risk of default',
                'Collateral risk (in secured loans)',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '📉 Common Mistakes to Avoid',
              points: const [
                'Taking loan without proper planning',
                'Ignoring interest rates',
                'Over-borrowing',
                'Not maintaining financial records',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '📊 Example (Simple Understanding)',
              points: const [
                'Suppose you take: Loan ₹5,00,000, Interest 15% per year, Tenure 3 years.',
                'You will pay fixed monthly EMIs until the loan is fully repaid.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '🛡️ Important Disclaimer (Very Important)',
              points: const [
                'This content is provided for educational and informational purposes only.',
                'We do not provide business loans or financial services.',
                'Users should verify details with official banks or financial institutions before making any decisions.',
              ],
            ),
            const SizedBox(height: 12),
            _businessLoanSection(
              context,
              title: '✅ Final Conclusion',
              points: const [
                'A business loan can help you grow and scale your business, but it should be used wisely.',
              ],
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _businessLoanSection(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool isHighlight = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isHighlight ? Colors.white : themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: isHighlight ? Colors.white : themeProvider.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isHighlight ? Colors.white.withOpacity(0.95) : themeProvider.textSecondary,
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

class EducationLoanInfoScreen extends StatelessWidget {
  const EducationLoanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Education Loan Guidance'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _educationLoanSection(
              context,
              title: '📌 What is an Education Loan?',
              points: const [
                'An Education Loan is a type of loan taken to cover the cost of education, such as tuition fees, books, accommodation, and other study-related expenses.',
                'In simple words: You borrow money to study now and repay it after completing your education.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '🎯 Purpose of Education Loan',
              points: const [
                'College or university fees',
                'Books and study materials',
                'Hostel or accommodation',
                'Travel expenses (for abroad studies)',
                'Other academic costs',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '🔐 Secured vs Unsecured Education Loan',
              points: const [
                'Secured Education Loan: Requires collateral (property, FD, etc.), lower interest rate, higher loan amount.',
                'Unsecured Education Loan: No collateral required, higher interest rate, based on student/parent income.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '💰 Education Loan Interest Rate',
              points: const [
                'Interest rates depend on the lender and profile.',
                'Typical range (India): 8% – 15% per year (approx.).',
                'Factors affecting interest: course type, college/university, credit profile of applicant/co-applicant, and loan amount.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '⏳ Moratorium Period (Special Feature)',
              points: const [
                'Moratorium Period = time when you do not need to repay EMI.',
                'Usually course duration + 6 to 12 months.',
                'EMI starts after completion of studies.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '🧮 Education Loan EMI (Repayment)',
              points: const [
                'After moratorium period, you repay through EMIs.',
                'EMI includes principal amount and interest.',
                'EMI depends on loan amount, interest rate, and repayment tenure.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '📋 Eligibility Criteria',
              points: const [
                'Indian citizen',
                'Confirmed admission in recognized institution',
                'Co-applicant (parent/guardian) usually required',
                'Basic financial stability',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '📄 Documents Required',
              points: const [
                'Identity proof (Aadhaar, PAN)',
                'Address proof',
                'Admission letter',
                'Fee structure',
                'Academic records',
                'Income proof of co-applicant',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '📈 Benefits of Education Loan',
              points: const [
                'Helps achieve higher education goals',
                'Flexible repayment options',
                'Moratorium period available',
                'Tax benefits under income tax laws',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '⚠️ Risks & Things to Consider',
              points: const [
                'Interest accumulation during study period',
                'Repayment pressure after course',
                'Impact on credit score if EMI is missed',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '📉 Common Mistakes to Avoid',
              points: const [
                'Borrowing more than required',
                'Not checking interest rates',
                'Ignoring repayment terms',
                'Choosing unrecognized institutions',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '📊 Example (Simple Understanding)',
              points: const [
                'Suppose you take: Loan ₹3,00,000, Interest 10% per year, Course 3 years.',
                'EMI repayment will start after course completion + moratorium period.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '🛡️ Important Disclaimer (Very Important)',
              points: const [
                'This content is provided for educational and informational purposes only.',
                'We do not provide education loans or financial services.',
                'Users should verify details with official banks or financial institutions before making any decisions.',
              ],
            ),
            const SizedBox(height: 12),
            _educationLoanSection(
              context,
              title: '✅ Final Conclusion',
              points: const [
                'An education loan is a great way to invest in your future, but it should be used wisely.',
              ],
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _educationLoanSection(
    BuildContext context, {
    required String title,
    required List<String> points,
    bool isHighlight = false,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? const Color(0xFF1E3A5F) : themeProvider.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isHighlight ? Colors.white : themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: isHighlight ? Colors.white : themeProvider.textPrimary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        color: isHighlight ? Colors.white.withOpacity(0.95) : themeProvider.textSecondary,
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

class _LoanGuideTableCell extends StatelessWidget {
  final String text;
  final bool isHeader;

  const _LoanGuideTableCell(this.text, {this.isHeader = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          color: isHeader ? const Color(0xFF1E3A5F) : themeProvider.textPrimary,
        ),
      ),
    );
  }
}


