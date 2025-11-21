import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/theme_provider.dart';

class IncomeTaxCalculatorScreen extends StatefulWidget {
  const IncomeTaxCalculatorScreen({super.key});

  @override
  State<IncomeTaxCalculatorScreen> createState() => _IncomeTaxCalculatorScreenState();
}

class _IncomeTaxCalculatorScreenState extends State<IncomeTaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _annualIncomeController = TextEditingController();
  final _ageController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _exemptionsController = TextEditingController();
  
  String? _selectedRegime; // Old or New Tax Regime
  String? _selectedAgeGroup;
  
  bool _showResults = false;
  
  // Calculation results
  double _annualIncome = 0;
  double _taxableIncome = 0;
  double _totalTax = 0;
  double _cess = 0;
  double _totalTaxPayable = 0;
  double _netIncome = 0;
  double _effectiveTaxRate = 0;
  
  final List<String> _regimes = ['Old Tax Regime', 'New Tax Regime'];
  final List<String> _ageGroups = ['Below 60', '60-80 years', 'Above 80 years'];
  
  @override
  void dispose() {
    _annualIncomeController.dispose();
    _ageController.dispose();
    _deductionsController.dispose();
    _exemptionsController.dispose();
    super.dispose();
  }
  
  void _calculateTax() {
    if (_formKey.currentState!.validate() && 
        _selectedRegime != null && 
        _selectedAgeGroup != null) {
      
      final annualIncome = double.parse(_annualIncomeController.text);
      _annualIncome = annualIncome;
      final deductions = double.tryParse(_deductionsController.text) ?? 0;
      final exemptions = double.tryParse(_exemptionsController.text) ?? 0;
      
      // Calculate taxable income based on regime
      if (_selectedRegime == 'New Tax Regime') {
        // New regime: Standard deduction of ₹50,000
        _taxableIncome = annualIncome - 50000 - exemptions;
      } else {
        // Old regime: Apply deductions (80C, HRA, etc.)
        _taxableIncome = annualIncome - deductions - exemptions;
      }
      
      if (_taxableIncome < 0) _taxableIncome = 0;
      
      // Calculate tax based on selected regime and age
      _totalTax = _calculateIncomeTax(_taxableIncome, _selectedRegime!, _selectedAgeGroup!);
      _cess = _totalTax * 0.04; // 4% cess
      _totalTaxPayable = _totalTax + _cess;
      _netIncome = annualIncome - _totalTaxPayable;
      _effectiveTaxRate = annualIncome > 0 ? (_totalTaxPayable / annualIncome) * 100 : 0;
      
      setState(() {
        _showResults = true;
      });
      
      // Show results in a popup modal
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _showTaxResultsModal(context);
          }
        });
      }
    }
  }
  
  void _showTaxResultsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaxResultsModal(
        annualIncome: _annualIncome,
        taxableIncome: _taxableIncome,
        totalTax: _totalTax,
        cess: _cess,
        totalTaxPayable: _totalTaxPayable,
        netIncome: _netIncome,
        effectiveTaxRate: _effectiveTaxRate,
      ),
    );
  }
  
  double _calculateIncomeTax(double taxableIncome, String regime, String ageGroup) {
    if (taxableIncome <= 0) return 0;
    
    if (regime == 'New Tax Regime') {
      // New Tax Regime (FY 2024-25)
      if (taxableIncome <= 300000) return 0;
      if (taxableIncome <= 700000) return (taxableIncome - 300000) * 0.05;
      if (taxableIncome <= 1000000) return 20000 + (taxableIncome - 700000) * 0.10;
      if (taxableIncome <= 1200000) return 50000 + (taxableIncome - 1000000) * 0.15;
      if (taxableIncome <= 1500000) return 80000 + (taxableIncome - 1200000) * 0.20;
      return 140000 + (taxableIncome - 1500000) * 0.30;
    } else {
      // Old Tax Regime with age-based slabs
      double tax = 0;
      
      if (ageGroup == 'Below 60') {
        if (taxableIncome <= 250000) return 0;
        if (taxableIncome <= 500000) tax = (taxableIncome - 250000) * 0.05;
        else if (taxableIncome <= 1000000) tax = 12500 + (taxableIncome - 500000) * 0.20;
        else tax = 112500 + (taxableIncome - 1000000) * 0.30;
      } else if (ageGroup == '60-80 years') {
        if (taxableIncome <= 300000) return 0;
        if (taxableIncome <= 500000) tax = (taxableIncome - 300000) * 0.05;
        else if (taxableIncome <= 1000000) tax = 10000 + (taxableIncome - 500000) * 0.20;
        else tax = 110000 + (taxableIncome - 1000000) * 0.30;
      } else { // Above 80 years
        if (taxableIncome <= 500000) return 0;
        if (taxableIncome <= 1000000) tax = (taxableIncome - 500000) * 0.20;
        else tax = 100000 + (taxableIncome - 1000000) * 0.30;
      }
      
      return tax;
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
          'Income Tax Calculator',
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
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.3),
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
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Calculate Your Income Tax',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Know your tax liability instantly',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Tax Regime Selection
              _buildSectionTitle('Select Tax Regime'),
              const SizedBox(height: 12),
              _buildRegimeSelector(),
              
              const SizedBox(height: 24),
              
              // Annual Income
              _buildSectionTitle('Annual Income (₹)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _annualIncomeController,
                hint: 'Enter your annual income',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter annual income';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Age Group
              _buildSectionTitle('Age Group'),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _selectedAgeGroup,
                hint: 'Select your age group',
                items: _ageGroups,
                icon: Icons.calendar_today,
                onChanged: (value) {
                  setState(() {
                    _selectedAgeGroup = value;
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Deductions (Old Regime)
              if (_selectedRegime == 'Old Tax Regime') ...[
                _buildSectionTitle('Tax Deductions (₹) - Optional'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _deductionsController,
                  hint: 'Enter deductions (80C, HRA, etc.)',
                  icon: Icons.receipt_long,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
              ],
              
              // Exemptions
              _buildSectionTitle('Other Exemptions (₹) - Optional'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _exemptionsController,
                hint: 'Enter other exemptions',
                icon: Icons.money_off,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 40),
              
              // Calculate Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade400, Colors.indigo.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _calculateTax,
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
                        'Calculate Tax',
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
                _buildTaxBreakdownCard(),
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(icon, color: Colors.indigo),
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
          prefixIcon: Icon(icon, color: Colors.indigo),
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
  
  Widget _buildRegimeSelector() {
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
      child: Row(
        children: _regimes.map((regime) {
          final isSelected = _selectedRegime == regime;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRegime = regime;
                  _showResults = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.indigo.shade50
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.indigo.shade400
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? Colors.indigo.shade400 : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      regime,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.indigo.shade700
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildResultsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
              Icons.verified,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tax Summary',
            style: TextStyle(
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
                  'Taxable Income',
                  '₹${NumberFormat('#,##,###').format(_taxableIncome)}',
                  Icons.account_balance,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultItem(
                  'Total Tax',
                  '₹${NumberFormat('#,##,###').format(_totalTax)}',
                  Icons.receipt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildResultItem(
                  'Tax + Cess',
                  '₹${NumberFormat('#,##,###').format(_totalTaxPayable)}',
                  Icons.payment,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResultItem(
                  'Net Income',
                  '₹${NumberFormat('#,##,###').format(_netIncome)}',
                  Icons.wallet,
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildTaxBreakdownCard() {
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
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pie_chart, color: Colors.indigo.shade700),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tax Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildBreakdownRow('Income Tax', _totalTax, Colors.blue),
          const SizedBox(height: 12),
          _buildBreakdownRow('Cess (4%)', _cess, Colors.orange),
          const Divider(height: 24),
          _buildBreakdownRow('Total Tax Payable', _totalTaxPayable, Colors.red, isBold: true),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Effective Tax Rate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${_effectiveTaxRate.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBreakdownRow(String label, double amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Tax Results Modal Widget
class _TaxResultsModal extends StatelessWidget {
  final double annualIncome;
  final double taxableIncome;
  final double totalTax;
  final double cess;
  final double totalTaxPayable;
  final double netIncome;
  final double effectiveTaxRate;

  const _TaxResultsModal({
    super.key,
    required this.annualIncome,
    required this.taxableIncome,
    required this.totalTax,
    required this.cess,
    required this.totalTaxPayable,
    required this.netIncome,
    required this.effectiveTaxRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                colors: [Colors.green.shade400, Colors.green.shade600],
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
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your tax calculation results',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
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
                  // Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultItem(
                          'Taxable Income',
                          '₹${NumberFormat('#,##,###').format(taxableIncome)}',
                          Icons.account_balance,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultItem(
                          'Total Tax',
                          '₹${NumberFormat('#,##,###').format(totalTax)}',
                          Icons.receipt,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultItem(
                          'Tax + Cess',
                          '₹${NumberFormat('#,##,###').format(totalTaxPayable)}',
                          Icons.payment,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultItem(
                          'Net Income',
                          '₹${NumberFormat('#,##,###').format(netIncome)}',
                          Icons.wallet,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Pie Chart Section
                  Container(
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
                                color: Colors.indigo.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.pie_chart, color: Colors.indigo.shade700),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tax Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Pie Chart Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              // Pie Chart
                              SizedBox(
                                height: 280,
                                child: _buildPieChart(),
                              ),
                              const SizedBox(height: 20),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildLegendItem('Tax', totalTax, Colors.blue),
                                  _buildLegendItem('Cess', cess, Colors.orange),
                                  _buildLegendItem('Net Income', netIncome, Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildBreakdownRow('Income Tax', totalTax, Colors.blue),
                        const SizedBox(height: 12),
                        _buildBreakdownRow('Cess (4%)', cess, Colors.orange),
                        const Divider(height: 24),
                        _buildBreakdownRow('Total Tax Payable', totalTaxPayable, Colors.red, isBold: true),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Effective Tax Rate',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${effectiveTaxRate.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade700,
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
                  backgroundColor: Colors.green.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Close',
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
    );
  }

  Widget _buildResultItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, double amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
        Text(
          '₹${NumberFormat('#,##,###').format(amount)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    if (annualIncome <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No data to display',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Calculate percentages based on annual income
    final taxPercentage = annualIncome > 0 ? (totalTax / annualIncome) * 100 : 0;
    final cessPercentage = annualIncome > 0 ? (cess / annualIncome) * 100 : 0;
    final netIncomePercentage = annualIncome > 0 ? (netIncome / annualIncome) * 100 : 0;

    // Build sections - use actual values, pie chart will handle zero values
    List<PieChartSectionData> sections = [];
    
    // Add tax section (only if > 0 or show as very small for visibility)
    if (totalTax > 0 || taxPercentage > 0.1) {
      sections.add(
        PieChartSectionData(
          value: totalTax > 0 ? totalTax : annualIncome * 0.001,
          title: taxPercentage > 1 ? '${taxPercentage.toStringAsFixed(1)}%' : '',
          color: Colors.blue.shade600,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Add cess section
    if (cess > 0 || cessPercentage > 0.1) {
      sections.add(
        PieChartSectionData(
          value: cess > 0 ? cess : annualIncome * 0.001,
          title: cessPercentage > 1 ? '${cessPercentage.toStringAsFixed(1)}%' : '',
          color: Colors.orange.shade600,
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }
    
    // Add net income section (always show)
    sections.add(
      PieChartSectionData(
        value: netIncome > 0 ? netIncome : annualIncome,
        title: netIncomePercentage > 1 ? '${netIncomePercentage.toStringAsFixed(1)}%' : '100.0%',
        color: Colors.green.shade600,
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 70,
        sections: sections,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            // Optional: Add touch interaction
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, double value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '₹${NumberFormat('#,##,###').format(value)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

