import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class GoalCalculatorModern extends StatefulWidget {
  const GoalCalculatorModern({super.key});

  @override
  State<GoalCalculatorModern> createState() => _GoalCalculatorModernState();
}

class _GoalCalculatorModernState extends State<GoalCalculatorModern> {
  double _goalAmount = 1000000;
  double _expectedReturn = 12.0;
  int _years = 10;

  double _requiredSip = 0;
  double _totalInvestment = 0;
  double _estimatedGrowth = 0;

  @override
  void initState() {
    super.initState();
    _calculateGoal();
  }

  void _calculateGoal() {
    // EXACT SAME LOGIC AS ORIGINAL
    final months = (_years * 12).round();
    final monthlyRate = _expectedReturn / 12 / 100;

    double sip;
    if (monthlyRate == 0) {
      sip = _goalAmount / months;
    } else {
      final factor = pow(1 + monthlyRate, months) - 1;
      sip = _goalAmount * monthlyRate / factor;
    }

    final totalInvestment = sip * months;
    final estimatedGrowth = _goalAmount - totalInvestment;

    setState(() {
      _requiredSip = sip;
      _totalInvestment = totalInvestment;
      _estimatedGrowth = estimatedGrowth;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'goal',
      inputData: {
        'Goal Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_goalAmount)}',
        'Expected Return': '${_expectedReturn.toStringAsFixed(1)}%',
        'Time Horizon': '$_years years',
      },
      resultData: {
        'Required Monthly SIP': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_requiredSip)}',
        'Total Investment': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalInvestment)}',
        'Estimated Growth': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_estimatedGrowth)}',
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
          'Goal Calculator',
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
            // Goal Amount Slider
            ModernCalculatorSlider(
              label: 'Goal Amount',
              value: _goalAmount,
              min: 100000,
              max: 50000000,
              divisions: 499,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _goalAmount = value;
                  _calculateGoal();
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
                  _calculateGoal();
                });
              },
            ),
            const SizedBox(height: 30),

            // Time Horizon Slider
            ModernCalculatorSlider(
              label: 'Time Horizon',
              value: _years.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              suffix: ' Years',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _years = value.toInt();
                  _calculateGoal();
                });
              },
            ),
            const SizedBox(height: 40),

            // Required SIP Result Card
            ModernResultCard(
              title: 'REQUIRED MONTHLY SIP',
              amount: formatCurrency(_requiredSip),
              subtitle: 'To reach your goal of ${formatCurrency(_goalAmount)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total Investment',
                    formatCurrency(_totalInvestment),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Estimated Growth',
                    formatCurrency(_estimatedGrowth),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Goal Breakdown Chart
            _buildGoalBreakdown(themeProvider),
            const SizedBox(height: 24),

            // Goal Information Card
            _buildGoalInfoCard(themeProvider),
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

  Widget _buildGoalBreakdown(ThemeProvider themeProvider) {
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
            'Goal Breakdown',
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
                    value: _totalInvestment,
                    title: '${((_totalInvestment / _goalAmount) * 100).toStringAsFixed(1)}%',
                    color: const Color(0xFF1E3A5F),
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: _estimatedGrowth,
                    title: '${((_estimatedGrowth / _goalAmount) * 100).toStringAsFixed(1)}%',
                    color: Colors.indigo.shade400,
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
              _buildLegendItem('Investment', const Color(0xFF1E3A5F), themeProvider),
              _buildLegendItem('Growth', Colors.indigo.shade400, themeProvider),
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

  Widget _buildGoalInfoCard(ThemeProvider themeProvider) {
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
                'Goal Planning Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Set specific financial targets'),
          _buildInfoRow('• Plan monthly investments systematically'),
          _buildInfoRow('• Track progress towards your goal'),
          _buildInfoRow('• Adjust strategy based on returns'),
          _buildInfoRow('• Achieve dreams with disciplined investing'),
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
