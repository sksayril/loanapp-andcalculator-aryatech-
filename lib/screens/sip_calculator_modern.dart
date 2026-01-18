import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class SipCalculatorModern extends StatefulWidget {
  const SipCalculatorModern({super.key});

  @override
  State<SipCalculatorModern> createState() => _SipCalculatorModernState();
}

class _SipCalculatorModernState extends State<SipCalculatorModern> {
  double _monthlyInvestment = 5000;
  double _expectedReturnRate = 12.0;
  int _years = 10;

  double _investedAmount = 0;
  double _estimatedReturns = 0;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateSip();
  }

  void _calculateSip() {
    // EXACT SAME LOGIC AS ORIGINAL
    final double monthlyRate = _expectedReturnRate / 12 / 100;
    final int months = _years * 12;

    double futureValue;
    if (monthlyRate == 0) {
      futureValue = _monthlyInvestment * months;
    } else {
      futureValue = _monthlyInvestment * 
          ((pow(1 + monthlyRate, months) - 1) / monthlyRate) * 
          (1 + monthlyRate);
    }
    
    final double totalInvestment = _monthlyInvestment * months;
    final double totalReturns = futureValue - totalInvestment;

    setState(() {
      _investedAmount = totalInvestment;
      _estimatedReturns = totalReturns;
      _totalValue = futureValue;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'sip',
      inputData: {
        'Monthly Investment': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_monthlyInvestment)}',
        'Expected Return Rate': '${_expectedReturnRate.toStringAsFixed(1)}%',
        'Investment Period': '$_years years',
      },
      resultData: {
        'Invested Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_investedAmount)}',
        'Estimated Returns': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_estimatedReturns)}',
        'Total Value': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalValue)}',
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
          'SIP Calculator',
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
            // Monthly Investment Slider
            ModernCalculatorSlider(
              label: 'Monthly Investment',
              value: _monthlyInvestment,
              min: 500,
              max: 100000,
              divisions: 199,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _monthlyInvestment = value;
                  _calculateSip();
                });
              },
            ),
            const SizedBox(height: 30),

            // Expected Return Rate Slider
            ModernCalculatorSlider(
              label: 'Expected Return Rate',
              value: _expectedReturnRate,
              min: 1.0,
              max: 30.0,
              divisions: 290,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _expectedReturnRate = value;
                  _calculateSip();
                });
              },
            ),
            const SizedBox(height: 30),

            // Investment Period Slider
            ModernCalculatorSlider(
              label: 'Investment Period',
              value: _years.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              suffix: ' Years',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _years = value.toInt();
                  _calculateSip();
                });
              },
            ),
            const SizedBox(height: 40),

            // Total Value Result Card
            ModernResultCard(
              title: 'TOTAL VALUE',
              amount: formatCurrency(_totalValue),
              subtitle: 'Estimated Returns: ${formatCurrency(_estimatedReturns)}',
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
                    'Estimated Returns',
                    formatCurrency(_estimatedReturns),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Investment Breakdown Chart
            _buildInvestmentBreakdown(themeProvider),
            const SizedBox(height: 24),

            // SIP Information Card
            _buildSipInfoCard(themeProvider),
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
                    title: '${((_investedAmount / _totalValue) * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF1E3A5F),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _estimatedReturns,
                    title: '${((_estimatedReturns / _totalValue) * 100).toStringAsFixed(1)}%',
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
              _buildLegendItem('Returns', Colors.green.shade400, themeProvider),
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

  Widget _buildSipInfoCard(ThemeProvider themeProvider) {
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
                'SIP Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Start with as low as ₹500/month'),
          _buildInfoRow('• Power of compounding grows wealth'),
          _buildInfoRow('• Disciplined investment approach'),
          _buildInfoRow('• Rupee cost averaging benefit'),
          _buildInfoRow('• Long-term wealth creation tool'),
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
