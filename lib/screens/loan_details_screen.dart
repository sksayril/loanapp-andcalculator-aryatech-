import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:emi_calculatornew/services/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

class LoanDetailsScreen extends StatefulWidget {
  final LoanApiData loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isAdLoading = false;
  
  // Apply Now button visibility
  bool _isApplyNowActive = false;
  bool _isCheckingApplyNow = true;

  @override
  void initState() {
    super.initState();
    // Load rewarded ad on init
    _loadRewardedAd();
    // Check Apply Now status
    _checkApplyNowStatus();
  }

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }

  // Load Rewarded Ad
  Future<void> _loadRewardedAd() async {
    if (_isAdLoading) return;
    
    setState(() {
      _isAdLoading = true;
    });
    
    print('→ Loading rewarded ad for Apply Now...');
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

  // Show Rewarded Ad and Launch URL
  Future<void> _showRewardedAdAndLaunchURL() async {
    print('→ Attempting to show rewarded ad...');
    print('  Ad loaded: $_isRewardedAdLoaded');
    print('  Ad object: ${_rewardedAd != null}');
    
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      print('✓ Showing rewarded ad now');
      
      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('✓ User earned reward: ${reward.amount} ${reward.type}');
            // Launch URL after user watches the ad
            if (mounted) {
              _launchURL(context, widget.loan.url);
            }
          },
        );
      } catch (e) {
        print('✗ Error showing rewarded ad: $e');
        // If ad fails to show, launch URL anyway
        if (mounted) {
          _launchURL(context, widget.loan.url);
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
              // Launch URL after user watches the ad
              if (mounted) {
                _launchURL(context, widget.loan.url);
              }
            },
          );
        } catch (e) {
          print('✗ Error showing rewarded ad on retry: $e');
          // If ad fails to show, launch URL anyway
          if (mounted) {
            _launchURL(context, widget.loan.url);
          }
        }
      } else {
        print('⚠ Could not load ad, launching URL without ad');
        // Launch URL even if ad fails to load
        if (mounted) {
          _launchURL(context, widget.loan.url);
        }
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
      // Default to showing button if API fails
      if (mounted) {
        setState(() {
          _isApplyNowActive = true;
          _isCheckingApplyNow = false;
        });
      }
    }
  }

  Future<void> _launchURL(BuildContext context, String? url) async {
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application link not available')),
        );
      }
      return;
    }
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open the link')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? themeProvider.backgroundColor
          : Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '${widget.loan.category?.name ?? 'Personal'} Loan - Details',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Loan Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? themeProvider.cardBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Bank Logo and Name
                  Row(
                    children: [
                      // Bank logo placeholder
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade100,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.blue.shade600,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Bank name and subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.loan.bankName ?? widget.loan.companyName ?? 'Bank Name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.loan.title ?? 'Instant Cash Loan',
                              style: TextStyle(
                                fontSize: 14,
                                color: themeProvider.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Key Features Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? themeProvider.cardBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Feature items
                  _buildFeatureItem(
                    context,
                    Icons.money,
                    'Loan Amount',
                    '₹50,000 up to ₹40 Lakhs',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.percent,
                    'Interest Rate',
                    'Starting from around ${widget.loan.interestRate ?? '10.50'}% per annum (may vary based on profile)',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.calendar_today,
                    'Tenure',
                    '12 months to 72 months',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.cancel_outlined,
                    'Collateral',
                    '❌ Not required',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.receipt_long,
                    'Processing Fee',
                    'Up to 2.5% of loan amount + GST',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.payment,
                    'Prepayment Charges',
                    'Applicable as per bank policy',
                    themeProvider,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Eligibility Criteria Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.themeMode == ThemeMode.dark
                    ? themeProvider.cardBackground
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Header
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Colors.blue.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Eligibility Criteria',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Eligibility items
                  _buildFeatureItem(
                    context,
                    Icons.person,
                    'Age',
                    '21 to 60 years',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.work_outline,
                    'Employment Type',
                    'Salaried or Self-Employed',
                    themeProvider,
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    context,
                    Icons.currency_rupee,
                    'Minimum Income',
                    'As per ${widget.loan.bankName ?? widget.loan.companyName ?? 'lender'} norms',
                    themeProvider,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Apply Now Button (only show if isActive is true)
            if (!_isCheckingApplyNow && _isApplyNowActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showRewardedAdAndLaunchURL,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.open_in_browser,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'APPLY NOW',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    ThemeProvider themeProvider,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
