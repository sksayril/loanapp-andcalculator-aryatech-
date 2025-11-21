import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/loan_profile.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';
import 'create_loan_profile_screen.dart';

class ViewLoanProfilesScreen extends StatefulWidget {
  const ViewLoanProfilesScreen({super.key});

  @override
  State<ViewLoanProfilesScreen> createState() => _ViewLoanProfilesScreenState();
}

class _ViewLoanProfilesScreenState extends State<ViewLoanProfilesScreen> {
  final _databaseHelper = DatabaseHelper.instance;
  List<LoanProfile> _loanProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoanProfiles();
  }

  Future<void> _loadLoanProfiles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profiles = await _databaseHelper.getAllLoanProfiles();
      setState(() {
        _loanProfiles = profiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profiles: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLoanProfile(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan Profile'),
        content: const Text('Are you sure you want to delete this loan profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _databaseHelper.deleteLoanProfile(id);
        _loadLoanProfiles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan profile deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  MaterialColor _getSectorColor(String sector) {
    final colors = {
      'Personal Loan': Colors.purple,
      'Home Loan': Colors.blue,
      'Car Loan': Colors.green,
      'Education Loan': Colors.orange,
      'Business Loan': Colors.red,
      'Gold Loan': Colors.amber,
      'Credit Card Loan': Colors.indigo,
      'Two Wheeler Loan': Colors.teal,
      'Other': Colors.grey,
    };
    return colors[sector] as MaterialColor? ?? Colors.pink;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    
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
          'My Loan Profiles',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: themeProvider.textPrimary),
            onPressed: _loadLoanProfiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _loanProfiles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadLoanProfiles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _loanProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = _loanProfiles[index];
                      return _buildLoanProfileCard(profile);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateLoanProfileScreen(),
            ),
          );
          if (result == true) {
            _loadLoanProfiles();
          }
        },
        backgroundColor: Colors.pink.shade400,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add New',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = ThemeProvider.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.orange.shade100.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.orange.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Loan Profiles Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: themeProvider.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Create your first loan profile to get started',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateLoanProfileScreen(),
                ),
              );
              if (result == true) {
                _loadLoanProfiles();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Loan Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanProfileCard(LoanProfile profile) {
    final MaterialColor sectorColor = _getSectorColor(profile.loanSector);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final themeProvider = ThemeProvider.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: themeProvider.themeMode == ThemeMode.dark
            ? Border.all(color: themeProvider.borderColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              themeProvider.themeMode == ThemeMode.dark ? 0.3 : 0.08
            ),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [sectorColor.shade400, sectorColor.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.loanSector,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.loanCompany,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () => _deleteLoanProfile(profile.id!),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.currency_rupee,
                  'Total Amount',
                  '₹${NumberFormat('#,##,###').format(profile.totalAmount)}',
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.payment,
                  'Monthly EMI',
                  '₹${NumberFormat('#,##,###').format(profile.monthlyEmi)}',
                  Colors.green,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'Tenure',
                        '${(profile.tenureDays / 30).toStringAsFixed(1)} months',
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.date_range,
                        'Created',
                        dateFormat.format(profile.createdAt),
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Additional Info Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeProvider.themeMode == ThemeMode.dark
                        ? Colors.grey.shade900
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: themeProvider.borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAdditionalInfo(
                            'Total Interest',
                            '₹${NumberFormat('#,##,###').format((profile.monthlyEmi * (profile.tenureDays / 30)) - profile.totalAmount)}',
                            Colors.red,
                          ),
                          _buildAdditionalInfo(
                            'Total Payable',
                            '₹${NumberFormat('#,##,###').format(profile.monthlyEmi * (profile.tenureDays / 30))}',
                            Colors.indigo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildProgressBar(profile),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    final themeProvider = ThemeProvider.of(context);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(String label, String value, Color color) {
    final themeProvider = ThemeProvider.of(context);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: themeProvider.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(LoanProfile profile) {
    final themeProvider = ThemeProvider.of(context);
    final monthsElapsed = DateTime.now().difference(profile.createdAt).inDays / 30;
    final totalMonths = profile.tenureDays / 30;
    final progress = monthsElapsed > 0 && totalMonths > 0
        ? (monthsElapsed / totalMonths).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (progress * 100).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loan Progress',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: themeProvider.textPrimary,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: progress > 0.7 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.7 ? Colors.green : Colors.orange,
            ),
          ),
        ),
        const SizedBox(height: 4),
          Text(
            monthsElapsed > 0
                ? '${monthsElapsed.toStringAsFixed(1)} months completed of ${totalMonths.toStringAsFixed(1)} months'
                : 'Loan just started',
            style: TextStyle(
              fontSize: 10,
              color: themeProvider.textSecondary,
            ),
          ),
      ],
    );
  }
}

