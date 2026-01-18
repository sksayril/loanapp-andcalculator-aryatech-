import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class IncomeTaxCalculatorModern extends StatefulWidget {
  const IncomeTaxCalculatorModern({super.key});

  @override
  State<IncomeTaxCalculatorModern> createState() => _IncomeTaxCalculatorModernState();
}

class _IncomeTaxCalculatorModernState extends State<IncomeTaxCalculatorModern> {
  double _annualIncome = 800000;
  double _deductions = 150000;
  double _exemptions = 0;
  
  String _selectedRegime = 'New Tax Regime';
  String _selectedAgeGroup = 'Below 60';
  
  final List<String> _regimes = ['Old Tax Regime', 'New Tax Regime'];
  final List<String> _ageGroups = ['Below 60', '60-80 years', 'Above 80 years'];
  
  // Calculation results
  double _taxableIncome = 0;
  double _totalTax = 0;
  double _cess = 0;
  double _totalTaxPayable = 0;
  double _netIncome = 0;
  double _effectiveTaxRate = 0;

  @override
  void initState() {
    super.initState();
    _calculateTax();
  }

  void _calculateTax() {
    // EXACT SAME LOGIC AS ORIGINAL
    // Calculate taxable income based on regime
    if (_selectedRegime == 'New Tax Regime') {
      // New regime: Standard deduction of ₹50,000
      _taxableIncome = _annualIncome - 50000 - _exemptions;
    } else {
      // Old regime: Apply deductions (80C, HRA, etc.)
      _taxableIncome = _annualIncome - _deductions - _exemptions;
    }
    
    if (_taxableIncome < 0) _taxableIncome = 0;
    
    // Calculate tax based on selected regime and age
    _totalTax = _calculateIncomeTax(_taxableIncome, _selectedRegime, _selectedAgeGroup);
    _cess = _totalTax * 0.04; // 4% cess
    _totalTaxPayable = _totalTax + _cess;
    _netIncome = _annualIncome - _totalTaxPayable;
    _effectiveTaxRate = _annualIncome > 0 ? (_totalTaxPayable / _annualIncome) * 100 : 0;

    setState(() {});

    // Save to history
    _saveToHistory();
  }

  double _calculateIncomeTax(double taxableIncome, String regime, String ageGroup) {
    // EXACT SAME LOGIC AS ORIGINAL
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

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'income_tax',
      inputData: {
        'Annual Income': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_annualIncome)}',
        'Tax Regime': _selectedRegime,
        'Age Group': _selectedAgeGroup,
        'Deductions': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_deductions)}',
        'Exemptions': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_exemptions)}',
      },
      resultData: {
        'Taxable Income': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_taxableIncome)}',
        'Total Tax': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalTax)}',
        'Cess': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_cess)}',
        'Total Tax Payable': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalTaxPayable)}',
        'Net Income': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_netIncome)}',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Income Tax Calculator',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tax Regime Toggle
            Text(
              'Tax Regime',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRegime = 'Old Tax Regime';
                          _calculateTax();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRegime == 'Old Tax Regime'
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Old Regime',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedRegime == 'Old Tax Regime'
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRegime = 'New Tax Regime';
                          _calculateTax();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedRegime == 'New Tax Regime'
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'New Regime',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedRegime == 'New Tax Regime'
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Age Group Selector
            Text(
              'Age Group',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _ageGroups.map((age) {
                final isSelected = _selectedAgeGroup == age;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAgeGroup = age;
                      _calculateTax();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E3A5F)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E3A5F)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      age,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Annual Income Slider
            ModernCalculatorSlider(
              label: 'Annual Income',
              value: _annualIncome,
              min: 100000,
              max: 10000000,
              divisions: 495,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _annualIncome = value;
                  _calculateTax();
                });
              },
            ),
            const SizedBox(height: 30),

            // Deductions (only for Old Regime)
            if (_selectedRegime == 'Old Tax Regime') ...[
              ModernCalculatorSlider(
                label: 'Tax Deductions (80C, HRA, etc.)',
                value: _deductions,
                min: 0,
                max: 500000,
                divisions: 100,
                valueFormatter: (val) => formatCompactCurrency(val),
                onChanged: (value) {
                  setState(() {
                    _deductions = value;
                    _calculateTax();
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            // Exemptions Slider
            ModernCalculatorSlider(
              label: 'Other Exemptions',
              value: _exemptions,
              min: 0,
              max: 200000,
              divisions: 40,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _exemptions = value;
                  _calculateTax();
                });
              },
            ),
            const SizedBox(height: 40),

            // Total Tax Payable Result Card
            ModernResultCard(
              title: 'TOTAL TAX PAYABLE',
              amount: formatCurrency(_totalTaxPayable),
              subtitle: 'Effective Tax Rate: ${_effectiveTaxRate.toStringAsFixed(2)}%',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Taxable Income',
                    formatCurrency(_taxableIncome),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Net Income',
                    formatCurrency(_netIncome),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Tax (excl. cess)',
                    formatCurrency(_totalTax),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Health & Edu Cess',
                    formatCurrency(_cess),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tax Breakdown Chart
            _buildTaxBreakdown(themeProvider),
            const SizedBox(height: 24),

            // Tax Information Card
            _buildTaxInfoCard(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: themeProvider.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxBreakdown(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.themeMode == ThemeMode.dark
              ? themeProvider.borderColor
              : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Income Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(
                    value: _netIncome,
                    title: '${((_netIncome / _annualIncome) * 100).toStringAsFixed(1)}%',
                    color: Colors.green.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _totalTaxPayable,
                    title: '${((_totalTaxPayable / _annualIncome) * 100).toStringAsFixed(1)}%',
                    color: Colors.red.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('Net Income', Colors.green.shade400, themeProvider),
              _buildLegendItem('Tax Payable', Colors.red.shade400, themeProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeProvider themeProvider) {
    return Row(
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
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.indigo.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tax Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedRegime == 'New Tax Regime') ...[
            _buildInfoRow('• Standard deduction: ₹50,000'),
            _buildInfoRow('• No deductions like 80C, HRA allowed'),
            _buildInfoRow('• Lower tax rates'),
          ] else ...[
            _buildInfoRow('• Deductions like 80C (₹1.5L), HRA allowed'),
            _buildInfoRow('• Higher tax rates but more savings options'),
          ],
          _buildInfoRow('• Health & Education Cess: 4%'),
          _buildInfoRow('• Tax calculated as per FY 2024-25 slabs'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.indigo.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
