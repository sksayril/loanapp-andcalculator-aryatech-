import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class FixedDepositCalculatorScreen extends StatefulWidget {
  const FixedDepositCalculatorScreen({super.key});

  @override
  State<FixedDepositCalculatorScreen> createState() => _FixedDepositCalculatorScreenState();
}

class _FixedDepositCalculatorScreenState extends State<FixedDepositCalculatorScreen> {
  final _principalController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _tenureController = TextEditingController();
  
  String _tenureType = 'Years'; // 'Years' or 'Months'
  
  double _principalAmount = 0;
  double _interestEarned = 0;
  double _maturityAmount = 0;
  bool _showResults = false;

  void _calculateFD() {
    final double? principal = double.tryParse(_principalController.text);
    final double? interestRate = double.tryParse(_interestRateController.text);
    final double? tenure = double.tryParse(_tenureController.text);

    if (principal == null || interestRate == null || tenure == null || 
        principal <= 0 || interestRate <= 0 || tenure <= 0) {
      setState(() {
        _principalAmount = 0;
        _interestEarned = 0;
        _maturityAmount = 0;
        _showResults = false;
      });
      return;
    }

    // Convert tenure to years if in months
    final double tenureInYears = _tenureType == 'Months' ? tenure / 12 : tenure;
    
    // Calculate compound interest
    // A = P * (1 + r/100)^t
    final double maturityAmount = principal * pow(1 + (interestRate / 100), tenureInYears);
    final double interestEarned = maturityAmount - principal;

    setState(() {
      _principalAmount = principal;
      _interestEarned = interestEarned;
      _maturityAmount = maturityAmount;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixed Deposit Calculator'),
        backgroundColor: Colors.orange.shade50,
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
                    Colors.orange.shade400,
                    Colors.orange.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Calculate Your FD Returns',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plan your fixed deposit investment',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Principal Amount Input
            _buildInputField(
              controller: _principalController,
              label: 'Principal Amount (₹)',
              icon: Icons.account_balance_wallet,
              hint: 'Enter investment amount',
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
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
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
                                  color: Colors.orange.shade700,
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
              onPressed: _calculateFD,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade400,
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
        prefixIcon: Icon(icon, color: Colors.orange.shade300),
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
          borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
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
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.2),
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
              Icon(Icons.calculate, color: Colors.orange.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                'Calculation Results',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildResultRow(
            'Principal Amount',
            formatter.format(_principalAmount),
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
            Icons.account_balance,
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
        color: isTotal ? Colors.orange.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: isTotal
            ? Border.all(color: Colors.orange.shade300, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isTotal
                  ? Colors.orange.shade400
                  : isHighlight
                      ? Colors.orange.shade200
                      : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isTotal ? Colors.white : Colors.orange.shade700,
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
                color: isTotal ? Colors.orange.shade900 : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.orange.shade700 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }
}

