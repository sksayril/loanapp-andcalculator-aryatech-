import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HouseRentCalculatorScreen extends StatefulWidget {
  const HouseRentCalculatorScreen({super.key});

  @override
  State<HouseRentCalculatorScreen> createState() => _HouseRentCalculatorScreenState();
}

class _HouseRentCalculatorScreenState extends State<HouseRentCalculatorScreen> {
  final _monthlyRentController = TextEditingController();
  final _monthsController = TextEditingController(text: '12');
  final _maintenanceController = TextEditingController(text: '0');
  final _depositController = TextEditingController(text: '0');
  final _otherChargesController = TextEditingController(text: '0');

  double _totalRent = 0;
  double _maintenanceTotal = 0;
  double _depositAmount = 0;
  double _otherCharges = 0;
  double _grandTotal = 0;

  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  void _calculateRent() {
    final monthlyRent = double.tryParse(_monthlyRentController.text) ?? 0;
    final months = int.tryParse(_monthsController.text) ?? 0;
    final maintenance = double.tryParse(_maintenanceController.text) ?? 0;
    final deposit = double.tryParse(_depositController.text) ?? 0;
    final otherCharges = double.tryParse(_otherChargesController.text) ?? 0;

    if (monthlyRent <= 0 || months <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid monthly rent and months.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalRent = monthlyRent * months;
    final maintenanceTotal = maintenance * months;
    final grandTotal = totalRent + maintenanceTotal + deposit + otherCharges;

    setState(() {
      _totalRent = totalRent;
      _maintenanceTotal = maintenanceTotal;
      _depositAmount = deposit;
      _otherCharges = otherCharges;
      _grandTotal = grandTotal;
    });

    // Show modal with results
    _showRentSummaryModal();
  }

  void _showRentSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRentSummaryModal(),
    );
  }

  @override
  void dispose() {
    _monthlyRentController.dispose();
    _monthsController.dispose();
    _maintenanceController.dispose();
    _depositController.dispose();
    _otherChargesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('House Rent Calculator'),
        backgroundColor: Colors.deepPurple.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildInputField(
              controller: _monthlyRentController,
              label: 'Monthly Rent (₹)',
              icon: Icons.home,
              hint: 'Enter monthly rent',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _monthsController,
              label: 'Lease Duration (Months)',
              icon: Icons.calendar_today,
              hint: 'e.g., 12',
              isInteger: true,
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _maintenanceController,
              label: 'Maintenance Charges (₹ / month)',
              icon: Icons.build,
              hint: 'Enter maintenance charges',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _depositController,
              label: 'Security Deposit (₹)',
              icon: Icons.security,
              hint: 'Enter deposit amount',
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _otherChargesController,
              label: 'Other Charges (₹)',
              icon: Icons.receipt_long,
              hint: 'Brokerage, advance rent, etc.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculateRent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Calculate Rent Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.apartment,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Plan Your Rent Budget',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimate yearly rent payouts with deposits & charges.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
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
    required String hint,
    bool isInteger = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        isInteger
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.deepPurple.shade300),
        filled: true,
        fillColor: Colors.grey.shade50,
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
          borderSide: BorderSide(color: Colors.deepPurple.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildRentSummaryModal() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade400,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: const Text(
                  'Calculate Rent Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Rent Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.deepPurple.shade100, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with icon
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade400,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.bar_chart,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Rent Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _buildResultRow('Total Rent Payable', _totalRent),
                            const Divider(height: 24, thickness: 1),
                            _buildResultRow('Maintenance Total', _maintenanceTotal),
                            const Divider(height: 24, thickness: 1),
                            _buildResultRow('Security Deposit', _depositAmount),
                            const Divider(height: 24, thickness: 1),
                            _buildResultRow('Other Charges', _otherCharges),
                            const SizedBox(height: 16),
                            // Grand Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Grand Total Payable',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _currency.format(_grandTotal),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Pie Chart Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Expense Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 250,
                              child: _buildPieChart(),
                            ),
                            const SizedBox(height: 20),
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

  Widget _buildPieChart() {
    final List<PieChartSectionData> sections = [];
    
    if (_grandTotal > 0) {
      final colors = [
        Colors.deepPurple,
        Colors.deepOrange,
        Colors.teal,
        Colors.amber.shade600,
      ];
      
      final values = [_totalRent, _maintenanceTotal, _depositAmount, _otherCharges];
      final labels = ['Rent', 'Maintenance', 'Deposit', 'Other'];
      
      for (int i = 0; i < values.length; i++) {
        if (values[i] > 0) {
          final percentage = (values[i] / _grandTotal) * 100;
          sections.add(
            PieChartSectionData(
              value: values[i],
              title: '${percentage.toStringAsFixed(1)}%',
              color: colors[i],
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          );
        }
      }
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 50,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      {'label': 'Total Rent Payable', 'value': _totalRent, 'color': Colors.deepPurple},
      {'label': 'Maintenance Total', 'value': _maintenanceTotal, 'color': Colors.deepOrange},
      {'label': 'Security Deposit', 'value': _depositAmount, 'color': Colors.teal},
      {'label': 'Other Charges', 'value': _otherCharges, 'color': Colors.amber.shade600},
    ];

    return Column(
      children: items.map((item) {
        if (item['value'] as double <= 0) return const SizedBox.shrink();
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
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade600,
          ),
        ),
      ],
    );
  }
}

