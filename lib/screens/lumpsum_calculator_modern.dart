import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class LumpsumCalculatorModern extends StatefulWidget {
  const LumpsumCalculatorModern({super.key});

  @override
  State<LumpsumCalculatorModern> createState() => _LumpsumCalculatorModernState();
}

class _LumpsumCalculatorModernState extends State<LumpsumCalculatorModern> {
  double _investmentAmount = 100000;
  double _expectedReturn = 12.0;
  int _years = 10;

  double _futureValue = 0;
  double _totalGain = 0;

  @override
  void initState() {
    super.initState();
    _calculateLumpsum();
  }

  void _calculateLumpsum() {
    // EXACT SAME LOGIC AS ORIGINAL
    final futureValue = _investmentAmount * pow(1 + _expectedReturn / 100, _years);

    setState(() {
      _futureValue = futureValue;
      _totalGain = futureValue - _investmentAmount;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'lumpsum',
      inputData: {
        'Investment Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_investmentAmount)}',
        'Expected Return': '${_expectedReturn.toStringAsFixed(1)}%',
        'Duration': '$_years years',
      },
      resultData: {
        'Investment Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_investmentAmount)}',
        'Total Gain': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalGain)}',
        'Future Value': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_futureValue)}',
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
          'Lumpsum Calculator',
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
            // Investment Amount Slider
            ModernCalculatorSlider(
              label: 'Investment Amount',
              value: _investmentAmount,
              min: 10000,
              max: 10000000,
              divisions: 199,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _investmentAmount = value;
                  _calculateLumpsum();
                });
              },
            ),
            const SizedBox(height: 30),

            // Expected Return Rate Slider
            ModernCalculatorSlider(
              label: 'Expected Annual Return',
              value: _expectedReturn,
              min: 1.0,
              max: 30.0,
              divisions: 290,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _expectedReturn = value;
                  _calculateLumpsum();
                });
              },
            ),
            const SizedBox(height: 30),

            // Investment Duration Slider
            ModernCalculatorSlider(
              label: 'Investment Duration',
              value: _years.toDouble(),
              min: 1,
              max: 40,
              divisions: 39,
              suffix: ' Years',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _years = value.toInt();
                  _calculateLumpsum();
                });
              },
            ),
            const SizedBox(height: 40),

            // Future Value Result Card
            ModernResultCard(
              title: 'FUTURE VALUE',
              amount: formatCurrency(_futureValue),
              subtitle: 'Total Gain: ${formatCurrency(_totalGain)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Investment',
                    formatCurrency(_investmentAmount),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Total Gain',
                    formatCurrency(_totalGain),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Investment Breakdown Chart
            _buildInvestmentBreakdown(themeProvider),
            const SizedBox(height: 24),

            // Lumpsum Information Card
            _buildLumpsumInfoCard(themeProvider),
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
                    value: _investmentAmount,
                    title: '${((_investmentAmount / _futureValue) * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF1E3A5F),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _totalGain,
                    title: '${((_totalGain / _futureValue) * 100).toStringAsFixed(1)}%',
                    color: Colors.deepOrange.shade400,
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
              _buildLegendItem('Returns', Colors.deepOrange.shade400, themeProvider),
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

  Widget _buildLumpsumInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepOrange.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.deepOrange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Lumpsum Investment Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• One-time investment opportunity'),
          _buildInfoRow('• Power of compounding over time'),
          _buildInfoRow('• Ideal when you have surplus funds'),
          _buildInfoRow('• No regular commitment needed'),
          _buildInfoRow('• Long-term wealth creation'),
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
          color: Colors.deepOrange.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
