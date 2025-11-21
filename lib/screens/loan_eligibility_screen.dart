import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/theme_provider.dart';

class LoanEligibilityScreen extends StatefulWidget {
  const LoanEligibilityScreen({super.key});

  @override
  State<LoanEligibilityScreen> createState() => _LoanEligibilityScreenState();
}

class _LoanEligibilityScreenState extends State<LoanEligibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _monthlyIncomeController = TextEditingController();
  final _monthlyExpensesController = TextEditingController();
  final _existingEmiController = TextEditingController();
  final _ageController = TextEditingController();
  final _workExperienceController = TextEditingController();
  
  String? _selectedLoanType;
  String? _selectedEmploymentType;
  
  bool _showResults = false;
  double _eligibleAmount = 0;
  double _maxEmi = 0;
  String _eligibilityStatus = '';
  MaterialColor _statusColor = Colors.green;
  
  final List<String> _loanTypes = [
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Education Loan',
    'Business Loan',
  ];
  
  final List<String> _employmentTypes = [
    'Salaried',
    'Self-Employed',
    'Business Owner',
    'Retired',
  ];

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _monthlyExpensesController.dispose();
    _existingEmiController.dispose();
    _ageController.dispose();
    _workExperienceController.dispose();
    super.dispose();
  }

  void _calculateEligibility() {
    if (_formKey.currentState!.validate() && 
        _selectedLoanType != null && 
        _selectedEmploymentType != null) {
      
      final monthlyIncome = double.parse(_monthlyIncomeController.text);
      final monthlyExpenses = double.parse(_monthlyExpensesController.text);
      final existingEmi = double.tryParse(_existingEmiController.text) ?? 0;
      final age = int.parse(_ageController.text);
      final workExp = int.tryParse(_workExperienceController.text) ?? 0;
      
      // Calculate available income for EMI
      final availableIncome = monthlyIncome - monthlyExpenses - existingEmi;
      
      // Maximum EMI should be 40-50% of net monthly income
      _maxEmi = availableIncome * 0.40; // Conservative 40%
      
      // Calculate eligible loan amount based on loan type and interest rate
      double interestRate = _getInterestRate(_selectedLoanType!);
      int tenureMonths = _getTenureMonths(_selectedLoanType!);
      
      // EMI formula: EMI = [P x R x (1+R)^N] / [(1+R)^N - 1]
      // Solving for P: P = EMI x [((1+R)^N - 1) / (R x (1+R)^N)]
      final monthlyRate = interestRate / 12 / 100;
      final emiFactor = ((1 + monthlyRate).pow(tenureMonths) - 1) / 
                       (monthlyRate * (1 + monthlyRate).pow(tenureMonths));
      _eligibleAmount = _maxEmi * emiFactor;
      
      // Apply eligibility multipliers based on employment and other factors
      double multiplier = 1.0;
      if (_selectedEmploymentType == 'Salaried') multiplier *= 1.0;
      if (_selectedEmploymentType == 'Self-Employed') multiplier *= 0.8;
      if (_selectedEmploymentType == 'Business Owner') multiplier *= 0.9;
      if (workExp >= 2) multiplier *= 1.1;
      if (age < 25 || age > 65) multiplier *= 0.7;
      
      _eligibleAmount *= multiplier;
      
      // Determine eligibility status
      if (_eligibleAmount >= 100000) {
        _eligibilityStatus = 'Highly Eligible';
        _statusColor = Colors.green as MaterialColor;
      } else if (_eligibleAmount >= 50000) {
        _eligibilityStatus = 'Eligible';
        _statusColor = Colors.blue as MaterialColor;
      } else if (_eligibleAmount >= 20000) {
        _eligibilityStatus = 'Moderately Eligible';
        _statusColor = Colors.orange as MaterialColor;
      } else {
        _eligibilityStatus = 'Low Eligibility';
        _statusColor = Colors.red as MaterialColor;
      }
      
      setState(() {
        _showResults = true;
      });
      
      // Automatically show eligibility criteria modal after calculation
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showEligibilityCriteriaModal(context);
          }
        });
      }
    }
  }

  double _getInterestRate(String loanType) {
    switch (loanType) {
      case 'Personal Loan':
        return 12.0;
      case 'Home Loan':
        return 8.5;
      case 'Car Loan':
        return 9.5;
      case 'Education Loan':
        return 8.0;
      case 'Business Loan':
        return 11.0;
      default:
        return 10.0;
    }
  }

  int _getTenureMonths(String loanType) {
    switch (loanType) {
      case 'Personal Loan':
        return 60; // 5 years
      case 'Home Loan':
        return 240; // 20 years
      case 'Car Loan':
        return 84; // 7 years
      case 'Education Loan':
        return 120; // 10 years
      case 'Business Loan':
        return 60; // 5 years
      default:
        return 60;
    }
  }

  Map<String, String> _getEligibilityCriteria(String loanType) {
    switch (loanType) {
      case 'Personal Loan':
        return {
          'Minimum Age': '21 years',
          'Maximum Age': '60 years',
          'Minimum Income': '₹15,000/month',
          'Work Experience': '3 months minimum',
          'Credit Score': '650+',
          'Employment': 'Salaried/Self-Employed',
        };
      case 'Home Loan':
        return {
          'Minimum Age': '21 years',
          'Maximum Age': '65 years',
          'Minimum Income': '₹25,000/month',
          'Work Experience': '2 years minimum',
          'Credit Score': '700+',
          'Down Payment': '10-20% of property value',
        };
      case 'Car Loan':
        return {
          'Minimum Age': '21 years',
          'Maximum Age': '65 years',
          'Minimum Income': '₹15,000/month',
          'Work Experience': '1 year minimum',
          'Credit Score': '650+',
          'Down Payment': '10-15% of car value',
        };
      case 'Education Loan':
        return {
          'Minimum Age': '18 years',
          'Maximum Age': '35 years (student)',
          'Co-applicant': 'Required (Parent/Guardian)',
          'Course': 'Recognized institution',
          'Credit Score': '650+',
          'Collateral': 'May be required for high amounts',
        };
      case 'Business Loan':
        return {
          'Minimum Age': '25 years',
          'Maximum Age': '65 years',
          'Minimum Income': '₹50,000/month',
          'Business Age': '2+ years',
          'Credit Score': '700+',
          'Financial Documents': 'Required',
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.cardBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Loan Eligibility Calculator',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Check Your Loan Eligibility',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Get instant eligibility check and loan amount',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Loan Type
              _buildSectionTitle('Loan Type'),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedLoanType,
                hint: 'Select Loan Type',
                items: _loanTypes,
                icon: Icons.category,
                onChanged: (value) {
                  setState(() {
                    _selectedLoanType = value;
                    _showResults = false;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Monthly Income
              _buildSectionTitle('Monthly Income (₹)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _monthlyIncomeController,
                hint: 'Enter monthly income',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly income';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Monthly Expenses
              _buildSectionTitle('Monthly Expenses (₹)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _monthlyExpensesController,
                hint: 'Enter monthly expenses',
                icon: Icons.shopping_cart,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly expenses';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Existing EMI (Optional)
              _buildSectionTitle('Existing EMI (₹) - Optional'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _existingEmiController,
                hint: 'Enter existing EMI if any',
                icon: Icons.payment,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              // Age
              _buildSectionTitle('Age'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _ageController,
                hint: 'Enter your age',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 18 || age > 75) {
                    return 'Age must be between 18-75';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Employment Type
              _buildSectionTitle('Employment Type'),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedEmploymentType,
                hint: 'Select Employment Type',
                items: _employmentTypes,
                icon: Icons.work,
                onChanged: (value) {
                  setState(() {
                    _selectedEmploymentType = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Work Experience
              _buildSectionTitle('Work Experience (Years) - Optional'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _workExperienceController,
                hint: 'Enter years of experience',
                icon: Icons.business_center,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 40),

              // Calculate Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _calculateEligibility,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calculate, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Check Eligibility',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Results
              if (_showResults) ...[
                const SizedBox(height: 40),
                _buildResultsCard(),
                const SizedBox(height: 24),
                if (_selectedLoanType != null)
                  // Button to view eligibility criteria
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: OutlinedButton.icon(
                      onPressed: () => _showEligibilityCriteriaModal(context),
                      icon: const Icon(Icons.info_outline, color: Colors.blue),
                      label: const Text(
                        'View Eligibility Criteria',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.blue.shade400, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = ThemeProvider.of(context);
    
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: themeProvider.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.blue),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: themeProvider.themeMode == ThemeMode.dark
            ? Border.all(color: themeProvider.borderColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              themeProvider.themeMode == ThemeMode.dark ? 0.2 : 0.05
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        style: TextStyle(color: themeProvider.textPrimary),
        dropdownColor: themeProvider.cardBackground,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeProvider.cardBackground,
          prefixIcon: Icon(icon, color: Colors.blue),
        ),
        hint: Text(
          hint,
          style: TextStyle(color: themeProvider.textSecondary),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(color: themeProvider.textPrimary),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select an option';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_statusColor.shade400, _statusColor.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _statusColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _statusColor == Colors.green
                  ? Icons.check_circle
                  : _statusColor == Colors.blue
                      ? Icons.verified
                      : _statusColor == Colors.orange
                          ? Icons.warning
                          : Icons.error,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _eligibilityStatus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildResultItem(
                  'Eligible Amount',
                  '₹${NumberFormat('#,##,###').format(_eligibleAmount)}',
                  Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultItem(
                  'Max EMI',
                  '₹${NumberFormat('#,##,###').format(_maxEmi)}',
                  Icons.payment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showEligibilityCriteriaModal(BuildContext context) {
    if (_selectedLoanType == null) return;
    
    final criteria = _getEligibilityCriteria(_selectedLoanType!);
    final MaterialColor loanColor = _getLoanTypeColor(_selectedLoanType!);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [loanColor.shade400, loanColor.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
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
                      Icons.info_outline,
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
                          'Eligibility Criteria',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedLoanType ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Meet these requirements to qualify for ${_selectedLoanType}',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Criteria List
                    ...criteria.entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: loanColor.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getCriteriaIcon(entry.key),
                              color: loanColor.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle_outline,
                            color: loanColor.shade400,
                            size: 24,
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                    // Tips section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50,
                            Colors.orange.shade100,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates, color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Tips to Improve Eligibility',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTipItem('Maintain a good credit score (700+)'),
                          _buildTipItem('Keep your debt-to-income ratio below 40%'),
                          _buildTipItem('Have stable employment history'),
                          _buildTipItem('Avoid multiple loan applications'),
                          _buildTipItem('Show consistent income growth'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: loanColor.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got It',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  MaterialColor _getLoanTypeColor(String loanType) {
    switch (loanType) {
      case 'Personal Loan':
        return Colors.purple;
      case 'Home Loan':
        return Colors.blue;
      case 'Car Loan':
        return Colors.green;
      case 'Education Loan':
        return Colors.orange;
      case 'Business Loan':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getCriteriaIcon(String criteria) {
    if (criteria.contains('Age')) return Icons.calendar_today;
    if (criteria.contains('Income')) return Icons.currency_rupee;
    if (criteria.contains('Experience')) return Icons.work;
    if (criteria.contains('Credit')) return Icons.score;
    if (criteria.contains('Payment')) return Icons.payment;
    if (criteria.contains('Employment')) return Icons.business;
    if (criteria.contains('Course')) return Icons.school;
    if (criteria.contains('Business Age')) return Icons.calendar_month;
    if (criteria.contains('Documents')) return Icons.description;
    if (criteria.contains('Collateral')) return Icons.security;
    return Icons.check_circle;
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityCriteriaCard() {
    final criteria = _getEligibilityCriteria(_selectedLoanType!);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
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
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info_outline, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'Eligibility Criteria',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...criteria.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

extension Pow on double {
  double pow(int exponent) {
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= this;
    }
    return result;
  }
}

