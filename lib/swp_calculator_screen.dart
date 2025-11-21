import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

class SwpCalculatorScreen extends StatefulWidget {
  const SwpCalculatorScreen({super.key});

  @override
  State<SwpCalculatorScreen> createState() => _SwpCalculatorScreenState();
}

class _SwpCalculatorScreenState extends State<SwpCalculatorScreen> {
  final TextEditingController _investmentController = TextEditingController();
  final TextEditingController _withdrawalController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  double _endingCorpus = 0;
  double _totalWithdrawn = 0;
  int _monthsCovered = 0;
  bool _ranOutOfFunds = false;

  final NumberFormat _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  @override
  void dispose() {
    _investmentController.dispose();
    _withdrawalController.dispose();
    _rateController.dispose();
    _yearsController.dispose();
    super.dispose();
  }

  void _calculateSwp() {
    final investment = double.tryParse(_investmentController.text.replaceAll(',', '')) ?? 0;
    final withdrawal = double.tryParse(_withdrawalController.text.replaceAll(',', '')) ?? 0;
    final annualRate = double.tryParse(_rateController.text) ?? 0;
    final years = double.tryParse(_yearsController.text) ?? 0;

    if (investment <= 0 || withdrawal <= 0 || annualRate < 0 || years <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid values for all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final months = (years * 12).round();
    final monthlyRate = annualRate / 12 / 100;

    double corpus = investment;
    double totalWithdrawals = 0;
    bool depleted = false;
    int i = 0;

    for (i = 0; i < months; i++) {
      corpus = corpus * (1 + monthlyRate);
      if (corpus <= withdrawal) {
        totalWithdrawals += corpus;
        corpus = 0;
        depleted = true;
        i++;
        break;
      } else {
        corpus -= withdrawal;
        totalWithdrawals += withdrawal;
      }
    }

    setState(() {
      _endingCorpus = corpus;
      _totalWithdrawn = totalWithdrawals;
      _monthsCovered = i;
      _ranOutOfFunds = depleted;
    });

    _showSwpSummaryModal();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: const Text('Systematic Withdrawal Plan'),
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
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _investmentController,
              label: 'Initial Investment (₹)',
              icon: Icons.account_balance_wallet,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _withdrawalController,
              label: 'Monthly Withdrawal (₹)',
              icon: Icons.payments,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _rateController,
              label: 'Expected Annual Return (%)',
              icon: Icons.trending_up,
              themeProvider: themeProvider,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _yearsController,
              label: 'Duration (Years)',
              icon: Icons.calendar_today,
              themeProvider: themeProvider,
              isNumericOnly: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateSwp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade500,
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

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade400,
            Colors.teal.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
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
              Icons.payments,
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
                  'Systematic Withdrawal Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Plan your monthly withdrawals smartly',
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
    bool isNumericOnly = false,
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
        keyboardType: TextInputType.numberWithOptions(decimal: !isNumericOnly),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(icon, color: Colors.green.shade400),
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
            borderSide: const BorderSide(color: Colors.green, width: 2),
          ),
        ),
      ),
    );
  }

  void _showSwpSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildSwpSummaryModal(),
    );
  }

  Widget _buildSwpSummaryModal() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sustainText = _monthsCovered == 0
        ? 'Less than 1 month'
        : '${(_monthsCovered / 12).toStringAsFixed(1)} years ($_monthsCovered months)';

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
                    colors: [Colors.green.shade400, Colors.teal.shade500],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Text(
                  'SWP Summary',
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
                            _buildSummaryRow('Total Withdrawn', _totalWithdrawn, themeProvider),
                            const Divider(height: 24),
                            _buildSummaryRow('Remaining Corpus', _endingCorpus, themeProvider),
                            const Divider(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Plan Sustains For',
                                        style: TextStyle(
                                          color: themeProvider.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sustainText,
                                        style: TextStyle(
                                          color: themeProvider.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  _ranOutOfFunds ? Icons.warning_amber : Icons.check_circle,
                                  color: _ranOutOfFunds ? Colors.orange : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _ranOutOfFunds
                                        ? 'Corpus gets exhausted before the selected duration.'
                                        : 'Corpus sustains for the full selected duration.',
                                    style: TextStyle(
                                      color: _ranOutOfFunds ? Colors.orange : Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
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
                              'Withdrawal Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: _buildPieChart(themeProvider),
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

  Widget _buildSummaryRow(String label, double value, ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: themeProvider.textSecondary,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(ThemeProvider themeProvider) {
    if (_totalWithdrawn <= 0 && _endingCorpus <= 0) {
      return Center(
        child: Text(
          'Enter values to view chart',
          style: TextStyle(color: themeProvider.textSecondary),
        ),
      );
    }

    final sections = <PieChartSectionData>[
      if (_totalWithdrawn > 0)
        PieChartSectionData(
          value: _totalWithdrawn,
          title: 'Withdrawn',
          color: Colors.green.shade500,
          radius: 80,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      if (_endingCorpus > 0)
        PieChartSectionData(
          value: _endingCorpus,
          title: 'Corpus',
          color: Colors.teal.shade400,
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
      {'label': 'Total Withdrawn', 'value': _totalWithdrawn, 'color': Colors.green.shade500},
      {'label': 'Remaining Corpus', 'value': _endingCorpus, 'color': Colors.teal.shade400},
    ];

    return Column(
      children: items.map((item) {
        if ((item['value'] as double) <= 0) {
          return const SizedBox.shrink();
        }
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

