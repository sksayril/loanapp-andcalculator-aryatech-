import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:provider/provider.dart';
// Ad imports
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:emi_calculatornew/services/ad_helper.dart';

class CibilScoreScreen extends StatefulWidget {
  const CibilScoreScreen({super.key});

  @override 
  State<CibilScoreScreen> createState() => _CibilScoreScreenState();
}

class _CibilScoreScreenState extends State<CibilScoreScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _panController = TextEditingController();
  final _dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double _cibilScore = 0;
  bool _showScore = false;
  bool _isLoading = false;
  bool _showEligibility = false;
  bool _controllersInitialized = false;
  
  AnimationController? _loaderController;
  AnimationController? _scoreController;
  Animation<double>? _scoreAnimation;
  
  // Ad related variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isAdLoading = false;
  bool _scoreCheckInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // Load rewarded ad on init
    _loadRewardedAd();
  }

  void _initializeControllers() {
    if (!_controllersInitialized) {
      _loaderController = AnimationController(
        duration: const Duration(seconds: 5),
        vsync: this,
      );
      _scoreController = AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      );
      _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _scoreController!, curve: Curves.easeOutBack),
      );
      _controllersInitialized = true;
    }
  }

  // Load Rewarded Ad
  Future<void> _loadRewardedAd() async {
    if (_isAdLoading) return;
    
    setState(() {
      _isAdLoading = true;
    });
    
    print('→ Starting to load rewarded ad...');
    _rewardedAd = await AdHelper.loadRewardedAd();
    
    if (_rewardedAd != null && mounted) {
      setState(() {
        _isRewardedAdLoaded = true;
        _isAdLoading = false;
      });
      
      print('✓ Rewarded ad is ready to show');
      
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

  // Load Banner Ad (COMMENTED OUT)
  /* void _loadBannerAd() {
    print('→ Starting to load banner ad...');
    _bannerAd = AdHelper.loadBannerAd(
      onAdLoaded: (ad) {
        print('✓ Banner ad loaded successfully');
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (error) {
        print('✗ Banner ad failed to load: ${error.message}');
        print('  Code: ${error.code}, Domain: ${error.domain}');
        if (mounted) {
          setState(() {
            _isBannerAdLoaded = false;
          });
        }
      },
      adSize: AdSize.banner,
    );
  } */

  // Show confirmation dialog before rewarded ad (COMMENTED OUT)
  /* Future<void> _showRewardedAdConfirmationDialog() async {
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
                    _showRewardedAdAndCheckScore();
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

  // Show Rewarded Ad and then check score
  Future<void> _showRewardedAdAndCheckScore() async {
    // Prevent multiple simultaneous score checks
    if (_scoreCheckInProgress) {
      print('⚠ Score check already in progress, ignoring request');
      return;
    }
    
    print('→ Attempting to show rewarded ad...');
    print('  Ad loaded: $_isRewardedAdLoaded');
    print('  Ad object: ${_rewardedAd != null}');
    
    if (_rewardedAd != null && _isRewardedAdLoaded) {
      print('✓ Showing rewarded ad now');
      
      // Set up callback to handle ad dismissal
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
          // Check score after ad is dismissed (if not already triggered)
          if (!_scoreCheckInProgress && mounted) {
            _scoreCheckInProgress = true;
            _performScoreCheck();
          }
          _loadRewardedAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('✗ Rewarded ad failed to show: ${error.message}');
          ad.dispose();
          setState(() {
            _isRewardedAdLoaded = false;
          });
          // Check score even if ad fails to show
          if (!_scoreCheckInProgress && mounted) {
            _scoreCheckInProgress = true;
            _performScoreCheck();
          }
          _loadRewardedAd(); // Load next ad
        },
        onAdImpression: (ad) {
          print('Rewarded ad impression');
        },
      );
      
      try {
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('✓ User earned reward: ${reward.amount} ${reward.type}');
            // Check score after user watches the ad
            if (!_scoreCheckInProgress && mounted) {
              _scoreCheckInProgress = true;
              _performScoreCheck();
            }
          },
        );
      } catch (e) {
        print('✗ Error showing rewarded ad: $e');
        // If ad fails to show, check score anyway
        if (!_scoreCheckInProgress && mounted) {
          _scoreCheckInProgress = true;
          _performScoreCheck();
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
      _rewardedAd = await AdHelper.loadRewardedAd();
      
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();
      
      if (_rewardedAd != null && mounted) {
        setState(() {
          _isRewardedAdLoaded = true;
        });
        print('✓ Ad loaded on retry, showing now');
        
        // Set up callback
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
            // Check score after ad is dismissed
            if (!_scoreCheckInProgress && mounted) {
              _scoreCheckInProgress = true;
              _performScoreCheck();
            }
            _loadRewardedAd();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            print('✗ Rewarded ad failed to show: ${error.message}');
            ad.dispose();
            setState(() {
              _isRewardedAdLoaded = false;
            });
            // Check score even if ad fails
            if (!_scoreCheckInProgress && mounted) {
              _scoreCheckInProgress = true;
              _performScoreCheck();
            }
            _loadRewardedAd();
          },
          onAdImpression: (ad) {
            print('Rewarded ad impression');
          },
        );
        
        try {
          await _rewardedAd!.show(
            onUserEarnedReward: (ad, reward) {
              print('✓ User earned reward: ${reward.amount} ${reward.type}');
              // Check score after user watches the ad
              if (!_scoreCheckInProgress && mounted) {
                _scoreCheckInProgress = true;
                _performScoreCheck();
              }
            },
          );
        } catch (e) {
          print('✗ Error showing rewarded ad on retry: $e');
          if (!_scoreCheckInProgress && mounted) {
            _scoreCheckInProgress = true;
            _performScoreCheck();
          }
        }
      } else {
        print('⚠ Could not load ad, proceeding without ad');
        if (!_scoreCheckInProgress && mounted) {
          _scoreCheckInProgress = true;
          _performScoreCheck();
        }
      }
    }
  }

  void _performScoreCheck() async {
    // Reset the flag when starting score check
    _scoreCheckInProgress = true;
    
    setState(() {
      _isLoading = true;
      _showScore = false;
      _showEligibility = false;
      // Generate a random score between 650 and 850
      _cibilScore = Random().nextInt(850 - 650 + 1) + 650;
    });

    // Ensure controllers are initialized
    _initializeControllers();
    
    // Start loader animation
    _loaderController?.reset();
    _loaderController?.forward();

    // Wait for 5 seconds (loader cannot be skipped)
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _showScore = true;
      });
      
      // Animate score meter
      _scoreController?.reset();
      _scoreController?.forward();
      
      // Show eligibility after score animation
      await Future.delayed(const Duration(milliseconds: 2500));
      
      if (mounted) {
        setState(() {
          _showEligibility = true;
          _scoreCheckInProgress = false; // Reset flag when score check is complete
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _panController.dispose();
    _dobController.dispose();
    _loaderController?.dispose();
    _scoreController?.dispose();
    // Ad disposal
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _checkCibilScore() {
    if (_formKey.currentState!.validate()) {
      // Show rewarded ad before checking score
      _showRewardedAdAndCheckScore();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A5F),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  String _getScoreCategory(double score) {
    if (score < 630) return 'Poor';
    if (score < 690) return 'Fair';
    if (score < 780) return 'Good';
    return 'Excellent';
  }

  Color _getScoreColor(double score) {
    if (score < 630) return Colors.red;
    if (score < 690) return Colors.orange;
    if (score < 780) return Colors.amber;
    return Colors.green;
  }

  String _getScoreDescription(double score) {
    if (score < 630) return 'Your credit score needs improvement. Focus on paying bills on time and reducing debt.';
    if (score < 690) return 'Your credit score is fair. Continue making timely payments to improve it further.';
    if (score < 780) return 'Good credit score! You\'re eligible for most loans with competitive interest rates.';
    return 'Excellent credit score! You qualify for the best loan offers and lowest interest rates.';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return PopScope(
      canPop: true,
      child: Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
          'CIBIL Score Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0B7D3B), Color(0xFF14A44D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '🟢 CIBIL Score Guide: Complete Beginner to Advanced Guide',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _guideSection(
              title: '📌 What is a CIBIL Score?',
              points: const [
                'A CIBIL Score is a 3-digit number ranging from 300 to 900 that represents your creditworthiness (how likely you are to repay a loan on time).',
                'It is calculated by TransUnion CIBIL based on your credit history and financial behavior.',
                'Higher score = Higher chances of loan approval.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '📊 CIBIL Score Range Explained',
              child: _scoreRangeTable(themeProvider),
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '🧠 Why is CIBIL Score Important?',
              points: const [
                'Loan approval (Personal, Home, Car loans)',
                'Credit card eligibility',
                'Interest rate (lower score = higher interest)',
                'Credit limit approval',
                'Banks and NBFCs use this score before approving any credit.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '⚙️ How is CIBIL Score Calculated?',
              points: const [
                '1) Payment History (35%): On-time EMI/credit card payment improves your score.',
                '2) Credit Utilization (30%): Keep usage below 30%.',
                '3) Credit History Length (15%): Older history helps.',
                '4) Credit Mix (10%): Mix of secured/unsecured credit is good.',
                '5) New Credit Inquiries (10%): Too many applications hurt the score.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '📉 What Affects Your CIBIL Score Negatively?',
              points: const [
                'Missing EMI payments',
                'High credit card usage',
                'Applying for multiple loans at once',
                'Loan default or settlement',
                'Closing old credit accounts early',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '📈 How to Improve Your CIBIL Score?',
              points: const [
                'Pay on time: Always pay EMIs and bills before due date.',
                'Maintain low utilization: Keep usage below 30%.',
                'Avoid multiple loan applications.',
                'Keep old accounts active.',
                'Check credit report for errors and correct them.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '🔍 How to Check Your CIBIL Score?',
              points: const [
                'Official credit bureaus',
                'Banking apps',
                'Financial platforms',
                'Always use trusted and secure platforms.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '⚠️ Common Myths About CIBIL Score',
              points: const [
                'Myth: Checking your own score reduces it. Truth: It does NOT affect your score.',
                'Myth: High income means high score. Truth: Income is not directly related.',
                'Myth: No loan means good score. Truth: No credit history can mean no score.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '📌 Minimum CIBIL Score Required for Loan',
              points: const [
                'Personal Loan: 700+ recommended',
                'Credit Card: 650+',
                'Home Loan: 750+ preferred',
                'Different lenders may have different criteria.',
              ],
            ),
            const SizedBox(height: 12),
            _guideSection(
              title: '🛡️ Important Disclaimer (For App Safety)',
              points: const [
                'This app provides educational information only about CIBIL scores and credit management.',
                'We do not provide loans, credit cards, or financial services.',
                'Users are advised to verify details with official financial institutions before making decisions.',
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _guideSection({
    required String title,
    List<String>? points,
    Widget? child,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: themeProvider.textPrimary,
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
                    const Text('• '),
                    Expanded(
                      child: Text(
                        point,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: themeProvider.textSecondary,
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

  Widget _scoreRangeTable(ThemeProvider themeProvider) {
    final rows = <Map<String, String>>[
      {'range': '750 – 900', 'rating': 'Excellent', 'meaning': 'Very high approval chances'},
      {'range': '700 – 749', 'rating': 'Good', 'meaning': 'Good chances'},
      {'range': '650 – 699', 'rating': 'Average', 'meaning': 'Moderate approval'},
      {'range': '550 – 649', 'rating': 'Poor', 'meaning': 'Low chances'},
      {'range': '300 – 549', 'rating': 'Very Poor', 'meaning': 'Very difficult to get a loan'},
    ];

    return Table(
      border: TableBorder.all(color: themeProvider.borderColor),
      columnWidths: const {
        0: FlexColumnWidth(1.3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1.7),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFEAF2FF)),
          children: [
            _tableCell('Score Range', isHeader: true),
            _tableCell('Rating', isHeader: true),
            _tableCell('Meaning', isHeader: true),
          ],
        ),
        ...rows.map(
          (row) => TableRow(
            children: [
              _tableCell(row['range']!),
              _tableCell(row['rating']!),
              _tableCell(row['meaning']!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: 16,
        color: Provider.of<ThemeProvider>(context, listen: false).textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textPrimary),
        hintStyle: TextStyle(color: Provider.of<ThemeProvider>(context, listen: false).textSecondary),
        prefixIcon: Icon(icon, color: const Color(0xFF1E3A5F)),
        filled: true,
        fillColor: Provider.of<ThemeProvider>(context, listen: false).cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Provider.of<ThemeProvider>(context, listen: false).borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Provider.of<ThemeProvider>(context, listen: false).borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    // Ensure controllers are initialized
    _initializeControllers();
    
    if (_loaderController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _loaderController!,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer rotating circle
                  Transform.rotate(
                    angle: _loaderController!.value * 2 * pi,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF1E3A5F).withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                      child: CircularProgressIndicator(
                        value: _loaderController!.value,
                        strokeWidth: 4,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A5F)),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                  // Inner pulsing circle
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1E3A5F).withOpacity(0.1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.credit_score,
                        size: 40,
                        color: const Color(0xFF1E3A5F).withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'Analyzing Your Credit Profile...',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Provider.of<ThemeProvider>(context).textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This may take a few seconds',
            style: TextStyle(
              fontSize: 14,
              color: Provider.of<ThemeProvider>(context).textSecondary,
            ),
          ),
          const SizedBox(height: 30),
          AnimatedBuilder(
            animation: _loaderController!,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _loaderController!.value,
                backgroundColor: Provider.of<ThemeProvider>(context).borderColor,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E3A5F)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSection() {
    // Ensure controllers are initialized
    _initializeControllers();
    
    if (_scoreAnimation == null) {
      return const SizedBox.shrink();
    }
    
    final scoreColor = _getScoreColor(_cibilScore);
    final category = _getScoreCategory(_cibilScore);
    
    return FadeTransition(
      opacity: _scoreAnimation!,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(_scoreAnimation!),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Score Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Your CIBIL Score',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Provider.of<ThemeProvider>(context).textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 350,
                      child: SfRadialGauge(
                        axes: <RadialAxis>[
                          RadialAxis(
                            minimum: 300,
                            maximum: 900,
                            startAngle: 180,
                            endAngle: 0,
                            radiusFactor: 0.85,
                            showLabels: true,
                            showTicks: true,
                            ranges: <GaugeRange>[
                              GaugeRange(
                                startValue: 300,
                                endValue: 629,
                                color: Colors.red.shade300,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                              GaugeRange(
                                startValue: 630,
                                endValue: 689,
                                color: Colors.orange.shade300,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                              GaugeRange(
                                startValue: 690,
                                endValue: 779,
                                color: Colors.amber.shade300,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                              GaugeRange(
                                startValue: 780,
                                endValue: 900,
                                color: Colors.green.shade300,
                                startWidth: 15,
                                endWidth: 15,
                              ),
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: _cibilScore,
                                enableAnimation: true,
                                animationDuration: 2000,
                                animationType: AnimationType.easeOutBack,
                                needleColor: scoreColor,
                                knobStyle: KnobStyle(
                                  color: scoreColor,
                                  borderColor: Colors.white,
                                  borderWidth: 3,
                                ),
                                needleLength: 0.8,
                                needleStartWidth: 1,
                                needleEndWidth: 5,
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                widget: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _cibilScore.toStringAsFixed(0),
                                      style: TextStyle(
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold,
                                        color: scoreColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: scoreColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: scoreColor.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: scoreColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                angle: 90,
                                positionFactor: 0.5,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: scoreColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: scoreColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: scoreColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _getScoreDescription(_cibilScore),
                              style: TextStyle(
                                fontSize: 13,
                                color: Provider.of<ThemeProvider>(context).textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
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

  Widget _buildEligibilitySection() {
    // Ensure controllers are initialized
    _initializeControllers();
    
    if (_scoreAnimation == null) {
      return const SizedBox.shrink();
    }
    
    return FadeTransition(
      opacity: _scoreAnimation!,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Loan Eligibility',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Provider.of<ThemeProvider>(context).textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildEligibilityCard(
              'Personal Loan',
              _cibilScore >= 700 ? 'Eligible' : 'Not Eligible',
              _cibilScore >= 700 ? Colors.green : Colors.red,
              _cibilScore >= 700
                  ? 'You qualify for personal loans up to ₹10 Lakhs'
                  : 'Improve your score to ₹700+ for personal loan eligibility',
              Icons.person,
            ),
            const SizedBox(height: 12),
            _buildEligibilityCard(
              'Home Loan',
              _cibilScore >= 750 ? 'Eligible' : 'Not Eligible',
              _cibilScore >= 750 ? Colors.green : Colors.red,
              _cibilScore >= 750
                  ? 'You qualify for home loans with competitive interest rates'
                  : 'Aim for ₹750+ score for better home loan offers',
              Icons.home,
            ),
            const SizedBox(height: 12),
            _buildEligibilityCard(
              'Car Loan',
              _cibilScore >= 680 ? 'Eligible' : 'Not Eligible',
              _cibilScore >= 680 ? Colors.green : Colors.red,
              _cibilScore >= 680
                  ? 'You qualify for car loans with attractive rates'
                  : 'Score of ₹680+ required for car loan approval',
              Icons.directions_car,
            ),
            const SizedBox(height: 12),
            _buildEligibilityCard(
              'Credit Card',
              _cibilScore >= 650 ? 'Eligible' : 'Not Eligible',
              _cibilScore >= 650 ? Colors.green : Colors.red,
              _cibilScore >= 650
                  ? 'You can apply for premium credit cards'
                  : 'Minimum ₹650 score needed for credit card approval',
              Icons.credit_card,
            ),
            const SizedBox(height: 24),
            // Tips Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E3A5F).withOpacity(0.1),
                    const Color(0xFF2C5F8D).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E3A5F).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tips to Improve Your Score',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem('Pay all bills and EMIs on time'),
                  _buildTipItem('Keep credit utilization below 30%'),
                  _buildTipItem('Maintain a healthy credit mix'),
                  _buildTipItem('Avoid multiple loan applications'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEligibilityCard(
    String loanType,
    String status,
    Color statusColor,
    String description,
    IconData icon,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      loanType,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: themeProvider.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 12),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Provider.of<ThemeProvider>(context).textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
