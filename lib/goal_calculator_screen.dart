import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class GoalCalculatorScreen extends StatefulWidget {
  const GoalCalculatorScreen({super.key});

  @override
  State<GoalCalculatorScreen> createState() => _GoalCalculatorScreenState();
}

class _GoalCalculatorScreenState extends State<GoalCalculatorScreen> {
  final TextEditingController _goalAmountController = TextEditingController();
  final TextEditingController _expectedReturnController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _requiredSip = 0;
  double _totalInvestment = 0;
  double _estimatedGrowth = 0;

  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void dispose() {
    _goalAmountController.dispose();
    _expectedReturnController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculateGoal() {
    final goal = double.tryParse(_goalAmountController.text.replaceAll(',', '')) ?? 0;
    final annualReturn = double.tryParse(_expectedReturnController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;

    if (goal <= 0 || annualReturn <= 0 || years <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values for all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final months = (years * 12).round();
    final monthlyRate = annualReturn / 12 / 100;

    double sip;
    if (monthlyRate == 0) {
      sip = goal / months;
    } else {
      final factor = pow(1 + monthlyRate, months) - 1;
      sip = goal * monthlyRate / factor;
    }

    final totalInvestment = sip * months;
    final estimatedGrowth = goal - totalInvestment;

    setState(() {
      _requiredSip = sip;
      _totalInvestment = totalInvestment;
      _estimatedGrowth = estimatedGrowth;
    });

    _showSummaryModal();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Goal Calculator'),
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        titleTextStyle: TextStyle(
          color: themeProvider.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(themeProvider),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _goalAmountController,
              label: 'Goal Amount (₹)',
              icon: Icons.flag,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _expectedReturnController,
              label: 'Expected Annual Return (%)',
              icon: Icons.trending_up,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _yearsController,
              label: 'Time Horizon (Years)',
              icon: Icons.calendar_today,
              themeProvider: themeProvider,
              isInteger: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade400,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5DADE2),
            Color(0xFF4A6CF7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
              Icons.flag_circle,
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
                  'Plan your financial goals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Know how much you need to invest monthly',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool isInteger = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(icon, color: Colors.indigo.shade400),
          filled: true,
          fillColor: themeProvider.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: themeProvider.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 2),
          ),
        ),
      ),
    );
  }

  void _showSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GoalSummarySheet(
        requiredSip: _requiredSip,
        totalInvestment: _totalInvestment,
        estimatedGrowth: _estimatedGrowth,
      ),
    );
  }
}

class _GoalSummarySheet extends StatelessWidget {
  final double requiredSip;
  final double totalInvestment;
  final double estimatedGrowth;
  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  _GoalSummarySheet({
    required this.requiredSip,
    required this.totalInvestment,
    required this.estimatedGrowth,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final totalFutureValue = totalInvestment + estimatedGrowth;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.cardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5DADE2), Color(0xFF4A6CF7)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Text(
                  'Goal Summary',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeProvider.borderColor),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              'Required Monthly SIP',
                              requiredSip,
                              themeProvider,
                              isHighlight: true,
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'Total Invested',
                              totalInvestment,
                              themeProvider,
                            ),
                            const Divider(height: 24),
                            _buildSummaryRow(
                              'Estimated Growth',
                              estimatedGrowth,
                              themeProvider,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: themeProvider.cardBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: themeProvider.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Goal Coverage',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: _buildPieChart(themeProvider, totalFutureValue),
                            ),
                            const SizedBox(height: 20),
                            _buildLegend(themeProvider),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String title, double value, ThemeProvider themeProvider, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            color: isHighlight ? Colors.indigo.shade400 : themeProvider.textSecondary,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: isHighlight ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.indigo.shade400 : themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(ThemeProvider themeProvider, double totalFutureValue) {
    if (totalFutureValue <= 0) {
      return Center(
        child: Text(
          'Enter values to view chart',
          style: TextStyle(color: themeProvider.textSecondary),
        ),
      );
    }

    final sections = [
      PieChartSectionData(
        value: totalInvestment,
        title: '${((totalInvestment / totalFutureValue) * 100).toStringAsFixed(1)}%',
        color: Colors.indigo.shade400,
        radius: 80,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: estimatedGrowth,
        title: '${((estimatedGrowth / totalFutureValue) * 100).toStringAsFixed(1)}%',
        color: Colors.blue.shade300,
        radius: 80,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 60,
        sectionsSpace: 3,
      ),
    );
  }

  Widget _buildLegend(ThemeProvider themeProvider) {
    final items = [
      {'label': 'Total Invested', 'value': totalInvestment, 'color': Colors.indigo.shade400},
      {'label': 'Growth', 'value': estimatedGrowth, 'color': Colors.blue.shade300},
    ];

    return Column(
      children: items.map((item) {
        if ((item['value'] as double) <= 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _currency.format(item['value'] as double),
                style: TextStyle(
                  color: themeProvider.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

