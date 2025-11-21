import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart' as lang;
import 'services/calculation_history_service.dart';

class GstCalculatorScreen extends StatefulWidget {
  const GstCalculatorScreen({super.key});

  @override
  State<GstCalculatorScreen> createState() => _GstCalculatorScreenState();
}

enum GstType { add, remove }

class _GstCalculatorScreenState extends State<GstCalculatorScreen>
    with TickerProviderStateMixin {
  final _amountController = TextEditingController();
  final _gstRateController = TextEditingController();
  GstType _gstType = GstType.add;

  double _netAmount = 0;
  double _gstAmount = 0;
  double _totalAmount = 0;
  bool _showResults = false;
  bool _animationsInitialized = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _gstRateController.text = '18'; // Default GST rate
    
    // Initialize animation controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Initialize animations after controller
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    // Reset controller to initial state
    _animationController.reset();
    
    // Mark animations as initialized
    _animationsInitialized = true;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _gstRateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _calculateGst() async {
    final double? initialAmount = double.tryParse(_amountController.text);
    final double? gstRate = double.tryParse(_gstRateController.text);

      if (initialAmount == null || gstRate == null || initialAmount <= 0 || gstRate <= 0) {
      final localizations = lang.AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations?.pleaseEnterValid ?? 'Please enter valid values'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      setState(() {
        _showResults = false;
      });
      return;
    }

    setState(() {
      if (_gstType == GstType.add) {
        _netAmount = initialAmount;
        _gstAmount = _netAmount * (gstRate / 100);
        _totalAmount = _netAmount + _gstAmount;
      } else {
        _totalAmount = initialAmount;
        _gstAmount = _totalAmount - (_totalAmount / (1 + (gstRate / 100)));
        _netAmount = _totalAmount - _gstAmount;
      }
      _showResults = true;
    });

    // Save to history
    await _saveToHistory(initialAmount, gstRate);

    // Reset and start animations
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> _saveToHistory(double amount, double gstRate) async {
    final historyService = CalculationHistoryService();
    await historyService.saveCalculation(
      calculatorType: 'gst',
      inputData: {
        'Amount': '₹${NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount)}',
        'GST Rate': '$gstRate%',
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
    final themeProvider = ThemeProvider.of(context);
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.purple.shade600,
        title: Consumer<lang.LanguageProvider>(
          builder: (context, languageProvider, _) {
            final localizations = lang.AppLocalizations.of(context);
            return Text(
              localizations?.gstCalculator ?? 'GST Calculator',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card with Gradient
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.purple.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<lang.LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      final localizations = lang.AppLocalizations.of(context);
                      return Column(
                        children: [
                          Text(
                            localizations?.calculateGst ?? 'Calculate GST',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations?.addRemoveGst ?? 'Add or remove GST from amounts',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Amount Input
            Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return _buildEnhancedInputField(
                  controller: _amountController,
                  label: localizations?.amount ?? 'Amount',
                  icon: Icons.currency_rupee,
                  themeProvider: themeProvider,
                );
              },
            ),

            const SizedBox(height: 20),

            // GST Rate Input
            Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return _buildEnhancedInputField(
                  controller: _gstRateController,
                  label: localizations?.gstRate ?? 'GST Rate (%)',
                  icon: Icons.percent,
                  themeProvider: themeProvider,
                );
              },
            ),

            const SizedBox(height: 24),

            // GST Type Selector with better design
            _buildEnhancedGstTypeSelector(themeProvider),

            const SizedBox(height: 32),

            // Calculate Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _calculateGst,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  elevation: 8,
                  shadowColor: Colors.purple.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Consumer<lang.LanguageProvider>(
                  builder: (context, languageProvider, _) {
                    final localizations = lang.AppLocalizations.of(context);
                    return Text(
                      localizations?.calculate ?? 'Calculate',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Results Section with Animations
            if (_showResults && _animationsInitialized && mounted) ...[
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results Cards
                        Row(
                          children: [
                            Expanded(
                              child: Consumer<lang.LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  final localizations = lang.AppLocalizations.of(context);
                                  return _buildResultCard(
                                    localizations?.netAmount ?? 'Net Amount',
                                    formatCurrency.format(_netAmount),
                                    Colors.blue,
                                    Icons.account_balance_wallet,
                                    themeProvider,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Consumer<lang.LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  final localizations = lang.AppLocalizations.of(context);
                                  return _buildResultCard(
                                    localizations?.gstAmount ?? 'GST Amount',
                                    formatCurrency.format(_gstAmount),
                                    Colors.orange,
                                    Icons.receipt,
                                    themeProvider,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Consumer<lang.LanguageProvider>(
                          builder: (context, languageProvider, _) {
                            final localizations = lang.AppLocalizations.of(context);
                            return _buildTotalCard(
                              formatCurrency.format(_totalAmount),
                              themeProvider,
                              localizations?.totalAmount ?? 'Total Amount',
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Pie Chart Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: themeProvider.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: themeProvider.borderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Consumer<lang.LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  final localizations = lang.AppLocalizations.of(context);
                                  return Text(
                                    localizations?.amountBreakdown ?? 'Amount Breakdown',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.textPrimary,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 280,
                                child: _buildPieChart(themeProvider),
                              ),
                              const SizedBox(height: 20),
                              Consumer<lang.LanguageProvider>(
                                builder: (context, languageProvider, _) {
                                  final localizations = lang.AppLocalizations.of(context);
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildLegendItem(
                                        localizations?.netAmount ?? 'Net Amount',
                                        formatCurrency.format(_netAmount),
                                        Colors.blue,
                                        themeProvider,
                                      ),
                                      _buildLegendItem(
                                        localizations?.gstAmount ?? 'GST Amount',
                                        formatCurrency.format(_gstAmount),
                                        Colors.orange,
                                        themeProvider,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeProvider themeProvider,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        style: TextStyle(
          fontSize: 16,
          color: themeProvider.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.purple.shade600, size: 24),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildEnhancedGstTypeSelector(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeProvider.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return _buildGstTypeButton(
                  localizations?.addGst ?? 'Add GST',
                  GstType.add,
                  Icons.add_circle_outline,
                  Colors.green,
                  themeProvider,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return _buildGstTypeButton(
                  localizations?.removeGst ?? 'Remove GST',
                  GstType.remove,
                  Icons.remove_circle_outline,
                  Colors.red,
                  themeProvider,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGstTypeButton(
    String label,
    GstType type,
    IconData icon,
    Color color,
    ThemeProvider themeProvider,
  ) {
    final isSelected = _gstType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _gstType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : themeProvider.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : themeProvider.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String label,
    String value,
    Color color,
    IconData icon,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(String value, ThemeProvider themeProvider, String label) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade600, Colors.purple.shade800],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ThemeProvider themeProvider) {
    if (_netAmount == 0 && _gstAmount == 0) {
      return const SizedBox();
    }

    final netPercent = _totalAmount > 0
        ? ((_netAmount / _totalAmount) * 100).toStringAsFixed(1)
        : '0';
    final gstPercent = _totalAmount > 0
        ? ((_gstAmount / _totalAmount) * 100).toStringAsFixed(1)
        : '0';

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: _netAmount,
            title: '$netPercent%\nNet',
            color: Colors.blue,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          PieChartSectionData(
            value: _gstAmount,
            title: '$gstPercent%\nGST',
            color: Colors.orange,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
        sectionsSpace: 4,
        centerSpaceRadius: 60,
        pieTouchData: PieTouchData(enabled: true),
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    String value,
    Color color,
    ThemeProvider themeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: themeProvider.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
