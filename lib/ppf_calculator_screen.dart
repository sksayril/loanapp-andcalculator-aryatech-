import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class PpfCalculatorScreen extends StatefulWidget {
  const PpfCalculatorScreen({super.key});

  @override
  State<PpfCalculatorScreen> createState() => _PpfCalculatorScreenState();
}

class _PpfCalculatorScreenState extends State<PpfCalculatorScreen> {
  final _yearlyInvestmentController = TextEditingController();
  final _returnRateController = TextEditingController();
  final _investmentPeriodController = TextEditingController();

  double _investedAmount = 0;
  double _totalInterest = 0;
  double _maturityValue = 0;

  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  void _calculatePpf() {
    final double? yearlyInvestment = double.tryParse(_yearlyInvestmentController.text);
    final double? annualRate = double.tryParse(_returnRateController.text);
    final int? years = int.tryParse(_investmentPeriodController.text);

    if (yearlyInvestment == null || annualRate == null || years == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid investment, rate, and period.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double balance = 0;
    for (int i = 0; i < years; i++) {
      balance += yearlyInvestment;
      double interestEarned = balance * (annualRate / 100);
      balance += interestEarned;
    }

    setState(() {
      _investedAmount = yearlyInvestment * years;
      _maturityValue = balance;
      _totalInterest = _maturityValue - _investedAmount;
    });

    _showPpfSummaryModal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PPF Calculator'),
        backgroundColor: Colors.purple.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: _yearlyInvestmentController,
              label: 'Yearly Investment',
              icon: Icons.account_balance_wallet,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _returnRateController,
              label: 'Interest Rate (%)',
              icon: Icons.trending_up,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _investmentPeriodController,
              label: 'Investment Period (Years)',
              icon: Icons.calendar_today,
              isYears: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculatePpf,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade400,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
    bool isYears = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !isYears),
      inputFormatters: [
        if (isYears)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple.shade300),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
        ),
      ),
    );
  }

  void _showPpfSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildPpfSummaryModal(),
    );
  }

  Widget _buildPpfSummaryModal() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Text(
                  'PPF Calculation Summary',
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
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Invested Amount', _investedAmount),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Total Interest', _totalInterest),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Maturity Value', _maturityValue, isTotal: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
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
                            const Text(
                              'Investment Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 220,
                              child: _buildPieChart(),
                            ),
                            const SizedBox(height: 16),
                            _buildLegend(),
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

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? Colors.purple.shade700 : Colors.grey.shade800,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: isTotal ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.purple.shade700 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    if (_maturityValue <= 0) {
      return const Center(child: Text('Enter values to view chart'));
    }

    final sections = [
      PieChartSectionData(
        value: _investedAmount,
        title: '${((_investedAmount / _maturityValue) * 100).toStringAsFixed(1)}%',
        color: Colors.purple.shade400,
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: _totalInterest,
        title: '${((_totalInterest / _maturityValue) * 100).toStringAsFixed(1)}%',
        color: Colors.pinkAccent.shade200,
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 50,
        sectionsSpace: 4,
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      {'label': 'Invested Amount', 'value': _investedAmount, 'color': Colors.purple.shade400},
      {'label': 'Interest Earned', 'value': _totalInterest, 'color': Colors.pinkAccent.shade200},
    ];

    return Column(
      children: items.map((item) {
        if ((item['value'] as double) <= 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item['color'] as Color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Text(
                _currency.format(item['value'] as double),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
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
    _yearlyInvestmentController.dispose();
    _returnRateController.dispose();
    _investmentPeriodController.dispose();
    super.dispose();
  }
}
