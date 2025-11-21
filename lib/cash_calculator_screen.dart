import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cash_counter_history_service.dart';
import '../screens/cash_counter_history_screen.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class CashCalculatorScreen extends StatefulWidget {
  final CashCounterHistory? editData;
  
  const CashCalculatorScreen({super.key, this.editData});

  @override
  State<CashCalculatorScreen> createState() => _CashCalculatorScreenState();
}

class _CashCalculatorScreenState extends State<CashCalculatorScreen> {
  final TextEditingController _note500Controller = TextEditingController(text: '0');
  final TextEditingController _note200Controller = TextEditingController(text: '0');
  final TextEditingController _note100Controller = TextEditingController(text: '0');
  final TextEditingController _note50Controller = TextEditingController(text: '0');
  final TextEditingController _note20Controller = TextEditingController(text: '0');
  final TextEditingController _note10Controller = TextEditingController(text: '0');
  final TextEditingController _otherPlusController = TextEditingController(text: '0');
  final TextEditingController _otherMinusController = TextEditingController(text: '0');
  final TextEditingController _notesController = TextEditingController();

  int _note500Qty = 0;
  int _note200Qty = 0;
  int _note100Qty = 0;
  int _note50Qty = 0;
  int _note20Qty = 0;
  int _note10Qty = 0;

  final CashCounterHistoryService _historyService = CashCounterHistoryService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _note500Controller.addListener(_updateCalculations);
    _note200Controller.addListener(_updateCalculations);
    _note100Controller.addListener(_updateCalculations);
    _note50Controller.addListener(_updateCalculations);
    _note20Controller.addListener(_updateCalculations);
    _note10Controller.addListener(_updateCalculations);
    _otherPlusController.addListener(_updateCalculations);
    _otherMinusController.addListener(_updateCalculations);
    
