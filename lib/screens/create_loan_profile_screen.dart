import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/loan_profile.dart';
import '../database/database_helper.dart';
import '../providers/theme_provider.dart';

class CreateLoanProfileScreen extends StatefulWidget {
  const CreateLoanProfileScreen({super.key});

  @override
  State<CreateLoanProfileScreen> createState() => _CreateLoanProfileScreenState();
}

class _CreateLoanProfileScreenState extends State<CreateLoanProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper.instance;

  // Controllers
  final _loanSectorController = TextEditingController();
  final _loanCompanyController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _monthlyEmiController = TextEditingController();
  final _tenureDaysController = TextEditingController();

  bool _isLoading = false;

  // Loan sector options
  final List<String> _loanSectors = [
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Education Loan',
    'Business Loan',
    'Gold Loan',
    'Credit Card Loan',
    'Two Wheeler Loan',
    'Other',
  ];

  String? _selectedSector;

  @override
  void dispose() {
    _loanSectorController.dispose();
    _loanCompanyController.dispose();
    _totalAmountController.dispose();
    _monthlyEmiController.dispose();
    _tenureDaysController.dispose();
    super.dispose();
  }

  Future<void> _saveLoanProfile() async {
    if (_formKey.currentState!.validate() && _selectedSector != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final profile = LoanProfile(
          loanSector: _selectedSector!,
          loanCompany: _loanCompanyController.text.trim(),
          totalAmount: double.parse(_totalAmountController.text.trim()),
          monthlyEmi: double.parse(_monthlyEmiController.text.trim()),
          tenureDays: int.parse(_tenureDaysController.text.trim()),
          createdAt: DateTime.now(),
        );

        await _databaseHelper.insertLoanProfile(profile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loan profile saved successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
          'Create Loan Profile',
          style: TextStyle(
            color: themeProvider.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add Your Loan Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Keep track of all your loans in one place',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Loan Sector Dropdown
              _buildSectionTitle('Loan Sector'),
              const SizedBox(height: 12),
              Builder(
                builder: (context) {
                  final themeProvider = ThemeProvider.of(context);
                  return Container(
                    decoration: BoxDecoration(
                      color: themeProvider.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: themeProvider.themeMode == ThemeMode.dark
                          ? Border.all(color: themeProvider.borderColor)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            themeProvider.themeMode == ThemeMode.dark ? 0.2 : 0.05
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedSector,
                      style: TextStyle(color: themeProvider.textPrimary),
                      dropdownColor: themeProvider.cardBackground,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: themeProvider.cardBackground,
                        prefixIcon: const Icon(Icons.category, color: Colors.pink),
                      ),
                      hint: Text(
                        'Select Loan Sector',
                        style: TextStyle(color: themeProvider.textSecondary),
                      ),
                      items: _loanSectors.map((sector) {
                        return DropdownMenuItem(
                          value: sector,
                          child: Text(
                            sector,
                            style: TextStyle(color: themeProvider.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSector = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a loan sector';
                        }
                        return null;
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Loan Company
              _buildSectionTitle('Loan Company'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _loanCompanyController,
                hint: 'Enter loan company name',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan company name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Total Loan Amount
              _buildSectionTitle('Total Loan Amount'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _totalAmountController,
                hint: 'Enter total loan amount (₹)',
                icon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total loan amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Monthly EMI
              _buildSectionTitle('Monthly EMI'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _monthlyEmiController,
                hint: 'Enter monthly EMI (₹)',
                icon: Icons.payment,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly EMI';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Tenure (Days)
              _buildSectionTitle('Loan Tenure'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _tenureDaysController,
                hint: 'Enter loan tenure in days',
                icon: Icons.calendar_today,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan tenure';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number of days';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.pink.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLoanProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: Colors.white, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Save Loan Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final themeProvider = ThemeProvider.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: themeProvider.themeMode == ThemeMode.dark
            ? Border.all(color: themeProvider.borderColor)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              themeProvider.themeMode == ThemeMode.dark ? 0.2 : 0.05
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: themeProvider.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: themeProvider.textSecondary),
          prefixIcon: Icon(icon, color: Colors.pink),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: themeProvider.cardBackground,
        ),
      ),
    );
  }
}

