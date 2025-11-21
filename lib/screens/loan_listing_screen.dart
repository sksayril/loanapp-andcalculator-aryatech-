import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class LoanListingScreen extends StatefulWidget {
  final String loanType;
  final String amountRange;
  final Color primaryColor;
  final String? initialCategoryId;

  const LoanListingScreen({
    super.key,
    required this.loanType,
    required this.amountRange,
    required this.primaryColor,
    this.initialCategoryId,
  });

  @override
  State<LoanListingScreen> createState() => _LoanListingScreenState();
}

class _LoanListingScreenState extends State<LoanListingScreen> {
  List<LoanData> _loans = [];
  List<LoanCategory> _categories = [];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRefreshing = false;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    // Set initial category ID if provided
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
    }
    _fetchLoans();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await LoanApiService.fetchCategoriesFromApi();
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      // Silently fail - categories are optional
      // Try fallback method
      try {
        final categories = await LoanApiService.fetchCategories();
        if (mounted) {
          setState(() {
            _categories = categories;
          });
        }
      } catch (e2) {
        // Categories are optional, continue without them
      }
    }
  }

  Future<void> _fetchLoans() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      LoanApiResponse apiResponse;
      
      // Use category-specific endpoint if categoryId is provided
      if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
        apiResponse = await LoanApiService.fetchLoansByCategoryId(_selectedCategoryId!);
      } else {
        apiResponse = await LoanApiService.fetchActiveLoans();
      }
      
      // Convert API data to LoanData format
      final loans = apiResponse.loans
          .where((loan) => loan.isActive ?? true) // Only show active loans
          .map((apiLoan) {
        return LoanData(
          title: apiLoan.title ?? 'Loan',
          companyName: apiLoan.companyName ?? 'Financial Institution',
          description: apiLoan.description ?? 'Get instant loans with flexible repayment options.',
          interestRate: apiLoan.interestRate ?? 'N/A',
          url: apiLoan.url ?? 'https://example.com',
          category: apiLoan.category ?? apiResponse.category,
          bankLogo: apiLoan.bankLogo,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _loans = loans;
          _totalCount = apiResponse.count;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
    _fetchLoans();
  }

  Future<void> _refreshLoans() async {
    setState(() {
      _isRefreshing = true;
    });
    await _fetchLoans();
  }

  void _showApplyNowConfirmation(LoanData loan) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: themeProvider.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Apply for Loan',
                  style: TextStyle(
                    color: themeProvider.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to be redirected to ${loan.companyName}\'s website to complete your loan application.',
                style: TextStyle(
                  color: themeProvider.textPrimary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: widget.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: widget.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Make sure you have all required documents ready before proceeding.',
                        style: TextStyle(
                          color: themeProvider.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: themeProvider.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close bottom sheet
                _launchURL(loan.url);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        // Open in external browser (Chrome/Default browser)
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not launch $url'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: widget.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.loanType} - Loans',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
              onPressed: _isRefreshing ? null : _refreshLoans,
              tooltip: 'Refresh loans',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.primaryColor,
                  widget.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Available Loans',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Amount Range: ${widget.amountRange}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                if (_totalCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total: $_totalCount loan${_totalCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Category filter hidden as per requirements
          // Loan List
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _loans.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _refreshLoans,
                            color: widget.primaryColor,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final isTablet = constraints.maxWidth > 700;
                                final crossAxisCount = isTablet ? 3 : 2;
                                // Increased aspect ratio to give more vertical space for full logo display
                                final childAspectRatio = isTablet ? 1.0 : 0.75;
                                return GridView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: childAspectRatio,
                                  ),
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: _loans.length,
                                  itemBuilder: (context, index) {
                                    return _buildLoanCard(_loans[index]);
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanCard(LoanData loan) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accent = widget.primaryColor;
    final accentSoft = _getCardAccentColor(accent);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLoanDetails(loan),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentSoft.withOpacity(0.55),
                themeProvider.cardBackground,
              ],
            ),
            border: Border.all(
              color: accentSoft.withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ensure logo has enough space and is not constrained
                    SizedBox(
                      height: 72,
                      child: Center(
                        child: _buildBankLogo(loan.bankLogo, size: 68),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        loan.companyName.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        loan.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: themeProvider.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (loan.category?.name != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        loan.category!.name!,
                        style: TextStyle(
                          fontSize: 10,
                          color: themeProvider.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6, bottom: 0),
                child: SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // Pill shape
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _getGradientColors(widget.primaryColor),
                      ),
                      boxShadow: [
                        // Neumorphic shadows - light highlight on top-left
                        BoxShadow(
                          color: Colors.white.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(-2, -2),
                          spreadRadius: 0,
                        ),
                        // Dark shadow on bottom-right - based on category color
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(2, 2),
                          spreadRadius: 0,
                        ),
                        // Soft diffused shadow - based on category color
                        BoxShadow(
                          color: widget.primaryColor.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showLoanDetails(loan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
                        minimumSize: const Size(double.infinity, 34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Pill shape
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      child: const Text(
                        'APPLY NOW',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
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

  Color _getCardAccentColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + 0.25).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // Generate gradient colors based on primary color
  List<Color> _getGradientColors(Color primaryColor) {
    final hsl = HSLColor.fromColor(primaryColor);
    
    // Lighter version (top-left)
    final lighter = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    
    // Original color (middle)
    final medium = primaryColor;
    
    // Darker version (bottom-right)
    final darker = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    
    return [lighter, medium, darker];
  }

  void _showLoanDetails(LoanData loan) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: themeProvider.cardBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: themeProvider.borderColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildBankLogo(loan.bankLogo, size: 80),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loan.companyName,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      loan.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: themeProvider.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            loan.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: themeProvider.textPrimary,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailChip(
                                  Icons.percent,
                                  'Interest Rate',
                                  loan.interestRate,
                                  Colors.green,
                                ),
                              ),
                              if (loan.category != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDetailChip(
                                    Icons.category,
                                    'Category',
                                    loan.category!.name ?? 'N/A',
                                    Colors.purple,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30), // Pill shape
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getGradientColors(widget.primaryColor),
                          ),
                          boxShadow: [
                            // Neumorphic shadows - light highlight on top-left
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(-3, -3),
                              spreadRadius: 0,
                            ),
                            // Dark shadow on bottom-right - based on category color
                            BoxShadow(
                              color: widget.primaryColor.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(4, 4),
                              spreadRadius: 0,
                            ),
                            // Soft diffused shadow - based on category color
                            BoxShadow(
                              color: widget.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showApplyNowConfirmation(loan);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // Pill shape
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.open_in_browser, color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                'APPLY NOW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 3,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Provider.of<ThemeProvider>(context, listen: false).textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading loans...',
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Loans',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchLoans,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: themeProvider.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Loans Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no active loans available at the moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshLoans,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? categoryId, bool isSelected) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onCategorySelected(selected ? categoryId : null);
      },
      selectedColor: widget.primaryColor.withOpacity(0.2),
      checkmarkColor: widget.primaryColor,
      backgroundColor: themeProvider.cardBackground,
      labelStyle: TextStyle(
        color: isSelected ? widget.primaryColor : themeProvider.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? widget.primaryColor : themeProvider.borderColor,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildBankLogo(String? bankLogoUrl, {double size = 64}) {
    final iconSize = size * 0.5;
    return bankLogoUrl != null && bankLogoUrl.isNotEmpty
        ? SizedBox(
            width: size,
            height: size,
            child: Image.network(
              bankLogoUrl,
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Show default icon if image fails to load
                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: widget.primaryColor,
                    size: iconSize,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: iconSize * 0.75,
                    height: iconSize * 0.75,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(widget.primaryColor),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          )
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.primaryColor.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.account_balance,
              color: widget.primaryColor,
              size: iconSize,
            ),
          );
  }
}

class LoanData {
  final String title;
  final String companyName;
  final String description;
  final String interestRate;
  final String url;
  final LoanCategory? category;
  final String? bankLogo;

  LoanData({
    required this.title,
    required this.companyName,
    required this.description,
    required this.interestRate,
    required this.url,
    this.category,
    this.bankLogo,
  });
}

