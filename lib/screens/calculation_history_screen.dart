import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/calculation_history_service.dart';

class CalculationHistoryScreen extends StatefulWidget {
  final String? calculatorType;
  
  const CalculationHistoryScreen({super.key, this.calculatorType});

  @override
  State<CalculationHistoryScreen> createState() => _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState extends State<CalculationHistoryScreen> {
  final CalculationHistoryService _historyService = CalculationHistoryService();
  List<CalculationHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await _historyService.getHistory(
      calculatorType: widget.calculatorType,
    );
    setState(() {
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int id) async {
    await _historyService.deleteCalculation(id);
    _loadHistory();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calculation deleted')),
      );
    }
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to delete all calculations?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _historyService.clearHistory(calculatorType: widget.calculatorType);
      _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final formatCurrency = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final formatDate = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.cardBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.calculatorType != null 
              ? '${_history.firstOrNull?.displayTitle ?? 'History'}'
              : 'Calculation History',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: _history.isNotEmpty
            ? [
                IconButton(
                  icon: Icon(Icons.delete_outline, color: themeProvider.textPrimary),
                  onPressed: _clearAll,
                  tooltip: 'Clear All',
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: themeProvider.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No calculation history',
                        style: TextStyle(
                          fontSize: 18,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final item = _history[index];
                      return _buildHistoryCard(
                        themeProvider,
                        item,
                        formatCurrency,
                        formatDate,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildHistoryCard(
    ThemeProvider themeProvider,
    CalculationHistory item,
    NumberFormat formatCurrency,
    DateFormat formatDate,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCalculatorColor(item.calculatorType).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCalculatorIcon(item.calculatorType),
            color: _getCalculatorColor(item.calculatorType),
            size: 24,
          ),
        ),
        title: Text(
          item.displayTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.textPrimary,
          ),
        ),
        subtitle: Text(
          formatDate.format(item.timestamp),
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () => _deleteItem(item.id),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow('Input', item.inputData, themeProvider),
                const SizedBox(height: 12),
                _buildResultRow('Result', item.resultData, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, Map<String, dynamic> data, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: themeProvider.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.textSecondary,
                    ),
                  ),
                  Text(
                    entry.value.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textPrimary,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color _getCalculatorColor(String type) {
    switch (type) {
      case 'emi':
        return Colors.teal;
      case 'gst':
        return Colors.purple;
      case 'vat':
        return Colors.green;
      case 'ppf':
        return Colors.blue;
      case 'sip':
        return Colors.orange;
      case 'income_tax':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCalculatorIcon(String type) {
    switch (type) {
      case 'emi':
        return Icons.calculate;
      case 'gst':
        return Icons.receipt;
      case 'vat':
        return Icons.attach_money;
      case 'ppf':
        return Icons.account_balance;
      case 'sip':
        return Icons.trending_up;
      case 'income_tax':
        return Icons.account_balance_wallet;
      default:
        return Icons.calculate;
    }
  }
}

