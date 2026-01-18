import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart' as lang;
import '../services/calculation_history_service.dart';
import '../widgets/modern_calculator_slider.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen>
    with TickerProviderStateMixin {
  // Slider values
  double _loanAmount = 200000;
  double _interestRate = 8.5;
  double _tenureMonths = 24;

  // State variables
  String _selectedLoanType = 'Home Loan';
  bool _showResults = false;

  // Calculation results
  double _emi = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;
  double _principalAmount = 0;
  List<AmortizationEntry> _amortizationSchedule = [];
  List<YearlyEmiData> _yearlyEmiData = [];
  List<BalanceOverTime> _balanceOverTime = [];

  late AnimationController _resultAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _loanTypes = [
    'Home Loan',
    'Personal Loan',
    'Car Loan',
    'Education Loan',
    'Business Loan',
  ];

  final Map<String, double> _defaultRates = {
    'Home Loan': 8.5,
    'Personal Loan': 12.0,
    'Car Loan': 9.5,
    'Education Loan': 8.0,
    'Business Loan': 11.0,
  };

  @override
  void initState() {
    super.initState();
    _interestRate = _defaultRates[_selectedLoanType]!;
    _calculateEMI();
    _resultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _resultAnimationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _resultAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _resultAnimationController.forward();
  }

  @override
  void dispose() {
    _resultAnimationController.dispose();
    super.dispose();
  }

  Future<void> _calculateEMI() async {
    final loanAmount = _loanAmount;
    final interestRate = _interestRate;
    final tenureMonths = _tenureMonths.toInt();

    if (loanAmount <= 0 || interestRate <= 0 || tenureMonths <= 0) {
      return;
    }

    // Calculate EMI
    final monthlyRate = interestRate / 12 / 100;
    final emi = (loanAmount *
            monthlyRate *
            math.pow(1 + monthlyRate, tenureMonths)) /
        (math.pow(1 + monthlyRate, tenureMonths) - 1);

    // Generate amortization schedule
    _generateAmortizationSchedule(
      loanAmount,
      interestRate,
      tenureMonths,
      emi,
      0,
      0,
    );

    // Calculate totals
    _totalPayment = _amortizationSchedule.fold(0.0, (sum, entry) => sum + entry.emi);
    _totalInterest = _totalPayment - loanAmount;
    _principalAmount = loanAmount;
    _emi = emi;

    // Generate chart data
    _generateChartData(tenureMonths);

    setState(() {
      _showResults = true;
    });

    _resultAnimationController.forward();
    
    // Save to history
    await _saveToHistory(loanAmount, interestRate, tenureMonths);
  }

  Future<void> _saveToHistory(
    double loanAmount,
    double interestRate,
    int tenureMonths,
  ) async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'emi',
      inputData: {
        'Loan Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(loanAmount)}',
        'Interest Rate': '$interestRate%',
        'Tenure': '$tenureMonths months',
        'Loan Type': _selectedLoanType,
      },
      resultData: {
        'EMI': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_emi)}',
        'Total Payment': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalPayment)}',
        'Total Interest': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_totalInterest)}',
        'Principal': '₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(_principalAmount)}',
      },
    );
  }

  void _showResultsModal(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: themeProvider.backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header with gradient background
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade400, Colors.teal.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMI Calculation Results',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Detailed breakdown and charts',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                              _exportAsPDF();
                            },
                            tooltip: 'Export as PDF',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                              _shareResults();
                            },
                            tooltip: 'Share Results',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Results Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildResultCard(
                                  _getEmiLabel(),
                                  formatCurrency.format(_getEmiByFrequency()),
                                  Colors.teal,
                                  Icons.payment,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildResultCard(
                                  'Total Payment',
                                  formatCurrency.format(_totalPayment),
                                  Colors.blue,
                                  Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildResultCard(
                                  'Total Interest',
                                  formatCurrency.format(_totalInterest),
                                  Colors.orange,
                                  Icons.trending_up,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildResultCard(
                                  'Principal',
                                  formatCurrency.format(_principalAmount),
                                  Colors.purple,
                                  Icons.money,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Pie Chart - Principal vs Interest
                          _buildSectionTitle('Principal vs Interest'),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: _buildPieChart(),
                          ),

                          const SizedBox(height: 32),

                          // Bar Chart - Yearly EMI Reduction
                          _buildSectionTitle('Yearly Payment Breakdown'),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: _buildBarChart(),
                          ),

                          const SizedBox(height: 32),

                          // Line Chart - Balance Over Time
                          _buildSectionTitle('Outstanding Balance Over Time'),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 250,
                            child: _buildLineChart(),
                          ),

                          const SizedBox(height: 32),

                          // Amortization Schedule
                          _buildSectionTitle('Amortization Schedule'),
                          const SizedBox(height: 16),
                          _buildAmortizationTable(),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateAmortizationSchedule(
    double principal,
    double annualRate,
    int tenureMonths,
    double emi,
    double prepaymentAmount,
    int prepaymentMonth,
  ) {
    _amortizationSchedule.clear();
    double remainingPrincipal = principal;
    final monthlyRate = annualRate / 12 / 100;

    for (int month = 1; month <= tenureMonths; month++) {
      double interestPayment = remainingPrincipal * monthlyRate;
      double principalPayment = emi - interestPayment;

      // Apply prepayment if applicable
      if (_showPrepayment && month == prepaymentMonth && prepaymentAmount > 0) {
        if (prepaymentAmount >= remainingPrincipal - principalPayment) {
          principalPayment = remainingPrincipal;
          remainingPrincipal = 0;
        } else {
          principalPayment += prepaymentAmount;
          remainingPrincipal -= prepaymentAmount;
        }
      } else {
        remainingPrincipal -= principalPayment;
      }

      if (remainingPrincipal < 0) remainingPrincipal = 0;

      _amortizationSchedule.add(AmortizationEntry(
        month: month,
        emi: emi,
        principal: principalPayment,
        interest: interestPayment,
        balance: remainingPrincipal,
      ));

      if (remainingPrincipal <= 0) break;
    }
  }

  void _generateChartData(int tenureMonths) {
    _yearlyEmiData.clear();
    _balanceOverTime.clear();

    // Yearly EMI reduction data
    for (int year = 1; year <= (tenureMonths / 12).ceil(); year++) {
      int startMonth = (year - 1) * 12;
      int endMonth = math.min(year * 12, tenureMonths);
      double yearlyPrincipal = 0;
      double yearlyInterest = 0;

      for (int i = startMonth; i < endMonth && i < _amortizationSchedule.length; i++) {
        yearlyPrincipal += _amortizationSchedule[i].principal;
        yearlyInterest += _amortizationSchedule[i].interest;
      }

      _yearlyEmiData.add(YearlyEmiData(
        year: year,
        principal: yearlyPrincipal,
        interest: yearlyInterest,
      ));
    }

    // Balance over time data (sample every 6 months)
    for (int i = 0; i < _amortizationSchedule.length; i += 6) {
      _balanceOverTime.add(BalanceOverTime(
        month: _amortizationSchedule[i].month,
        balance: _amortizationSchedule[i].balance,
      ));
    }
    // Add final balance
    if (_amortizationSchedule.isNotEmpty) {
      _balanceOverTime.add(BalanceOverTime(
        month: _amortizationSchedule.last.month,
        balance: _amortizationSchedule.last.balance,
      ));
    }
  }

  String _getEmiLabel() {
    switch (_emiDisplayFrequency) {
      case 'Quarterly':
        return 'Quarterly EMI';
      case 'Yearly':
        return 'Yearly EMI';
      default:
        return 'Monthly EMI';
    }
  }

  double _getEmiByFrequency() {
    switch (_emiDisplayFrequency) {
      case 'Quarterly':
        return _emi * 3;
      case 'Yearly':
        return _emi * 12;
      default:
        return _emi;
    }
  }

  void _onLoanTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedLoanType = value;
        _interestRateController.text = _defaultRates[value]!.toString();
      });
    }
  }

  void _exportAsPDF() async {
    if (!_showResults) return;

    final pdf = pw.Document();
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'EMI Calculator Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Loan Details:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Loan Type: $_selectedLoanType'),
            pw.Text('Loan Amount: ${formatCurrency.format(_principalAmount)}'),
            pw.Text('Interest Rate: ${_interestRateController.text}%'),
            pw.Text('Tenure: ${_tenureController.text} ${_isTenureInYears ? 'Years' : 'Months'}'),
            pw.SizedBox(height: 20),
            pw.Text('Calculation Results:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('EMI: ${formatCurrency.format(_emi)}'),
            pw.Text('Total Payment: ${formatCurrency.format(_totalPayment)}'),
            pw.Text('Total Interest: ${formatCurrency.format(_totalInterest)}'),
            pw.SizedBox(height: 20),
            pw.Text('Amortization Schedule:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(),
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Month', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('EMI', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Principal', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Interest', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                ..._amortizationSchedule.take(50).map((entry) => pw.TableRow(
                  children: [
                    pw.Text(entry.month.toString()),
                    pw.Text(formatCurrency.format(entry.emi)),
                    pw.Text(formatCurrency.format(entry.principal)),
                    pw.Text(formatCurrency.format(entry.interest)),
                    pw.Text(formatCurrency.format(entry.balance)),
                  ],
                )),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _shareResults() {
    if (!_showResults) return;

    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final shareText = '''
EMI Calculator Results

Loan Type: $_selectedLoanType
Loan Amount: ${formatCurrency.format(_principalAmount)}
Interest Rate: ${_interestRateController.text}%
Tenure: ${_tenureController.text} ${_isTenureInYears ? 'Years' : 'Months'}

EMI: ${formatCurrency.format(_emi)}
Total Payment: ${formatCurrency.format(_totalPayment)}
Total Interest: ${formatCurrency.format(_totalInterest)}
''';

    Share.share(shareText, subject: 'EMI Calculator Results');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.cardBackground,
        elevation: 0,
        title: Text(
          'EMI Calculator',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Loan Type Selection
            _buildSectionTitle('Loan Type'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: themeProvider.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeProvider.borderColor),
              ),
              child: DropdownButton<String>(
                value: _selectedLoanType,
                isExpanded: true,
                underline: const SizedBox(),
                items: _loanTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: _onLoanTypeChanged,
              ),
            ),

            const SizedBox(height: 24),

            // Loan Amount
            _buildSectionTitle('Loan Amount (₹)'),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _loanAmountController,
              hint: 'Enter loan amount',
              icon: Icons.currency_rupee,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Interest Rate
            _buildSectionTitle('Interest Rate (%)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _interestRateController,
                    hint: 'Enter interest rate',
                    icon: Icons.percent,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                _buildToggleButton(
                  'Fixed',
                  'Floating',
                  _isFixedRate,
                  (value) => setState(() => _isFixedRate = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tenure
            _buildSectionTitle('Loan Tenure'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _tenureController,
                    hint: 'Enter tenure',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                _buildToggleButton(
                  'Years',
                  'Months',
                  _isTenureInYears,
                  (value) => setState(() => _isTenureInYears = value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // EMI Display Frequency
            _buildSectionTitle('EMI Display Frequency'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyButton('Monthly', _emiDisplayFrequency == 'Monthly'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFrequencyButton('Quarterly', _emiDisplayFrequency == 'Quarterly'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildFrequencyButton('Yearly', _emiDisplayFrequency == 'Yearly'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Prepayment Option
            Row(
              children: [
                Checkbox(
                  value: _showPrepayment,
                  onChanged: (value) => setState(() => _showPrepayment = value ?? false),
                ),
                const Text('Enable Prepayment/Part Payment'),
              ],
            ),

            if (_showPrepayment) ...[
              const SizedBox(height: 16),
              _buildSectionTitle('Prepayment Amount (₹)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _prepaymentAmountController,
                hint: 'Enter prepayment amount',
                icon: Icons.payment,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Prepayment Month'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _prepaymentMonthController,
                hint: 'Enter month number',
                icon: Icons.calendar_month,
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateEMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Calculate EMI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = ThemeProvider.of(context);
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: themeProvider.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
  }) {
    final themeProvider = ThemeProvider.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
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
      ),
    );
  }

  Widget _buildToggleButton(String label1, String label2, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: value ? Colors.teal : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: value ? Colors.teal.shade700 : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              child: Text(
                label1,
                style: TextStyle(
                  color: value ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: !value ? Colors.teal.shade700 : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                label2,
                style: TextStyle(
                  color: !value ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _emiDisplayFrequency = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(String title, String value, Color color, IconData icon) {
    final themeProvider = ThemeProvider.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: _principalAmount,
            title: 'Principal\n${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(_principalAmount)}',
            color: Colors.blue,
            radius: 80,
          ),
          PieChartSectionData(
            value: _totalInterest,
            title: 'Interest\n${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(_totalInterest)}',
            color: Colors.orange,
            radius: 80,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }

  Widget _buildBarChart() {
    if (_yearlyEmiData.isEmpty) return const SizedBox();

    final maxValue = _yearlyEmiData.map((e) => e.principal + e.interest).reduce(math.max) * 1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() > 0 && value.toInt() <= _yearlyEmiData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Y${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        barGroups: _yearlyEmiData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return BarChartGroupData(
            x: index + 1,
            groupVertically: false,
            barRods: [
              BarChartRodData(
                toY: data.principal,
                color: Colors.blue,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: data.principal + data.interest,
                fromY: data.principal,
                color: Colors.orange,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineChart() {
    if (_balanceOverTime.isEmpty) return const SizedBox();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  'M${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '₹${(value / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: _balanceOverTime.map((data) {
              return FlSpot(data.month.toDouble(), data.balance);
            }).toList(),
            isCurved: true,
            color: Colors.teal,
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmortizationTable() {
    final themeProvider = ThemeProvider.of(context);
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeProvider.borderColor),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Month')),
            DataColumn(label: Text('EMI')),
            DataColumn(label: Text('Principal')),
            DataColumn(label: Text('Interest')),
            DataColumn(label: Text('Balance')),
          ],
          rows: _amortizationSchedule.take(50).map((entry) {
            return DataRow(
              cells: [
                DataCell(Text(entry.month.toString())),
                DataCell(Text(NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(entry.emi))),
                DataCell(Text(NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(entry.principal))),
                DataCell(Text(NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(entry.interest))),
                DataCell(Text(NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(entry.balance))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Data Models
class AmortizationEntry {
  final int month;
  final double emi;
  final double principal;
  final double interest;
  final double balance;

  AmortizationEntry({
    required this.month,
    required this.emi,
    required this.principal,
    required this.interest,
    required this.balance,
  });
}

class YearlyEmiData {
  final int year;
  final double principal;
  final double interest;

  YearlyEmiData({
    required this.year,
    required this.principal,
    required this.interest,
  });
}

class BalanceOverTime {
  final int month;
  final double balance;

  BalanceOverTime({
    required this.month,
    required this.balance,
  });
}

