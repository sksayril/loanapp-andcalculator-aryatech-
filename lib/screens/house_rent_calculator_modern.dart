import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

class HouseRentCalculatorModern extends StatefulWidget {
  const HouseRentCalculatorModern({super.key});

  @override
  State<HouseRentCalculatorModern> createState() => _HouseRentCalculatorModernState();
}

class _HouseRentCalculatorModernState extends State<HouseRentCalculatorModern> {
  double _monthlyRent = 15000;
  int _months = 12;
  double _maintenance = 2000;
  double _deposit = 30000;
  double _otherCharges = 5000;

  double _totalRent = 0;
  double _maintenanceTotal = 0;
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _calculateRent();
  }

  void _calculateRent() {
    // EXACT SAME LOGIC AS ORIGINAL
    final totalRent = _monthlyRent * _months;
    final maintenanceTotal = _maintenance * _months;
    final grandTotal = totalRent + maintenanceTotal + _deposit + _otherCharges;

    setState(() {
      _totalRent = totalRent;
      _maintenanceTotal = maintenanceTotal;
      _grandTotal = grandTotal;
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'house_rent',
      inputData: {
        'Monthly Rent': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_monthlyRent)}',
        'Lease Duration': '$_months months',
        'Maintenance': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_maintenance)}/month',
        'Security Deposit': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_deposit)}',
        'Other Charges': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_otherCharges)}',
      },
      resultData: {
        'Total Rent': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalRent)}',
        'Total Maintenance': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_maintenanceTotal)}',
        'Security Deposit': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_deposit)}',
        'Other Charges': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_otherCharges)}',
        'Grand Total': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_grandTotal)}',
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
          'House Rent Calculator',
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
            // Monthly Rent Slider
            ModernCalculatorSlider(
              label: 'Monthly Rent',
              value: _monthlyRent,
              min: 5000,
              max: 200000,
              divisions: 195,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _monthlyRent = value;
                  _calculateRent();
                });
              },
            ),
            const SizedBox(height: 30),

            // Lease Duration Slider
            ModernCalculatorSlider(
              label: 'Lease Duration',
              value: _months.toDouble(),
              min: 1,
              max: 60,
              divisions: 59,
              suffix: ' Months',
              valueFormatter: (val) => val.toInt().toString(),
              onChanged: (value) {
                setState(() {
                  _months = value.toInt();
                  _calculateRent();
                });
              },
            ),
            const SizedBox(height: 30),

            // Maintenance Charges Slider
            ModernCalculatorSlider(
              label: 'Maintenance Charges (per month)',
              value: _maintenance,
              min: 0,
              max: 20000,
              divisions: 200,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _maintenance = value;
                  _calculateRent();
                });
              },
            ),
            const SizedBox(height: 30),

            // Security Deposit Slider
            ModernCalculatorSlider(
              label: 'Security Deposit',
              value: _deposit,
              min: 0,
              max: 500000,
              divisions: 100,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _deposit = value;
                  _calculateRent();
                });
              },
            ),
            const SizedBox(height: 30),

            // Other Charges Slider
            ModernCalculatorSlider(
              label: 'Other Charges (Brokerage, etc.)',
              value: _otherCharges,
              min: 0,
              max: 100000,
              divisions: 100,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _otherCharges = value;
                  _calculateRent();
                });
              },
            ),
            const SizedBox(height: 40),

            // Grand Total Result Card
            ModernResultCard(
              title: 'TOTAL COST',
              amount: formatCurrency(_grandTotal),
              subtitle: 'Total cost for $_months months lease',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Total Rent',
                    formatCurrency(_totalRent),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Total Maintenance',
                    formatCurrency(_maintenanceTotal),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Security Deposit',
                    formatCurrency(_deposit),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'Other Charges',
                    formatCurrency(_otherCharges),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cost Breakdown Chart
            _buildCostBreakdown(themeProvider),
            const SizedBox(height: 24),

            // Rent Information Card
            _buildRentInfoCard(themeProvider),
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

  Widget _buildCostBreakdown(ThemeProvider themeProvider) {
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
            'Cost Breakdown',
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
                    value: _totalRent,
                    title: '${((_totalRent / _grandTotal) * 100).toStringAsFixed(1)}%',
                    color: Colors.deepPurple.shade400,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_maintenanceTotal > 0)
                    PieChartSectionData(
                      value: _maintenanceTotal,
                      title: '${((_maintenanceTotal / _grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.purple.shade300,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (_deposit > 0)
                    PieChartSectionData(
                      value: _deposit,
                      title: '${((_deposit / _grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.blue.shade400,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (_otherCharges > 0)
                    PieChartSectionData(
                      value: _otherCharges,
                      title: '${((_otherCharges / _grandTotal) * 100).toStringAsFixed(1)}%',
                      color: Colors.amber.shade400,
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
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildLegendItem('Rent', Colors.deepPurple.shade400, themeProvider),
              if (_maintenanceTotal > 0)
                _buildLegendItem('Maintenance', Colors.purple.shade300, themeProvider),
              if (_deposit > 0)
                _buildLegendItem('Deposit', Colors.blue.shade400, themeProvider),
              if (_otherCharges > 0)
                _buildLegendItem('Others', Colors.amber.shade400, themeProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeProvider themeProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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

  Widget _buildRentInfoCard(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.deepPurple.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'House Rent Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• Security deposit is refundable'),
          _buildInfoRow('• Maintenance charges are monthly'),
          _buildInfoRow('• Include brokerage in other charges'),
          _buildInfoRow('• Plan for advance rent if required'),
          _buildInfoRow('• Budget for moving and initial setup'),
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
          color: Colors.deepPurple.shade900,
          height: 1.4,
        ),
      ),
    );
  }
}
