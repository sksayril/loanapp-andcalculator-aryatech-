import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class RecurringDepositCalculatorModern extends StatefulWidget {
  const RecurringDepositCalculatorModern({super.key});

  @override
  State<RecurringDepositCalculatorModern> createState() => _RecurringDepositCalculatorModernState();
}

class _RecurringDepositCalculatorModernState extends State<RecurringDepositCalculatorModern> {
  double _monthlyDeposit = 5000;
  double _interestRate = 6.5;
  int _tenureMonths = 12;

  double _totalDeposit = 0;
  double _interestEarned = 0;
  double _maturityAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateRD();
  }

  void _calculateRD() {
    // EXACT SAME LOGIC AS ORIGINAL
    // Formula: M = P * [((1 + r)^n - 1) / r] * (1 + r)
    // where P = monthly deposit, r = monthly interest rate, n = number of months
    final double monthlyRate = _interestRate / 12 / 100;
    final double maturityAmount = _monthlyDeposit * 
        ((pow(1 + monthlyRate, _tenureMonths) - 1) / monthlyRate) * 
        (1 + monthlyRate);
    
    final double totalDeposit = _monthlyDeposit * _tenureMonths;
    final double interestEarned = maturityAmount - totalDeposit;

    setState(() {
      _totalDeposit = totalDeposit;
      _interestEarned = interestEarned;
      _maturityAmount = maturityAmount;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'recurring_deposit',
      inputData: {
        'Monthly Deposit': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_monthlyDeposit)}',
        'Interest Rate': '${_interestRate.toStringAsFixed(1)}%',
        'Tenure': '$_tenureMonths months (${(_tenureMonths / 12).toStringAsFixed(1)} years)',
      },
      resultData: {
        'Total Deposit': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalDeposit)}',
        'Interest Earned': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_interestEarned)}',
        'Maturity Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_maturityAmount)}',
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
          'Recurring Deposit Calculator',
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
            // Monthly Deposit Slider
            ModernCalculatorSlider(
              label: 'Monthly Deposit',
              value: _monthlyDeposit,
              min: 500,
              max: 100000,
              divisions: 199,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _monthlyDeposit = value;
                  _calculateRD();
                });
              },
            ),
            const SizedBox(height: 30),

            // Interest Rate Slider
            ModernCalculatorSlider(
              label: 'Interest Rate',
              value: _interestRate,
              min: 3.0,
              max: 12.0,
              divisions: 90,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _interestRate = value;
                  _calculateRD();
                });
              },
            ),
            const SizedBox(height: 30),

            // Tenure Slider (in months)
            ModernCalculatorSlider(
              label: 'Tenure',
              value: _tenureMonths.toDouble(),
              min: 6,
              max: 120,
              divisions: 114,
              valueFormatter: (val) {
                final months = val.toInt();
                if (months < 12) {
                  return '$months M';
                } else if (months % 12 == 0) {
                  return '${months ~/ 12} Y';
                } else {
                  return '${months ~/ 12}Y ${months % 12}M';
                }
              },
              onChanged: (value) {
                setState(() {
                  _tenureMonths = value.toInt();
                  _calculateRD();
                });
              },
            ),
            const SizedBox(height: 40),

            // Maturity Amount Result Card
            ModernResultCard(
              title: 'MATURITY AMOUNT',
              amount: formatCurrency(_maturityAmount),
              subtitle: 'Interest Earned: ${formatCurrency(_interestEarned)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total Deposit',
                    formatCurrency(_totalDeposit),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Interest Earned',
                    formatCurrency(_interestEarned),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Investment Breakdown Chart
            _buildInvestmentBreakdown(themeProvider),
            const SizedBox(height: 24),

            // RD Information Card
            _buildRdInfoCard(themeProvider),
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
                    value: _totalDeposit,
                    title: '${((_totalDeposit / _maturityAmount) * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF1E3A5F),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _interestEarned,
                    title: '${((_interestEarned / _maturityAmount) * 100).toStringAsFixed(1)}%',
                    color: Colors.teal.shade400,
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
              _buildLegendItem('Deposits', const Color(0xFF1E3A5F), themeProvider),
              _buildLegendItem('Interest', Colors.teal.shade400, themeProvider),
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

  Widget _buildRdInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.teal.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.teal.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recurring Deposit Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Regular monthly deposits'),
          _buildInfoRow('• Fixed interest rate for entire tenure'),
          _buildInfoRow('• Minimum tenure: 6 months'),
          _buildInfoRow('• Ideal for disciplined savings'),
          _buildInfoRow('• TDS applicable on interest above ₹40,000'),
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
          color: Colors.teal.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
