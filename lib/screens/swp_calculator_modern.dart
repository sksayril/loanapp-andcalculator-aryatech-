import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class SwpCalculatorModern extends StatefulWidget {
  const SwpCalculatorModern({super.key});

  @override
  State<SwpCalculatorModern> createState() => _SwpCalculatorModernState();
}

class _SwpCalculatorModernState extends State<SwpCalculatorModern> {
  double _initialInvestment = 500000;
  double _monthlyWithdrawal = 5000;
  double _expectedReturn = 10.0;
  int _years = 10;

  double _endingCorpus = 0;
  double _totalWithdrawn = 0;
  int _monthsCovered = 0;
  bool _ranOutOfFunds = false;

  @override
  void initState() {
    super.initState();
    _calculateSwp();
  }

  void _calculateSwp() {
    // EXACT SAME LOGIC AS ORIGINAL
    final months = (_years * 12).round();
    final monthlyRate = _expectedReturn / 12 / 100;

    double corpus = _initialInvestment;
    double totalWithdrawals = 0;
    bool depleted = false;
    int i = 0;

    for (i = 0; i < months; i++) {
      corpus = corpus * (1 + monthlyRate);
      if (corpus <= _monthlyWithdrawal) {
        totalWithdrawals += corpus;
        corpus = 0;
        depleted = true;
        i++;
        break;
      } else {
        corpus -= _monthlyWithdrawal;
        totalWithdrawals += _monthlyWithdrawal;
      }
    }

    setState(() {
      _endingCorpus = corpus;
      _totalWithdrawn = totalWithdrawals;
      _monthsCovered = i;
      _ranOutOfFunds = depleted;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'swp',
      inputData: {
        'Initial Investment': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_initialInvestment)}',
        'Monthly Withdrawal': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_monthlyWithdrawal)}',
        'Expected Return': '${_expectedReturn.toStringAsFixed(1)}%',
        'Duration': '$_years years',
      },
      resultData: {
        'Total Withdrawn': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalWithdrawn)}',
        'Ending Corpus': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_endingCorpus)}',
        'Months Covered': '$_monthsCovered months',
        'Status': _ranOutOfFunds ? 'Funds Depleted' : 'Funds Available',
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
          'SWP Calculator',
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
            // Initial Investment Slider
            ModernCalculatorSlider(
              label: 'Initial Investment',
              value: _initialInvestment,
              min: 50000,
              max: 10000000,
              divisions: 199,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _initialInvestment = value;
                  _calculateSwp();
                });
              },
            ),
            const SizedBox(height: 30),

            // Monthly Withdrawal Slider
            ModernCalculatorSlider(
              label: 'Monthly Withdrawal',
              value: _monthlyWithdrawal,
              min: 1000,
              max: 200000,
              divisions: 199,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _monthlyWithdrawal = value;
                  _calculateSwp();
                });
              },
            ),
            const SizedBox(height: 30),

            // Expected Return Slider
            ModernCalculatorSlider(
              label: 'Expected Annual Return',
              value: _expectedReturn,
              min: 1.0,
              max: 20.0,
              divisions: 190,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _expectedReturn = value;
                  _calculateSwp();
                });
              },
            ),
            const SizedBox(height: 30),

            // Duration Slider
            ModernCalculatorSlider(
              label: 'Duration',
              value: _years.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              suffix: ' Years',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _years = value.toInt();
                  _calculateSwp();
                });
              },
            ),
            const SizedBox(height: 40),

            // Warning if funds run out
            if (_ranOutOfFunds)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Funds will be depleted after $_monthsCovered months (${(_monthsCovered / 12).toStringAsFixed(1)} years)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Ending Corpus Result Card
            ModernResultCard(
              title: _ranOutOfFunds ? 'FUNDS DEPLETED' : 'ENDING CORPUS',
              amount: formatCurrency(_endingCorpus),
              subtitle: 'Total Withdrawn: ${formatCurrency(_totalWithdrawn)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total Withdrawn',
                    formatCurrency(_totalWithdrawn),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Months Covered',
                    '$_monthsCovered',
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Withdrawal Breakdown Chart
            _buildWithdrawalBreakdown(themeProvider),
            const SizedBox(height: 24),

            // SWP Information Card
            _buildSwpInfoCard(themeProvider),
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

  Widget _buildWithdrawalBreakdown(ThemeProvider themeProvider) {
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
            'Withdrawal vs Remaining',
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
                    value: _totalWithdrawn,
                    title: '${((_totalWithdrawn / (_totalWithdrawn + _endingCorpus)) * 100).toStringAsFixed(1)}%',
                    color: Colors.red.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_endingCorpus > 0)
                    PieChartSectionData(
                      value: _endingCorpus,
                      title: '${((_endingCorpus / (_totalWithdrawn + _endingCorpus)) * 100).toStringAsFixed(1)}%',
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
              _buildLegendItem('Withdrawn', Colors.red.shade400, themeProvider),
              if (_endingCorpus > 0)
                _buildLegendItem('Remaining', Colors.green.shade400, themeProvider),
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

  Widget _buildSwpInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'SWP Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Regular income from investments'),
          _buildInfoRow('• Tax-efficient withdrawal strategy'),
          _buildInfoRow('• Remaining corpus continues to grow'),
          _buildInfoRow('• Flexible withdrawal amounts'),
          _buildInfoRow('• Ideal for retirement planning'),
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
          color: Colors.green.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
