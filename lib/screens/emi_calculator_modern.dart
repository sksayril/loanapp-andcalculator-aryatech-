import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';

class EmiCalculatorModern extends StatefulWidget {
  const EmiCalculatorModern({super.key});

  @override
  State<EmiCalculatorModern> createState() => _EmiCalculatorModernState();
}

class _EmiCalculatorModernState extends State<EmiCalculatorModern> {
  // Slider values
  double _loanAmount = 200000;
  double _interestRate = 10.5;
  double _tenureMonths = 24;

  // Results
  double _emi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;

  @override
  void initState() {
    super.initState();
    _calculateEMI();
  }

  void _calculateEMI() {
    final P = _loanAmount;
    final r = _interestRate / 12 / 100;
    final n = _tenureMonths;

    if (r == 0) {
      _emi = P / n;
    } else {
      _emi = P * r * math.pow(1 + r, n) / (math.pow(1 + r, n) - 1);
    }

    _totalPayment = _emi * n;
    _totalInterest = _totalPayment - P;

    setState(() {});
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
          'EMI Calculator',
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
            // Loan Amount Slider
            ModernCalculatorSlider(
              label: 'Loan Amount',
              value: _loanAmount,
              min: 50000,
              max: 2000000,
              divisions: 195,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _loanAmount = value;
                  _calculateEMI();
                });
              },
            ),
            const SizedBox(height: 30),
            
            // Interest Rate Slider
            ModernCalculatorSlider(
              label: 'Interest Rate',
              value: _interestRate,
              min: 5.0,
              max: 20.0,
              divisions: 150,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _interestRate = value;
                  _calculateEMI();
                });
              },
            ),
            const SizedBox(height: 30),
            
            // Tenure Slider
            ModernCalculatorSlider(
              label: 'Tenure',
              value: _tenureMonths,
              min: 12,
              max: 60,
              divisions: 48,
              suffix: ' Months',
              valueFormatter: (val) => val.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _tenureMonths = value;
                  _calculateEMI();
                });
              },
            ),
            const SizedBox(height: 40),
            
            // EMI Result Card
            ModernResultCard(
              title: 'YOUR MONTHLY EMI',
              amount: formatCurrency(_emi),
              subtitle: 'Total Interest Payable: ${formatCurrency(_totalInterest)}',
            ),
            const SizedBox(height: 24),
            
            // Additional Info Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Principal Amount',
                    formatCurrency(_loanAmount),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Total Payment',
                    formatCurrency(_totalPayment),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Breakdown Card
            _buildBreakdownCard(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, ThemeProvider themeProvider) {
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(ThemeProvider themeProvider) {
    final principalPercentage = (_loanAmount / _totalPayment * 100);
    final interestPercentage = (_totalInterest / _totalPayment * 100);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Progress bar
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: principalPercentage / 100,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A5F),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                'Principal',
                formatCurrency(_loanAmount),
                '${principalPercentage.toStringAsFixed(1)}%',
                const Color(0xFF1E3A5F),
                themeProvider,
              ),
              _buildLegendItem(
                'Interest',
                formatCurrency(_totalInterest),
                '${interestPercentage.toStringAsFixed(1)}%',
                Colors.orange.shade400,
                themeProvider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    String value,
    String percentage,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: themeProvider.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            fontSize: 11,
            color: themeProvider.textSecondary,
          ),
        ),
      ],
    );
  }
}
