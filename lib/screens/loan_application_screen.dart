import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../live_data_screen.dart';
import '../services/ad_helper.dart';
import '../services/loan_api_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  int _currentStep = 1;
  bool _showResults = false;
  
  // Bank-specific Flow Variables
  bool _isBankFlow = false;
  int _bankStep = 1;
  String? _selectedBank;

  // Rewarded ad variables
  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoaded = false;
  bool _isAdLoading = false;
  bool _isAdNavigationInProgress = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _showRewardedAdAndStartFlow(String bankName) async {
    if (_isAdNavigationInProgress) return;
    _isAdNavigationInProgress = true;

    Future<void> presentRewardedAd(RewardedAd ad) async {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _isAdNavigationInProgress = false;
          _startBankFlow(bankName);
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (a, error) {
          a.dispose();
          _rewardedAd = null;
          _isRewardedAdLoaded = false;
          _isAdNavigationInProgress = false;
          _startBankFlow(bankName);
          _loadRewardedAd();
        },
      );

      try {
        await ad.show(onUserEarnedReward: (_, __) {});
      } catch (_) {
        _isAdNavigationInProgress = false;
        _startBankFlow(bankName);
        _loadRewardedAd();
      }
    }

    if (_rewardedAd != null && _isRewardedAdLoaded) {
      await presentRewardedAd(_rewardedAd!);
      return;
    }

    // If ad not loaded, try to load it while showing a loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final ad = await AdHelper.loadRewardedAd();
    if (!mounted) {
      _isAdNavigationInProgress = false;
      return;
    }
    Navigator.pop(context); // Close loader

    if (ad != null) {
      setState(() {
        _rewardedAd = ad;
        _isRewardedAdLoaded = true;
      });
      await presentRewardedAd(ad);
    } else {
      _isAdNavigationInProgress = false;
      _startBankFlow(bankName);
      _loadRewardedAd();
    }
  }

  // Bank Data
  final List<Map<String, String>> _banks = [
    {'name': 'SBI', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/SBI-logo.svg/3840px-SBI-logo.svg.png'},
    {'name': 'HDFC', 'logo': 'https://companieslogo.com/img/orig/HDB-bb6241fe.png?t=1720244492'},
    {'name': 'ICICI', 'logo': 'https://companieslogo.com/img/orig/IBN-af38b5c0.png?t=1720244492'},
    {'name': 'Axis', 'logo': 'https://companieslogo.com/img/orig/AXISBANK.BO-8f59e95b.png?t=1720244490'},
    {'name': 'Kotak', 'logo': 'https://companieslogo.com/img/orig/KOTAKBANK.NS-36440c5e.png?t=1720244492'},
    {'name': 'PNB', 'logo': 'https://static.toiimg.com/thumb/msid-74887573,width-400,resizemode-4/74887573.jpg'},
    {'name': 'BoB', 'logo': 'https://1000logos.net/wp-content/uploads/2021/06/Bank-of-Baroda-icon.png'},
    {'name': 'Canara', 'logo': 'https://companieslogo.com/img/orig/CANBK.NS-94324ae3.png?t=1720244491'},
    {'name': 'Union Bank', 'logo': 'https://companieslogo.com/img/orig/UNIONBANK.NS-5bba728d.png?t=1720244494'},
    {'name': 'IDFC FIRST', 'logo': 'https://companieslogo.com/img/orig/IDFCFIRSTB.NS-6c6b4306.png?t=1720244492'},
    {'name': 'IndusInd', 'logo': 'https://www.clipartmax.com/png/full/241-2415990_about-us-indusind-bank-ltd-logo.png'},
    {'name': 'Yes Bank', 'logo': 'https://upload.wikimedia.org/wikipedia/en/6/64/YESBANKLOGO.png'},
    {'name': 'Federal Bank', 'logo': 'https://www.federal.bank.in/documents/d/guest/federal-favicon-blue-1-'},
    {'name': 'Bandhan Bank', 'logo': 'https://i.pinimg.com/736x/9d/1c/43/9d1c433d8372320c2e4819ac25d67b69.jpg'},
    {'name': 'Bank of India', 'logo': 'https://companieslogo.com/img/orig/BANKINDIA.NS-e3d88e01.png?t=1720244490'},
    {'name': 'Indian Bank', 'logo': 'https://companieslogo.com/img/orig/INDIANB.NS-a686632c.png?t=1746790300'},
    {'name': 'IDBI', 'logo': 'https://companieslogo.com/img/orig/IDBI.NS-1e2d35e6.png?t=1745688100'},
    {'name': 'RBL Bank', 'logo': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTgS5UaLYIuJWZV9rbs9RM9yCdKRcJYkS_nA&s'},
    {'name': 'Karur Vysya', 'logo': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSq9pTtuy9ziKJiV8nJfGkgYemdhO3t-EZ0zw&s'},
    {'name': 'South Indian', 'logo': 'https://yt3.googleusercontent.com/ytc/AIdro_lvfHUfQp100dC6ErUGEex-prdFdYsvrc83_4y4qclMJA=s900-c-k-c0x00ffffff-no-rj'},
  ];

  // Bank Flow Options
  int? _bankCibilIndex;
  final List<String> _cibilScores = ['750+', '650 - 750', '550 - 650', 'I don\'t know'];

  int? _bankIncomeIndex;
  final List<String> _bankIncomes = ['₹10k - ₹25k', '₹25k - ₹50k', '₹50k - ₹1L', '₹1L+'];

  int? _bankRepayIndex;
  final List<String> _repayTenures = ['3 months', '6 months', '12 months', '24 months+'];

  int? _bankPurposeIndex;
  final List<String> _loanPurposes = ['To start a business', 'Personal expenses', 'Education', 'Emergency', 'Other'];
  
  // Step 1: Monthly Income
  int _selectedIncomeIndex = 1;
  final List<String> _incomeRanges = [
    'Below ₹10,000',
    '₹10,000 - ₹25,000',
    '₹25,000 - ₹50,000',
    '₹50,000 - ₹1,00,000',
    'Above ₹1,00,000',
  ];

  // Step 2: Employment Type
  int _selectedEmploymentIndex = 0;
  final List<String> _employmentTypes = ['Salaried', 'Self-Employed', 'Business Owner', 'Freelancer'];

  // Step 3: Age Group
  int _selectedAgeIndex = 1; 
  final List<String> _ageGroups = ['18-21', '22-30', '31-40', '41-50', '50+'];

  // Step 4: Residential Status
  int _selectedResidenceIndex = 0;
  final List<String> _residenceTypes = ['Owned', 'Rented', 'With Parents'];

  // Step 5: Existing Loan
  int _selectedLoanIndex = 1; 
  final List<String> _loanOptions = ['Yes', 'No'];

  void _startBankFlow(String bankName) {
    setState(() {
      _selectedBank = bankName;
      _isBankFlow = true;
      _bankStep = 1;
    });
  }

  void _nextStep() {
    if (_isBankFlow) {
      if (_bankStep < 4) {
        setState(() {
          _bankStep++;
        });
      } else {
        // Navigate directly to LiveDataScreen without popup
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LiveDataScreen()),
        );
      }
      return;
    }

    if (_currentStep < 5) {
      setState(() {
        _currentStep++;
      });
    } else {
      setState(() {
        _showResults = true;
      });
    }
  }

  void _previousStep() {
    if (_isBankFlow) {
      if (_bankStep > 1) {
        setState(() {
          _bankStep--;
        });
      } else {
        setState(() {
          _isBankFlow = false;
        });
      }
      return;
    }
    if (_showResults) {
      setState(() {
        _showResults = false;
      });
      return;
    }
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    String title = 'Loan Application';
    if (_isBankFlow) {
      title = _selectedBank ?? 'Bank Selection';
    } else if (_showResults) {
      title = 'Best Offers';
    }

    return Scaffold(
      backgroundColor: isDark ? themeProvider.backgroundColor : const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E3A5F), 
            fontWeight: FontWeight.bold, 
            fontSize: 20
          ),
        ),
        backgroundColor: isDark ? themeProvider.backgroundColor : const Color(0xFFF8F9FE),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E3A5F)),
          onPressed: _previousStep,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Colors.grey), onPressed: () {}),
        ],
      ),
      body: _isBankFlow 
          ? _buildBankSpecificFlow() 
          : (_showResults ? _buildResultsView() : _buildApplicationFlow()),
    );
  }

  Widget _buildApplicationFlow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $_currentStep of 5',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
              ),
              Text(
                '${(_currentStep * 20)}% Complete',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4CAF50)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _currentStep * 0.2,
              backgroundColor: const Color(0xFFE0E0E0),
              color: const Color(0xFF4CAF50),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 48),
          Expanded(
            child: _buildStepContent(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentStep == 5 ? const Color(0xFF00C853) : const Color(0xFF4358F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: (_currentStep == 5 ? Colors.green : const Color(0xFF4358F6)).withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentStep == 5 ? 'Check Eligibility' : 'Continue',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward, size: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🔥', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text(
                  'Best Offers',
                  style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: _banks.length,
              itemBuilder: (context, index) {
                return _buildBankCard(_banks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(Map<String, String> bank) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Image.network(
              bank['logo']!,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              },
              errorBuilder: (context, error, stackTrace) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, color: Color(0xFF1E3A5F), size: 30),
                  const SizedBox(height: 4),
                  const Text('Bank', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bank['name']!,
            style: const TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF1E3A5F),
              letterSpacing: 0.5
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 140,
            height: 42,
            child: ElevatedButton(
              onPressed: () => _showRewardedAdAndStartFlow(bank['name']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Check Now', 
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankSpecificFlow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildBankStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0, top: 16),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Next', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankStepContent() {
    switch (_bankStep) {
      case 1:
        return _buildBankQuestion(
          'What is your approximate CIBIL score?',
          _cibilScores,
          _bankCibilIndex,
          (index) => setState(() => _bankCibilIndex = index),
        );
      case 2:
        return _buildBankQuestion(
          'What is your monthly income?',
          _bankIncomes,
          _bankIncomeIndex,
          (index) => setState(() => _bankIncomeIndex = index),
          showCheckmark: true,
        );
      case 3:
        return _buildBankQuestion(
          'In how much time would you like to repay the loan?',
          _repayTenures,
          _bankRepayIndex,
          (index) => setState(() => _bankRepayIndex = index),
        );
      case 4:
        return _buildBankQuestion(
          'Why do you need the loan?',
          _loanPurposes,
          _bankPurposeIndex,
          (index) => setState(() => _bankPurposeIndex = index),
        );
      default:
        return Container();
    }
  }

  Widget _buildBankQuestion(String question, List<String> options, int? selectedIndex, Function(int) onTap, {bool showCheckmark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1E293B), 
            height: 1.2,
            letterSpacing: -0.5
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please select one option to continue.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 32),
        ...List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          return _buildBankFlowCard(options[index], isSelected, () => onTap(index), showCheckmark);
        }),
      ],
    );
  }

  Widget _buildBankFlowCard(String text, bool isSelected, VoidCallback onTap, bool showCheckmark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                  ? const Color(0xFF6366F1).withOpacity(0.1) 
                  : Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF334155),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildIncomeStep();
      case 2:
        return _buildGenericStep(
          'What is your employment type?',
          'This helps us verify your stability.',
          _employmentTypes,
          _selectedEmploymentIndex,
          (index) => setState(() => _selectedEmploymentIndex = index),
        );
      case 3:
        return _buildAgeStep();
      case 4:
        return _buildGenericStep(
          'What is your residential status?',
          'This helps us understand your living situation.',
          _residenceTypes,
          _selectedResidenceIndex,
          (index) => setState(() => _selectedResidenceIndex = index),
        );
      case 5:
        return _buildLoanStep();
      default:
        return Container();
    }
  }

  Widget _buildIncomeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Monthly income?',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1E293B), 
            height: 1.1,
            letterSpacing: -1.0
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This helps us find the most suitable loan offers tailored for your capacity.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _incomeRanges.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedIncomeIndex == index;
              return _buildSelectionCard(_incomeRanges[index], isSelected, () {
                setState(() => _selectedIncomeIndex = index);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your age group?',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1E293B), 
            height: 1.1,
            letterSpacing: -1.0
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Age is a key factor in determining your loan tenure and interest rates.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: List.generate(_ageGroups.length, (index) {
            final isSelected = _selectedAgeIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedAgeIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? const Color(0xFF6366F1).withOpacity(0.1) 
                        : Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _ageGroups[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF475569),
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle, color: Color(0xFF6366F1), size: 18),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildLoanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Existing loans?',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1E293B), 
            height: 1.1,
            letterSpacing: -1.0
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Understanding your current commitments helps in providing a realistic offer.',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        ...List.generate(_loanOptions.length, (index) {
          final isSelected = _selectedLoanIndex == index;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLoanIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected 
                        ? const Color(0xFF6366F1).withOpacity(0.1) 
                        : Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Center(child: Icon(Icons.check, color: Colors.white, size: 16))
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _loanOptions[index],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const Spacer(),
        Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildBadge('100% Free'),
              _buildBadge('No CIBIL Impact'),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_box, color: Color(0xFF4CAF50), size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E3A5F))),
        ],
      ),
    );
  }

  Widget _buildGenericStep(String title, String subtitle, List<String> options, int selectedIndex, Function(int) onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.w900, 
            color: Color(0xFF1E293B), 
            height: 1.2,
            letterSpacing: -0.5
          ),
        ),
        const SizedBox(height: 12),
        Text(
          subtitle,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.4),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return _buildSelectionCard(options[index], isSelected, () => onTap(index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard(String text, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                  ? const Color(0xFF6366F1).withOpacity(0.1) 
                  : Colors.black.withOpacity(0.02),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF334155),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
