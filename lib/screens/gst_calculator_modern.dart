import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/modern_calculator_slider.dart';
import '../services/calculation_history_service.dart';

enum GstType { add, remove }

class GstCalculatorModern extends StatefulWidget {
  const GstCalculatorModern({super.key});

  @override
  State<GstCalculatorModern> createState() => _GstCalculatorModernState();
}

class _GstCalculatorModernState extends State<GstCalculatorModern> {
  double _amount = 10000;
  double _gstRate = 18;
  GstType _gstType = GstType.add;

  double _netAmount = 0;
  double _gstAmount = 0;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _calculateGst();
  }

  void _calculateGst() {
    setState(() {
      if (_gstType == GstType.add) {
        // Add GST logic (same as original)
        _netAmount = _amount;
        _gstAmount = _netAmount * (_gstRate / 100);
        _totalAmount = _netAmount + _gstAmount;
      } else {
        // Remove GST logic (same as original)
        _totalAmount = _amount;
        _gstAmount = _totalAmount - (_totalAmount / (1 + (_gstRate / 100)));
        _netAmount = _totalAmount - _gstAmount;
      }
    });

    // Save to history
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'gst',
      inputData: {
        'Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_amount)}',
        'GST Rate': '$_gstRate%',
        'Type': _gstType == GstType.add ? 'Add GST' : 'Remove GST',
      },
      resultData: {
        'Net Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_netAmount)}',
        'GST Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(_gstAmount)}',
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
          'GST Calculator',
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
            // GST Type Toggle
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
                          _gstType = GstType.add;
                          _calculateGst();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _gstType == GstType.add
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Add GST',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _gstType == GstType.add
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
                          _gstType = GstType.remove;
                          _calculateGst();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _gstType == GstType.remove
                              ? const Color(0xFF1E3A5F)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Remove GST',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _gstType == GstType.remove
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
              label: _gstType == GstType.add ? 'Net Amount' : 'Gross Amount',
              value: _amount,
              min: 100,
              max: 1000000,
              divisions: 999,
              valueFormatter: (val) => formatCompactCurrency(val),
              onChanged: (value) {
                setState(() {
                  _amount = value;
                  _calculateGst();
                });
              },
            ),
            const SizedBox(height: 30),

            // GST Rate Slider
            ModernCalculatorSlider(
              label: 'GST Rate',
              value: _gstRate,
              min: 0,
              max: 28,
              divisions: 28,
              suffix: '%',
              valueFormatter: (val) => val.toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _gstRate = value;
                  _calculateGst();
                });
              },
            ),
            const SizedBox(height: 40),

            // Result Card
            ModernResultCard(
              title: _gstType == GstType.add
                  ? 'TOTAL AMOUNT (WITH GST)'
                  : 'NET AMOUNT (WITHOUT GST)',
              amount: _gstType == GstType.add
                  ? formatCurrency(_totalAmount)
                  : formatCurrency(_netAmount),
              subtitle: 'GST Amount: ${formatCurrency(_gstAmount)}',
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
                    'GST Amount',
                    formatCurrency(_gstAmount),
                    themeProvider,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Total Amount (Incl. GST)',
              formatCurrency(_totalAmount),
              themeProvider,
              fullWidth: true,
            ),
            const SizedBox(height: 24),

            // GST Rate Presets
            _buildGstRatePresets(),
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

  Widget _buildGstRatePresets() {
    final presets = [
      {'rate': 0.0, 'label': '0%'},
      {'rate': 5.0, 'label': '5%'},
      {'rate': 12.0, 'label': '12%'},
      {'rate': 18.0, 'label': '18%'},
      {'rate': 28.0, 'label': '28%'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick GST Rates',
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
            final isSelected = _gstRate == preset['rate'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _gstRate = preset['rate'] as double;
                  _calculateGst();
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
}
