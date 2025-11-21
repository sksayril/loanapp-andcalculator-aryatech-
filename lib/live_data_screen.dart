import 'package:flutter/material.dart';
import 'package:emi_calculatornew/services/loan_api_service.dart';
import 'package:emi_calculatornew/screens/loan_listing_screen.dart';
import 'package:emi_calculatornew/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class InstantLoanCategory {
  const InstantLoanCategory({
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.color,
    required this.categoryId,
  });

  final String title;
  final String emoji;
  final String subtitle;
  final Color color;
  final String? categoryId;
}

class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({super.key});

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  List<InstantLoanCategory> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _highlightedIndex = 0;

  // Mapping of category names to emojis and colors
  final Map<String, Map<String, dynamic>> _categoryMetadata = {
    'Personal Loan': {
      'emoji': '😊',
      'subtitle': 'For personal needs',
      'color': Color(0xFF5DADE2),
    },
    'Home Loan': {
      'emoji': '🏡',
      'subtitle': 'For your home needs',
      'color': Color(0xFFAF7AC5),
    },
    'Car Loan': {
      'emoji': '🚗',
      'subtitle': 'Drive your dream ride',
      'color': Color(0xFFF5B041),
    },
    'Gold Loan': {
      'emoji': '🥇',
      'subtitle': 'Unlock the value of gold',
      'color': Color(0xFFF8C471),
    },
    'Education Loan': {
      'emoji': '🎓',
      'subtitle': 'Fund higher studies',
      'color': Color(0xFF48C9B0),
    },
    'Business Loan': {
      'emoji': '💼',
      'subtitle': 'Boost working capital',
      'color': Color(0xFFEC7063),
    },
  };

  final List<String> _desiredOrder = [
    'Personal Loan',
    'Home Loan',
    'Education Loan',
    'Car Loan',
    'Gold Loan',
    'Business Loan',
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await LoanApiService.fetchCategoriesFromApi();
      
      if (mounted) {
        setState(() {
          final mappedCategories = categories.map((category) {
            final name = category.name ?? 'Unknown';
            final metadata = _categoryMetadata[name] ?? {
              'emoji': '💰',
              'subtitle': category.description ?? 'Loan options available',
              'color': Color(0xFF5DADE2),
            };
            
            return InstantLoanCategory(
              title: name,
              emoji: metadata['emoji'] as String,
              subtitle: metadata['subtitle'] as String,
              color: metadata['color'] as Color,
              categoryId: category.id,
            );
          }).toList();

          mappedCategories.sort((a, b) {
            final aIndex = _desiredOrder.indexOf(a.title);
            final bIndex = _desiredOrder.indexOf(b.title);
            final safeA = aIndex == -1 ? _desiredOrder.length : aIndex;
            final safeB = bIndex == -1 ? _desiredOrder.length : bIndex;
            return safeA.compareTo(safeB);
          });

          _categories = mappedCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeProvider.cardBackground,
        title: Text(
          'Loans',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: themeProvider.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textPrimary),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline),
            color: themeProvider.textSecondary,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroCard(),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Choose a loan type'),
                        const SizedBox(height: 10),
                        _buildCategoryGrid(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF5DADE2), Color(0xFF85C1E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '⚡',
                  style: TextStyle(fontSize: 26),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Quick processing\nFast disbursal',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Pick a loan card below to view offers.\nPaperless application, trusted partners, curated for you.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = index == _highlightedIndex;
        return InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            setState(() => _highlightedIndex = index);
            _navigateToLoanListing(category);
          },
          child:           AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Provider.of<ThemeProvider>(context).cardBackground,
              border: Border.all(
                color: isSelected
                    ? category.color
                    : Provider.of<ThemeProvider>(context).borderColor,
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? category.color.withOpacity(0.25)
                      : Provider.of<ThemeProvider>(context).borderColor,
                  blurRadius: isSelected ? 18 : 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmojiBadge(category.emoji, category.color),
                const SizedBox(height: 14),
                Text(
                  category.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Provider.of<ThemeProvider>(context).textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  category.subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Provider.of<ThemeProvider>(context).textSecondary,
                    height: 1.3,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(
                      Icons.bolt,
                      color: category.color,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Check offers',
                      style: TextStyle(
                        color: category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: category.color,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmojiBadge(String emoji, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.14),
        border: Border.all(color: color.withOpacity(0.6), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF5DADE2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: themeProvider.textPrimary,
          ),
        ),
      ],
    );
  }

  void _navigateToLoanListing(InstantLoanCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoanListingScreen(
          loanType: category.title,
          amountRange: 'All amounts',
          primaryColor: category.color,
          initialCategoryId: category.categoryId,
        ),
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
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5DADE2)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading categories...',
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
              'Error Loading Categories',
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
              onPressed: _loadCategories,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5DADE2),
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
}

