import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class RecurringDepositCalculatorScreen extends StatefulWidget {
  const RecurringDepositCalculatorScreen({super.key});

  @override
  State<RecurringDepositCalculatorScreen> createState() => _RecurringDepositCalculatorScreenState();
}

class _RecurringDepositCalculatorScreenState extends State<RecurringDepositCalculatorScreen> {
  final _monthlyDepositController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();
  
  String _tenureType = 'Years'; // 'Years' or 'Months'
  
  double _totalDeposit = 0;
  double _interestEarned = 0;
  double _maturityAmount = 0;
  bool _showResults = false;

  void _calculateRD() {
    final double? monthlyDeposit = double.tryParse(_monthlyDepositController.text);
    final double? interestRate = double.tryParse(_interestRateController.text);
    final double? tenure = double.tryParse(_tenureController.text);

    if (monthlyDeposit == null || interestRate == null || tenure == null || 
        monthlyDeposit <= 0 || interestRate <= 0 || tenure <= 0) {
      setState(() {
        _totalDeposit = 0;
        _interestEarned = 0;
        _maturityAmount = 0;
        _showResults = false;
      });
      return;
    }

    // Convert tenure to months
    final int tenureInMonths = _tenureType == 'Months' 
        ? tenure.toInt() 
        : (tenure * 12).toInt();
    
    // Calculate RD maturity amount
    // Formula: M = P * [((1 + r)^n - 1) / r] * (1 + r)
    // where P = monthly deposit, r = monthly interest rate, n = number of months
    final double monthlyRate = interestRate / 12 / 100;
    final double maturityAmount = monthlyDeposit * 
        ((pow(1 + monthlyRate, tenureInMonths) - 1) / monthlyRate) * 
        (1 + monthlyRate);
    
    final double totalDeposit = monthlyDeposit * tenureInMonths;
    final double interestEarned = maturityAmount - totalDeposit;

    setState(() {
      _totalDeposit = totalDeposit;
      _interestEarned = interestEarned;
      _maturityAmount = maturityAmount;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Deposit Calculator'),
        backgroundColor: Colors.teal.shade50,
        elevation: 0,
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
                    Colors.teal.shade400,
                    Colors.teal.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.savings,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Calculate Your RD Returns',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan your recurring deposit investment',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Monthly Deposit Input
            _buildInputField(
              controller: _monthlyDepositController,
              label: 'Monthly Deposit (₹)',
              icon: Icons.account_balance_wallet,
              hint: 'Enter monthly deposit amount',
            ),
            const SizedBox(height: 20),
            
            // Interest Rate Input
            _buildInputField(
              controller: _interestRateController,
              label: 'Interest Rate (%)',
              icon: Icons.trending_up,
              hint: 'Enter annual interest rate',
            ),
            const SizedBox(height: 20),
            
            // Tenure Input with Type Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInputField(
                        controller: _tenureController,
                        label: 'Tenure',
                        icon: Icons.calendar_today,
                        hint: 'Enter tenure',
                        isTenure: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.shade200),
                      ),
                      child: DropdownButton<String>(
                        value: _tenureType,
                        isExpanded: true,
                        underline: const SizedBox(),
                        items: ['Years', 'Months'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _tenureType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            
            // Calculate Button
            ElevatedButton(
              onPressed: _calculateRD,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
            const SizedBox(height: 30),
            
            // Results Card
            if (_showResults) _buildResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool isTenure = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.teal.shade300),
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
          borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.shade50,
            Colors.teal.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
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
              Icon(Icons.calculate, color: Colors.teal.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Calculation Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResultRow(
            'Total Deposit',
            formatter.format(_totalDeposit),
            Icons.account_balance_wallet,
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            'Interest Earned',
            formatter.format(_interestEarned),
            Icons.trending_up,
            isHighlight: true,
          ),
          const Divider(height: 24, thickness: 2),
          _buildResultRow(
            'Maturity Amount',
            formatter.format(_maturityAmount),
            Icons.savings,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    IconData icon, {
    bool isTotal = false,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTotal ? Colors.teal.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isTotal
            ? Border.all(color: Colors.teal.shade300, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal
                  ? Colors.teal.shade400
                  : isHighlight
                      ? Colors.teal.shade200
                      : Colors.teal.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? Colors.white : Colors.teal.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 18 : 16,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? Colors.teal.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.teal.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _monthlyDepositController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }
}

