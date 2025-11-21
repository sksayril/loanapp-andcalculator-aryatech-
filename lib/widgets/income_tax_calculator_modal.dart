import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeTaxCalculatorModal extends StatefulWidget {
  const IncomeTaxCalculatorModal({super.key});

  @override
  State<IncomeTaxCalculatorModal> createState() => _IncomeTaxCalculatorModalState();
}

class _IncomeTaxCalculatorModalState extends State<IncomeTaxCalculatorModal> {
  final _formKey = GlobalKey<FormState>();
  final _calculator = _IncomeTaxCalculator();
  
  // Controllers
  final _annualIncomeController = TextEditingController();
  final _ageController = TextEditingController();
  final _deductionsController = TextEditingController();
  final _exemptionsController = TextEditingController();
  
  String? _selectedRegime;
  String? _selectedAgeGroup;
  
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
      final deductions = double.tryParse(_deductionsController.text) ?? 0;
      final exemptions = double.tryParse(_exemptionsController.text) ?? 0;
      
      final results = _calculator.calculateTax(
        annualIncome,
        _selectedRegime!,
        _selectedAgeGroup!,
        deductions,
        exemptions,
      );
      
      // Show results in a popup modal
      _showTaxResultsModal(context, results);
    }
  }
  
  void _showTaxResultsModal(BuildContext context, TaxCalculationResults results) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaxResultsModal(results: results),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                colors: [Colors.indigo.shade400, Colors.indigo.shade600],
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
                    Icons.account_balance_wallet,
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
                        'Income Tax Calculator',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Calculate your tax liability',
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
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 32),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
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
          fillColor: Colors.grey.shade50,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
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
          fillColor: Colors.grey.shade50,
          prefixIcon: Icon(icon, color: Colors.indigo),
        ),
        hint: Text(hint),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: _regimes.map((regime) {
          final isSelected = _selectedRegime == regime;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRegime = regime;
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
}

class TaxCalculationResults {
  final double taxableIncome;
  final double totalTax;
  final double cess;
  final double totalTaxPayable;
  final double netIncome;
  final double effectiveTaxRate;
  final String regime;
  final String ageGroup;

  TaxCalculationResults({
    required this.taxableIncome,
    required this.totalTax,
    required this.cess,
    required this.totalTaxPayable,
    required this.netIncome,
    required this.effectiveTaxRate,
    required this.regime,
    required this.ageGroup,
  });
}

class TaxResultsModal extends StatelessWidget {
  final TaxCalculationResults results;

  const TaxResultsModal({super.key, required this.results});

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
                          '₹${NumberFormat('#,##,###').format(results.taxableIncome)}',
                          Icons.account_balance,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultItem(
                          'Total Tax',
                          '₹${NumberFormat('#,##,###').format(results.totalTax)}',
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
                          '₹${NumberFormat('#,##,###').format(results.totalTaxPayable)}',
                          Icons.payment,
                          Colors.red,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultItem(
                          'Net Income',
                          '₹${NumberFormat('#,##,###').format(results.netIncome)}',
                          Icons.wallet,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tax Breakdown Card
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
                        const SizedBox(height: 20),
                        _buildBreakdownRow('Income Tax', results.totalTax, Colors.blue),
                        const SizedBox(height: 12),
                        _buildBreakdownRow('Cess (4%)', results.cess, Colors.orange),
                        const Divider(height: 24),
                        _buildBreakdownRow('Total Tax Payable', results.totalTaxPayable, Colors.red, isBold: true),
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
                                '${results.effectiveTaxRate.toStringAsFixed(2)}%',
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
}

class _IncomeTaxCalculator {
  TaxCalculationResults calculateTax(
    double annualIncome,
    String regime,
    String ageGroup,
    double deductions,
    double exemptions,
  ) {
    double taxableIncome;
    
    if (regime == 'New Tax Regime') {
      taxableIncome = annualIncome - 50000 - exemptions;
    } else {
      taxableIncome = annualIncome - deductions - exemptions;
    }
    
    if (taxableIncome < 0) taxableIncome = 0;
    
    final totalTax = _calculateIncomeTax(taxableIncome, regime, ageGroup);
    final cess = totalTax * 0.04;
    final totalTaxPayable = totalTax + cess;
    final netIncome = annualIncome - totalTaxPayable;
    final effectiveTaxRate = annualIncome > 0 ? (totalTaxPayable / annualIncome) * 100.0 : 0.0;
    
    return TaxCalculationResults(
      taxableIncome: taxableIncome,
      totalTax: totalTax,
      cess: cess,
      totalTaxPayable: totalTaxPayable,
      netIncome: netIncome,
      effectiveTaxRate: effectiveTaxRate.toDouble(),
      regime: regime,
      ageGroup: ageGroup,
    );
  }
  
  double _calculateIncomeTax(double taxableIncome, String regime, String ageGroup) {
    if (taxableIncome <= 0) return 0;
    
    if (regime == 'New Tax Regime') {
      if (taxableIncome <= 300000) return 0;
      if (taxableIncome <= 700000) return (taxableIncome - 300000) * 0.05;
      if (taxableIncome <= 1000000) return 20000 + (taxableIncome - 700000) * 0.10;
      if (taxableIncome <= 1200000) return 50000 + (taxableIncome - 1000000) * 0.15;
      if (taxableIncome <= 1500000) return 80000 + (taxableIncome - 1200000) * 0.20;
      return 140000 + (taxableIncome - 1500000) * 0.30;
    } else {
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
      } else {
        if (taxableIncome <= 500000) return 0;
        if (taxableIncome <= 1000000) tax = (taxableIncome - 500000) * 0.20;
        else tax = 100000 + (taxableIncome - 1000000) * 0.30;
      }
      
      return tax;
    }
  }
}

