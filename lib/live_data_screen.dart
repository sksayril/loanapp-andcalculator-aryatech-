import 'package:flutter/material.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:provider/provider.dart';
// import 'package:emi_calculatornew/services/ad_helper.dart'; // COMMENTED OUT - ADS DISABLED
// import 'package:google_mobile_ads/google_mobile_ads.dart'; // COMMENTED OUT - ADS DISABLED
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await LoanApiService.fetchCategoriesFromApi();
      
      if (mounted) {
        setState(() {
          final mappedCategories = categories.map((category) {
            final name = category.name ?? 'Unknown';
            final metadata = _categoryMetadata[name] ?? {
              'icon': Icons.account_balance_wallet_outlined,
              'interestRate': 'Contact for details',
              'processingTime': 'Varies',
              'color': Color(0xFF5E35B1),
            };
            
            return InstantLoanCategory(
              title: name,
              emoji: '', // Not used anymore
              subtitle: metadata['interestRate'] as String,
              color: metadata['color'] as Color,
              categoryId: category.id,
            );
          }).toList();

          mappedCategories.sort((a, b) {
            final aIndex = _desiredOrder.indexOf(a.title);
            final bIndex = _desiredOrder.indexOf(b.title);
            final safeA = aIndex == -1 ? _desiredOrder.length : aIndex;
            final safeB = bIndex == -1 ? _desiredOrder.length : bIndex;
            return safeA.compareTo(safeB);
          });

          _categories = mappedCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
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
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildLoanListCard(_categories[index]);
                    },
                  ),
      ),
    );
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