    // Load edit data if provided
    if (widget.editData != null) {
      _loadEditData();
    }
  }

  void _loadEditData() {
    final data = widget.editData!;
    _note500Controller.text = data.note500.toString();
    _note200Controller.text = data.note200.toString();
    _note100Controller.text = data.note100.toString();
    _note50Controller.text = data.note50.toString();
    _note20Controller.text = data.note20.toString();
    _note10Controller.text = data.note10.toString();
    _otherPlusController.text = data.otherPlus.toStringAsFixed(0);
    _otherMinusController.text = data.otherMinus.toStringAsFixed(0);
    _notesController.text = data.notes;
  }

  @override
  void dispose() {
    _note500Controller.dispose();
    _note200Controller.dispose();
    _note100Controller.dispose();
    _note50Controller.dispose();
    _note20Controller.dispose();
    _note10Controller.dispose();
    _otherPlusController.dispose();
    _otherMinusController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _note500Qty = int.tryParse(_note500Controller.text) ?? 0;
      _note200Qty = int.tryParse(_note200Controller.text) ?? 0;
      _note100Qty = int.tryParse(_note100Controller.text) ?? 0;
      _note50Qty = int.tryParse(_note50Controller.text) ?? 0;
      _note20Qty = int.tryParse(_note20Controller.text) ?? 0;
      _note10Qty = int.tryParse(_note10Controller.text) ?? 0;
    });
  }

  void _resetAll() {
    setState(() {
      _note500Controller.text = '0';
      _note200Controller.text = '0';
      _note100Controller.text = '0';
      _note50Controller.text = '0';
      _note20Controller.text = '0';
      _note10Controller.text = '0';
      _otherPlusController.text = '0';
      _otherMinusController.text = '0';
    });
  }

  Future<void> _saveData() async {
    if (_isSaving) return;

    // Show modal dialog for notes
    final notes = await _showNotesDialog();
    if (notes == null) return; // User cancelled

    setState(() => _isSaving = true);

    try {
      final note500 = int.tryParse(_note500Controller.text) ?? 0;
      final note200 = int.tryParse(_note200Controller.text) ?? 0;
      final note100 = int.tryParse(_note100Controller.text) ?? 0;
      final note50 = int.tryParse(_note50Controller.text) ?? 0;
      final note20 = int.tryParse(_note20Controller.text) ?? 0;
      final note10 = int.tryParse(_note10Controller.text) ?? 0;
      final otherPlus = double.tryParse(_otherPlusController.text) ?? 0.0;
      final otherMinus = double.tryParse(_otherMinusController.text) ?? 0.0;

      if (widget.editData != null) {
        // Update existing entry
        await _historyService.updateCashCount(
          id: widget.editData!.id,
          note500: note500,
          note200: note200,
          note100: note100,
          note50: note50,
          note20: note20,
          note10: note10,
          otherPlus: otherPlus,
          otherMinus: otherMinus,
          totalNotes: totalNotes,
          totalAmount: totalAmount,
          notes: notes,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cash count updated successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        // Save new entry
        await _historyService.saveCashCount(
          note500: note500,
          note200: note200,
          note100: note100,
          note50: note50,
          note20: note20,
          note10: note10,
          otherPlus: otherPlus,
          otherMinus: otherMinus,
          totalNotes: totalNotes,
          totalAmount: totalAmount,
          notes: notes,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cash count saved successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<String?> _showNotesDialog() async {
    final notesController = TextEditingController(text: _notesController.text);
    
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final dialogThemeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor: dialogThemeProvider.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.note, color: const Color(0xFF5DADE2), size: 24),
              const SizedBox(width: 8),
              Text(
                'Add Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: dialogThemeProvider.textPrimary,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dialogThemeProvider.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dialogThemeProvider.borderColor),
            ),
            child: TextField(
              controller: notesController,
              maxLines: 4,
              autofocus: true,
              style: TextStyle(color: dialogThemeProvider.textPrimary),
              decoration: InputDecoration(
                hintText: 'Add notes (optional)',
                hintStyle: TextStyle(color: dialogThemeProvider.textSecondary),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.note, color: dialogThemeProvider.textSecondary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'Cancel',
                style: TextStyle(color: dialogThemeProvider.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _notesController.text = notesController.text.trim();
                Navigator.of(context).pop(notesController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5DADE2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Calculate totals directly from controllers for real-time updates
  int get totalNotes {
    final qty500 = int.tryParse(_note500Controller.text) ?? 0;
    final qty200 = int.tryParse(_note200Controller.text) ?? 0;
    final qty100 = int.tryParse(_note100Controller.text) ?? 0;
    final qty50 = int.tryParse(_note50Controller.text) ?? 0;
    final qty20 = int.tryParse(_note20Controller.text) ?? 0;
    final qty10 = int.tryParse(_note10Controller.text) ?? 0;
    return qty500 + qty200 + qty100 + qty50 + qty20 + qty10;
  }
  
  double get totalAmount {
    final qty500 = int.tryParse(_note500Controller.text) ?? 0;
    final qty200 = int.tryParse(_note200Controller.text) ?? 0;
    final qty100 = int.tryParse(_note100Controller.text) ?? 0;
    final qty50 = int.tryParse(_note50Controller.text) ?? 0;
    final qty20 = int.tryParse(_note20Controller.text) ?? 0;
    final qty10 = int.tryParse(_note10Controller.text) ?? 0;
    final otherPlus = double.tryParse(_otherPlusController.text) ?? 0;
    final otherMinus = double.tryParse(_otherMinusController.text) ?? 0;
    return (qty500 * 500) + 
           (qty200 * 200) + 
           (qty100 * 100) + 
           (qty50 * 50) + 
           (qty20 * 20) + 
           (qty10 * 10) +
           otherPlus -
           otherMinus;
  }

  String _numberToWords(double amount) {
    if (amount == 0) return 'Zero Rupee';
    
    int n = amount.toInt();
    if (n == 0) return 'Zero Rupee';
    
    // Convert to words using Indian numbering system
    String result = '';
    
    // Crores
    if (n >= 10000000) {
      final crores = n ~/ 10000000;
      result += '${_convertNumber(crores)} Crore${crores > 1 ? 's' : ''} ';
      n = n % 10000000;
    }
    
    // Lakhs
    if (n >= 100000) {
      final lakhs = n ~/ 100000;
      result += '${_convertNumber(lakhs)} Lakh${lakhs > 1 ? 's' : ''} ';
      n = n % 100000;
    }
    
    // Thousands
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      result += '${_convertNumber(thousands)} Thousand ';
      n = n % 1000;
    }
    
    // Hundreds
    if (n > 0) {
      result += _convertNumber(n);
    }
    
    result = result.trim();
    return '$result Rupee${amount.toInt() > 1 ? 's' : ''}';
  }

  String _convertNumber(int n) {
    if (n == 0) return '';
    if (n < 20) {
      final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 
                     'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 
                     'Seventeen', 'Eighteen', 'Nineteen'];
      return ones[n];
    } else if (n < 100) {
      final tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
      final ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
      final ten = tens[n ~/ 10];
      final one = ones[n % 10];
      return one.isEmpty ? ten : '$ten $one';
    } else {
      final hundreds = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'];
      final hundred = hundreds[n ~/ 100];
      final remainder = n % 100;
      if (remainder > 0) {
        return '$hundred Hundred ${_convertNumber(remainder)}';
      }
      return '$hundred Hundred';
    }
  }

  Color _getNoteColor(int denomination) {
    switch (denomination) {
      case 500:
        return const Color(0xFF8B9A46); // Greenish-grey
      case 200:
        return const Color(0xFFFFA500); // Orange
      case 100:
        return const Color(0xFF9B59B6); // Purple/Lavender
      case 50:
        return const Color(0xFF00CED1); // Cyan/Light Blue
      case 20:
        return const Color(0xFFADFF2F); // Yellow-Green
      case 10:
        return const Color(0xFFFFB6C1); // Light Pink/Brown
      default:
        return Colors.grey;
    }
  }

  String _getNoteImagePath(int denomination) {
    switch (denomination) {
      case 500:
        return 'assets/notesimages/500notes.jpg';
      case 200:
        return 'assets/notesimages/200notes.png';
      case 100:
        return 'assets/notesimages/100notes.png';
      case 50:
        return 'assets/notesimages/50rs.png';
      case 20:
        return 'assets/notesimages/10notes.png'; // Using 10notes.png for 20 as placeholder
      case 10:
        return 'assets/notesimages/10not.png';
      default:
        return 'assets/notesimages/100notes.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DADE2),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Icon(Icons.calculate, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              widget.editData != null ? 'Edit Cash Count' : 'Cash Counter',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        actions: [
          // History Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.history, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CashCounterHistoryScreen(),
                  ),
                );
                if (result == true) {
                  // Reload if needed
                }
              },
              tooltip: 'History',
            ),
          ),
          // Refresh Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _resetAll,
              tooltip: 'Reset',
            ),
          ),
          // Save Button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      widget.editData != null ? Icons.update : Icons.save,
                      color: Colors.white,
                      size: 18,
                    ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _isSaving ? null : _saveData,
              tooltip: widget.editData != null ? 'Update' : 'Save',
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // Enhanced Column Headers
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: themeProvider.cardBackground,
                border: Border(
                  bottom: BorderSide(color: themeProvider.borderColor, width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(Icons.currency_rupee, size: 14, color: themeProvider.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Currency',
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.numbers, size: 14, color: themeProvider.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'QTY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeProvider.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 24,
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.attach_money, size: 14, color: themeProvider.textSecondary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Amount',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: themeProvider.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Currency Rows
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _buildCurrencyRow(500, _getNoteColor(500), _note500Controller, _note500Qty),
                  _buildCurrencyRow(200, _getNoteColor(200), _note200Controller, _note200Qty),
                  _buildCurrencyRow(100, _getNoteColor(100), _note100Controller, _note100Qty),
                  _buildCurrencyRow(50, _getNoteColor(50), _note50Controller, _note50Qty),
                  _buildCurrencyRow(20, _getNoteColor(20), _note20Controller, _note20Qty),
                  _buildCurrencyRow(10, _getNoteColor(10), _note10Controller, _note10Qty),
                  _buildOtherAmountRow(),
                  const SizedBox(height: 120), // Space for footer
                ],
              ),
            ),
            // Enhanced Footer - Fixed Position with Better Layout
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF5DADE2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Row: Total Label and Notes Count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Calculator icon, Total, Speaker
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Icon(Icons.calculate, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.volume_up, color: Colors.white.withOpacity(0.9), size: 14),
                        ],
                      ),
                      // Notes Count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$totalNotes Notes',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Second Row: Total Amount - Prominent Display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '₹${NumberFormat('#,##,###').format(totalAmount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Third Row: Number to words
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _numberToWords(totalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyRow(
    int denomination,
    Color noteColor,
    TextEditingController controller,
    int quantity,
  ) {
    // Calculate amount from controller text for real-time updates
    final qty = int.tryParse(controller.text) ?? 0;
    final amount = denomination * qty;

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeProvider.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Currency Note Image - Reduced Size
          Container(
            width: 60,
            height: 42,
            decoration: BoxDecoration(
              color: themeProvider.cardBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: noteColor.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: noteColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _getNoteImagePath(denomination),
                fit: BoxFit.contain,
                width: 60,
                height: 42,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to colored badge if image fails to load
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          noteColor,
                          noteColor.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '₹$denomination',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Denomination and multiplication - Compact
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₹$denomination',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
              Text(
                '×',
                style: TextStyle(
                  fontSize: 11,
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          // Minus Button - Smaller
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.red.shade300,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  final currentValue = int.tryParse(controller.text) ?? 0;
                  if (currentValue > 0) {
                    controller.text = (currentValue - 1).toString();
                    _updateCalculations();
                  }
                },
                child: Icon(
                  Icons.remove,
                  color: Colors.red.shade700,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Enhanced Quantity Input - Flexible
          Flexible(
            flex: 1,
            child: Container(
              constraints: const BoxConstraints(minWidth: 50, maxWidth: 80),
              decoration: BoxDecoration(
                color: themeProvider.backgroundColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: themeProvider.borderColor,
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
                onChanged: (value) {
                  _updateCalculations();
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Plus Button - Smaller
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.green.shade300,
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  final currentValue = int.tryParse(controller.text) ?? 0;
                  controller.text = (currentValue + 1).toString();
                  _updateCalculations();
                },
                child: Icon(
                  Icons.add,
                  color: Colors.green.shade700,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Equals sign - Smaller
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: themeProvider.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              '=',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: themeProvider.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Enhanced Amount Display - Expanded to show full amount
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade50,
                    Colors.blue.shade100.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.blue.shade200,
                  width: 1.5,
                ),
              ),
              child: Text(
                '₹${NumberFormat('#,##,###').format(amount)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherAmountRow() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: themeProvider.borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Section: Other Plus ₹
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle, color: Colors.green.shade700, size: 14),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Plus ₹',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Button
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(7),
                            onTap: () {
                              final currentValue = double.tryParse(_otherPlusController.text) ?? 0;
                              if (currentValue > 0) {
                                _otherPlusController.text = (currentValue - 1).toStringAsFixed(0);
                                _updateCalculations();
                              }
                            },
                            child: Icon(
                              Icons.remove,
                              color: Colors.red.shade700,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Input Field
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 50, maxWidth: 80),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _otherPlusController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimary,
                            ),
                            onChanged: (value) {
                              _updateCalculations();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                              isDense: true,
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Plus Button
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(7),
                            onTap: () {
                              final currentValue = double.tryParse(_otherPlusController.text) ?? 0;
                              _otherPlusController.text = (currentValue + 1).toStringAsFixed(0);
                              _updateCalculations();
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green.shade700,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right Section: Other Minus ₹
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove_circle, color: Colors.red.shade700, size: 14),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          'Minus ₹',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minus Button
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.red.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(7),
                            onTap: () {
                              final currentValue = double.tryParse(_otherMinusController.text) ?? 0;
                              if (currentValue > 0) {
                                _otherMinusController.text = (currentValue - 1).toStringAsFixed(0);
                                _updateCalculations();
                              }
                            },
                            child: Icon(
                              Icons.remove,
                              color: Colors.red.shade700,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Input Field
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 50, maxWidth: 80),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            controller: _otherMinusController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.textPrimary,
                            ),
                            onChanged: (value) {
                              _updateCalculations();
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                              isDense: true,
                              hintText: '0',
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Plus Button
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: Colors.green.shade300,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(7),
                            onTap: () {
                              final currentValue = double.tryParse(_otherMinusController.text) ?? 0;
                              _otherMinusController.text = (currentValue + 1).toStringAsFixed(0);
                              _updateCalculations();
                            },
                            child: Icon(
                              Icons.add,
                              color: Colors.green.shade700,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

