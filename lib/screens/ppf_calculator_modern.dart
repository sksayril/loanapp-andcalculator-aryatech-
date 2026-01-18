import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class PpfCalculatorModern extends StatefulWidget {
  const PpfCalculatorModern({super.key});

  @override
  State<PpfCalculatorModern> createState() => _PpfCalculatorModernState();
}

class _PpfCalculatorModernState extends State<PpfCalculatorModern> {
  double _yearlyInvestment = 50000;
  double _interestRate = 7.1; // Current PPF rate
  int _years = 15; // PPF default tenure

  double _investedAmount = 0;
  double _totalInterest = 0;
  double _maturityValue = 0;

  @override
  void initState() {
    super.initState();
    _calculatePpf();
  }

  void _calculatePpf() {
    // EXACT SAME LOGIC AS ORIGINAL
    double balance = 0;
    for (int i = 0; i < _years; i++) {
      balance += _yearlyInvestment;
      double interestEarned = balance * (_interestRate / 100);
      balance += interestEarned;
    }

    setState(() {
      _investedAmount = _yearlyInvestment * _years;
      _maturityValue = balance;
      _totalInterest = _maturityValue - _investedAmount;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'ppf',
      inputData: {
        'Yearly Investment': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_yearlyInvestment)}',
        'Interest Rate': '${_interestRate.toStringAsFixed(1)}%',
        'Investment Period': '$_years years',
      },
      resultData: {
        'Invested Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_investedAmount)}',
        'Total Interest': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalInterest)}',
        'Maturity Value': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_maturityValue)}',
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
          'PPF Calculator',
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
            // Yearly Investment Slider
            ModernCalculatorSlider(
              label: 'Yearly Investment',
              value: _yearlyInvestment,
              min: 500,
              max: 150000,
              divisions: 299,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _yearlyInvestment = value;
                  _calculatePpf();
                });
              },
            ),
            const SizedBox(height: 30),

            // Interest Rate Slider
            ModernCalculatorSlider(
              label: 'Interest Rate',
              value: _interestRate,
              min: 5.0,
              max: 12.0,
              divisions: 70,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _interestRate = value;
                  _calculatePpf();
                });
              },
            ),
            const SizedBox(height: 30),

            // Investment Period Slider
            ModernCalculatorSlider(
              label: 'Investment Period',
              value: _years.toDouble(),
              min: 15,
              max: 50,
              divisions: 35,
              suffix: ' Years',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _years = value.toInt();
                  _calculatePpf();
                });
              },
            ),
            const SizedBox(height: 40),

            // Maturity Value Result Card
            ModernResultCard(
              title: 'MATURITY VALUE',
              amount: formatCurrency(_maturityValue),
              subtitle: 'Total Interest Earned: ${formatCurrency(_totalInterest)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Invested Amount',
                    formatCurrency(_investedAmount),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Total Interest',
                    formatCurrency(_totalInterest),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Investment Breakdown Chart
            _buildInvestmentBreakdown(themeProvider),
            const SizedBox(height: 24),

            // PPF Information Card
            _buildPpfInfoCard(themeProvider),
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

  Widget _buildInvestmentBreakdown(ThemeProvider themeProvider) {
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
            'Investment Breakdown',
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
                    value: _investedAmount,
                    title: '${((_investedAmount / _maturityValue) * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF1E3A5F),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _totalInterest,
                    title: '${((_totalInterest / _maturityValue) * 100).toStringAsFixed(1)}%',
                    color: Colors.green.shade400,
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
              _buildLegendItem('Principal', const Color(0xFF1E3A5F), themeProvider),
              _buildLegendItem('Interest', Colors.green.shade400, themeProvider),
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

  Widget _buildPpfInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'PPF Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Minimum Investment: ₹500/year'),
          _buildInfoRow('• Maximum Investment: ₹1,50,000/year'),
          _buildInfoRow('• Lock-in Period: 15 years'),
          _buildInfoRow('• Tax Benefit: Under Section 80C'),
          _buildInfoRow('• Interest: Tax-free & compounded yearly'),
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
          color: Colors.blue.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
