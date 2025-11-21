import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'providers/theme_provider.dart';

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  final _monthlyInvestmentController = TextEditingController();
  final _returnRateController = TextEditingController();
  final _investmentPeriodController = TextEditingController();

  double _investedAmount = 0;
  double _estimatedReturns = 0;
  double _totalValue = 0;

  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  void _calculateSip() {
    final double? monthlyInvestment = double.tryParse(_monthlyInvestmentController.text);
    final double? annualRate = double.tryParse(_returnRateController.text);
    final int? years = int.tryParse(_investmentPeriodController.text);

    if (monthlyInvestment == null || annualRate == null || years == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid investment, rate, and period.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double monthlyRate = annualRate / 12 / 100;
    final int months = years * 12;

    double futureValue;
    if (monthlyRate == 0) {
      futureValue = monthlyInvestment * months;
    } else {
      futureValue = monthlyInvestment * ((pow(1 + monthlyRate, months) - 1) / monthlyRate) * (1 + monthlyRate);
    }
    final double totalInvestment = monthlyInvestment * months;
    final double totalReturns = futureValue - totalInvestment;

    setState(() {
      _investedAmount = totalInvestment;
      _estimatedReturns = totalReturns;
      _totalValue = futureValue;
    });

    _showSipSummaryModal();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Systematic Investment Plan'),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.blue.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.trending_up,
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
                              'SIP Calculator',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Calculate your future wealth',
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _monthlyInvestmentController,
              label: 'Monthly Investment (₹)',
              icon: Icons.monetization_on,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _returnRateController,
              label: 'Expected Return Rate (%)',
              icon: Icons.trending_up,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _investmentPeriodController,
              label: 'Investment Period (Years)',
              icon: Icons.calendar_today,
              isYears: true,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateSip,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
    bool isYears = false,
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
        keyboardType: TextInputType.numberWithOptions(decimal: !isYears),
        style: TextStyle(color: themeProvider.textPrimary),
        inputFormatters: [
          if (isYears)
            FilteringTextInputFormatter.digitsOnly
          else
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.textSecondary),
          hintStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(icon, color: Colors.blue.shade400),
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
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
    );
  }

  void _showSipSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSipSummaryModal(),
    );
  }

  Widget _buildSipSummaryModal() {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Text(
                  'SIP Calculation Summary',
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
                            _buildSummaryRow('Total Invested', _investedAmount, themeProvider),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Estimated Returns', _estimatedReturns, themeProvider),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Total Value', _totalValue, themeProvider, isTotal: true),
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
                              'Investment Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 250,
                              child: _buildPieChart(),
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

  Widget _buildSummaryRow(String label, double value, ThemeProvider themeProvider, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.blue.shade700 : themeProvider.textPrimary,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: isTotal ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.blue.shade700 : themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    if (_totalValue <= 0) {
      return Center(
        child: Text(
          'Enter values to view chart',
          style: TextStyle(
            color: themeProvider.textSecondary,
          ),
        ),
      );
    }

    final investedPercentage = (_investedAmount / _totalValue) * 100;
    final returnsPercentage = (_estimatedReturns / _totalValue) * 100;

    final sections = [
      PieChartSectionData(
        value: _investedAmount,
        title: '${investedPercentage.toStringAsFixed(1)}%',
        color: Colors.blue.shade500,
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: _estimatedReturns,
        title: '${returnsPercentage.toStringAsFixed(1)}%',
        color: Colors.teal.shade400,
        radius: 80,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 60,
        sectionsSpace: 3,
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeProvider themeProvider) {
    final items = [
      {'label': 'Total Invested', 'value': _investedAmount, 'color': Colors.blue.shade500},
      {'label': 'Estimated Returns', 'value': _estimatedReturns, 'color': Colors.teal.shade400},
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
                    fontSize: 15,
                    color: themeProvider.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _currency.format(item['value'] as double),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _monthlyInvestmentController.dispose();
    _returnRateController.dispose();
    _investmentPeriodController.dispose();
    super.dispose();
  }
}
