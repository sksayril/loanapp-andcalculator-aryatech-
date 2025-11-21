import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class VatCalculatorScreen extends StatefulWidget {
  const VatCalculatorScreen({super.key});

  @override
  State<VatCalculatorScreen> createState() => _VatCalculatorScreenState();
}

enum VatType { add, remove }

class _VatCalculatorScreenState extends State<VatCalculatorScreen> {
  final _amountController = TextEditingController();
  final _vatRateController = TextEditingController();
  VatType _vatType = VatType.add;

  double _netAmount = 0;
  double _vatAmount = 0;
  double _totalAmount = 0;

  final _currency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

  void _calculateVat() {
    final double? initialAmount = double.tryParse(_amountController.text);
    final double? vatRate = double.tryParse(_vatRateController.text);

    if (initialAmount == null || vatRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid amount and VAT rate.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      if (_vatType == VatType.add) {
        // 'initialAmount' is the net amount, we add VAT to it
        _netAmount = initialAmount;
        _vatAmount = _netAmount * (vatRate / 100);
        _totalAmount = _netAmount + _vatAmount;
      } else {
        // 'initialAmount' is the total amount, we subtract VAT from it
        _totalAmount = initialAmount;
        _vatAmount = _totalAmount - (_totalAmount / (1 + (vatRate / 100)));
        _netAmount = _totalAmount - _vatAmount;
      }
    });

    _showVatSummaryModal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VAT Calculator'),
        backgroundColor: Colors.green.shade50,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(
              controller: _amountController,
              label: 'Amount',
              icon: Icons.attach_money,
            ),
            const SizedBox(height: 20),
            _buildInputField(
              controller: _vatRateController,
              label: 'VAT Rate (%)',
              icon: Icons.rate_review,
            ),
            const SizedBox(height: 20),
            _buildVatTypeSelector(),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _calculateVat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green.shade300),
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
          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildVatTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<VatType>(
              title: const Text('Add VAT'),
              value: VatType.add,
              groupValue: _vatType,
              onChanged: (VatType? value) {
                if (value != null) {
                  setState(() {
                    _vatType = value;
                  });
                }
              },
              activeColor: Colors.green.shade400,
            ),
          ),
          Expanded(
            child: RadioListTile<VatType>(
              title: const Text('Remove VAT'),
              value: VatType.remove,
              groupValue: _vatType,
              onChanged: (VatType? value) {
                if (value != null) {
                  setState(() {
                    _vatType = value;
                  });
                }
              },
              activeColor: Colors.green.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _showVatSummaryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _buildVatSummaryModal(),
    );
  }

  Widget _buildVatSummaryModal() {
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
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.green.shade500,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: const Text(
                  'VAT Calculation Summary',
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
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Net Amount', _netAmount),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('VAT Amount', _vatAmount),
                            const Divider(height: 24, thickness: 1),
                            _buildSummaryRow('Total Amount', _totalAmount, isTotal: true),
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
                              'Expense Breakdown',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
            color: isTotal ? Colors.green.shade700 : Colors.grey.shade800,
          ),
        ),
        Text(
          _currency.format(value),
          style: TextStyle(
            fontSize: isTotal ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: isTotal ? Colors.green.shade700 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    if (_totalAmount <= 0) {
      return const Center(child: Text('Enter values to view chart'));
    }

    final sections = [
      PieChartSectionData(
        value: _netAmount,
        title: '${((_netAmount / _totalAmount) * 100).toStringAsFixed(1)}%',
        color: Colors.green.shade400,
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        value: _vatAmount,
        title: '${((_vatAmount / _totalAmount) * 100).toStringAsFixed(1)}%',
        color: Colors.orange.shade400,
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
      {'label': 'Net Amount', 'value': _netAmount, 'color': Colors.green.shade400},
      {'label': 'VAT Amount', 'value': _vatAmount, 'color': Colors.orange.shade400},
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
    _amountController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }
}
