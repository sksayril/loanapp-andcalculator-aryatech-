import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

enum VatType { add, remove }

class VatCalculatorModern extends StatefulWidget {
  const VatCalculatorModern({super.key});

  @override
  State<VatCalculatorModern> createState() => _VatCalculatorModernState();
}

class _VatCalculatorModernState extends State<VatCalculatorModern> {
  double _amount = 10000;
  double _vatRate = 5.0;
  VatType _vatType = VatType.add;

  double _netAmount = 0;
  double _vatAmount = 0;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateVat();
  }

  void _calculateVat() {
    // EXACT SAME LOGIC AS ORIGINAL
    setState(() {
      if (_vatType == VatType.add) {
        // 'amount' is the net amount, we add VAT to it
        _netAmount = _amount;
        _vatAmount = _netAmount * (_vatRate / 100);
        _totalAmount = _netAmount + _vatAmount;
      } else {
        // 'amount' is the total amount, we subtract VAT from it
        _totalAmount = _amount;
        _vatAmount = _totalAmount - (_totalAmount / (1 + (_vatRate / 100)));
        _netAmount = _totalAmount - _vatAmount;
      }
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'vat',
      inputData: {
        'Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_amount)}',
        'VAT Rate': '$_vatRate%',
        'Type': _vatType == VatType.add ? 'Add VAT' : 'Remove VAT',
      },
      resultData: {
        'Net Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_netAmount)}',
        'VAT Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_vatAmount)}',
        'Total Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_totalAmount)}',
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
          'VAT Calculator',
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
            // VAT Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _vatType = VatType.add;
                          _calculateVat();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _vatType == VatType.add
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Add VAT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _vatType == VatType.add
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _vatType = VatType.remove;
                          _calculateVat();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _vatType == VatType.remove
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Remove VAT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _vatType == VatType.remove
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Amount Slider
            ModernCalculatorSlider(
              label: _vatType == VatType.add ? 'Net Amount' : 'Gross Amount',
              value: _amount,
              min: 100,
              max: 1000000,
              divisions: 999,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _amount = value;
                  _calculateVat();
                });
              },
            ),
            const SizedBox(height: 30),

            // VAT Rate Slider
            ModernCalculatorSlider(
              label: 'VAT Rate',
              value: _vatRate,
              min: 0,
              max: 28,
              divisions: 280,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  _vatRate = value;
                  _calculateVat();
                });
              },
            ),
            const SizedBox(height: 40),

            // Result Card
            ModernResultCard(
              title: _vatType == VatType.add
                  ? 'TOTAL AMOUNT (WITH VAT)'
                  : 'NET AMOUNT (WITHOUT VAT)',
              amount: _vatType == VatType.add
                  ? formatCurrency(_totalAmount)
                  : formatCurrency(_netAmount),
              subtitle: 'VAT Amount: ${formatCurrency(_vatAmount)}',
            ),
            const SizedBox(height: 24),

            // Breakdown Cards
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    'Net Amount',
                    formatCurrency(_netAmount),
                    themeProvider,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    'VAT Amount',
                    formatCurrency(_vatAmount),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Total Amount (Incl. VAT)',
              formatCurrency(_totalAmount),
              themeProvider,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // VAT Rate Presets
            _buildVatRatePresets(),
            const SizedBox(height: 24),

            // VAT Information Card
            _buildVatInfoCard(themeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    ThemeProvider themeProvider, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1E3A5F).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            fullWidth ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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

  Widget _buildVatRatePresets() {
    final presets = [
      {'rate': 0.0, 'label': '0%'},
      {'rate': 5.0, 'label': '5%'},
      {'rate': 12.0, 'label': '12%'},
      {'rate': 14.0, 'label': '14%'},
      {'rate': 20.0, 'label': '20%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick VAT Rates',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Provider.of<ThemeProvider>(context).textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: presets.map((preset) {
            final isSelected = _vatRate == preset['rate'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _vatRate = preset['rate'] as double;
                  _calculateVat();
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E3A5F)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A5F)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  preset['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVatInfoCard(ThemeProvider themeProvider) {
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
                'VAT Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('• VAT is Value Added Tax'),
          _buildInfoRow('• Consumption tax on goods & services'),
          _buildInfoRow('• Rates vary by country/region'),
          _buildInfoRow('• Common rates: 0%, 5%, 12%, 14%, 20%'),
          _buildInfoRow('• Essential items often have lower rates'),
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
