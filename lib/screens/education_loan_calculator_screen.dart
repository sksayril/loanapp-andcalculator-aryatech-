import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/services/ad_helper.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';

class EducationLoanCalculatorScreen extends StatefulWidget {
  const EducationLoanCalculatorScreen({super.key});

  @override
  State<EducationLoanCalculatorScreen> createState() => _EducationLoanCalculatorScreenState();
}

class _EducationLoanCalculatorScreenState extends State<EducationLoanCalculatorScreen> {
  double _loanAmount = 200000; // Default ₹2,00,000
  int _tenureMonths = 24; // Default 24 months
  double _interestRate = 9.5; // Default 9.5% p.a.
  
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

  // Show Rewarded Ad and Navigate
  Future<void> _showRewardedAdAndNavigate() async {
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
                MaterialPageRoute(
                  builder: (context) => const LoanListingScreen(
                    loanType: 'Education Loan',
                    amountRange: 'All amounts',
                    primaryColor: Color(0xFF00BFA5),
                  ),
                ),
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
            MaterialPageRoute(
              builder: (context) => const LoanListingScreen(
                loanType: 'Education Loan',
                amountRange: 'All amounts',
                primaryColor: Color(0xFF00BFA5),
              ),
            ),
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
                  MaterialPageRoute(
                    builder: (context) => const LoanListingScreen(
                      loanType: 'Education Loan',
                      amountRange: 'All amounts',
                      primaryColor: Color(0xFF00BFA5),
                    ),
                  ),
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
              MaterialPageRoute(
                builder: (context) => const LoanListingScreen(
                  loanType: 'Education Loan',
                  amountRange: 'All amounts',
                  primaryColor: Color(0xFF00BFA5),
                ),
              ),
            );
          }
        }
      } else {
        print('⚠ Could not load ad, navigating without ad');
        // Navigate even if ad fails to load
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoanListingScreen(
                loanType: 'Education Loan',
                amountRange: 'All amounts',
                primaryColor: Color(0xFF00BFA5),
              ),
            ),
          );
        }
      }
    }
  }

  double _calculateEMI() {
    if (_tenureMonths == 0 || _interestRate == 0) return 0;
    
    final monthlyRate = _interestRate / 12 / 100;
    final tenure = _tenureMonths.toDouble();
    
    final emi = _loanAmount *
        monthlyRate *
        pow(1 + monthlyRate, tenure) /
        (pow(1 + monthlyRate, tenure) - 1);
    
    return emi.isFinite ? emi : 0;
  }

  double _calculateTotalInterest() {
    final emi = _calculateEMI();
    final totalAmount = emi * _tenureMonths;
    return totalAmount - _loanAmount;
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹ ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹ ${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  String _formatCompactCurrency(double amount) {
    if (amount >= 100000) {
      return '₹ ${(amount / 100000).toStringAsFixed(2)}L';
    } else if (amount >= 1000) {
      return '₹ ${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹ ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final emi = _calculateEMI();
    final totalInterest = _calculateTotalInterest();
    final totalAmount = _loanAmount + totalInterest;

    return Scaffold(
      backgroundColor: themeProvider.themeMode == ThemeMode.dark
          ? themeProvider.backgroundColor
          : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Education Loan Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Amount Section
              _buildSectionHeader('Loan Amount', _formatCurrency(_loanAmount), themeProvider),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00BFA5),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.white,
                  thumbShape: const _CustomSliderThumb(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _loanAmount,
                  min: 50000,
                  max: 2000000,
                  divisions: 39,
                  onChanged: (value) {
                    setState(() {
                      _loanAmount = value;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹50K',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                  Text(
                    '₹20L',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Tenure Section
              _buildSectionHeader('Tenure', '$_tenureMonths Months', themeProvider),
              const SizedBox(height: 12),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF00BFA5),
                  inactiveTrackColor: Colors.grey.shade300,
                  thumbColor: Colors.white,
                  thumbShape: const _CustomSliderThumb(
                    enabledThumbRadius: 10,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 20,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _tenureMonths.toDouble(),
                  min: 12,
                  max: 60,
                  divisions: 48,
                  onChanged: (value) {
                    setState(() {
                      _tenureMonths = value.toInt();
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '12M',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                  Text(
                    '60M',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Monthly EMI Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: themeProvider.themeMode == ThemeMode.dark
                      ? themeProvider.cardBackground
                      : Colors.white,
                ),
                child: Column(
                  children: [
                    Text(
                      'YOUR MONTHLY EMI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _formatCompactCurrency(emi),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BFA5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total Interest Payable: ${_formatCurrency(totalInterest)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Credit Profile Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Excellent Credit Profile!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Feature Highlights
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildFeatureCard(
                    Icons.flash_on,
                    '2 Hour\nDisbursal',
                    themeProvider,
                  ),
                  _buildFeatureCard(
                    Icons.percent,
                    'Zero\nForeclosure',
                    themeProvider,
                  ),
                  _buildFeatureCard(
                    Icons.description_outlined,
                    'Minimal\nDocs',
                    themeProvider,
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Total Amount and Apply Now Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Apply Now Button (only show if isActive is true)
                    if (!_isCheckingApplyNow && _isApplyNowActive)
                      ElevatedButton(
                        onPressed: _showRewardedAdAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00BFA5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Apply Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String value, ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: themeProvider.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String text, ThemeProvider themeProvider) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00BFA5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: themeProvider.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Slider Thumb with border
class _CustomSliderThumb extends SliderComponentShape {
  final double enabledThumbRadius;

  const _CustomSliderThumb({
    required this.enabledThumbRadius,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    
    // Draw white circle with teal border
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final borderPaint = Paint()
      ..color = const Color(0xFF00BFA5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, enabledThumbRadius, paint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);
  }
}
