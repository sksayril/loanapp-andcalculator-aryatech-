import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:package_info_plus/package_info_plus.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/language_provider.dart' as lang;
import 'screens/qa_screen.dart';
import 'screens/view_loan_profiles_screen.dart';
import 'screens/refer_and_earn_screen.dart';
import 'cibil_score_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _appVersion = '1.0.0';
  
  // Avatar colors for random avatar generation
  static const List<Color> _avatarColors = [
    Color(0xFFFFD1B3), // Peach
    Color(0xFFFFE4B3), // Light Peach
    Color(0xFFFFF5B3), // Cream
    Color(0xFFE8F5FF), // Light Blue
    Color(0xFFFFE8F0), // Light Pink
    Color(0xFFE8FFE8), // Light Green
    Color(0xFFF0E8FF), // Light Purple
  ];
  
  Color _avatarColor = const Color(0xFFFFD1B3);
  String _avatarInitials = 'U';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      setState(() {
        _appVersion = '4.0.1';
      });
    }
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load user data
    String? savedName = prefs.getString('profile_user_name');
    String? savedAvatarColor = prefs.getString('profile_avatar_color');
    
    // Don't generate random name - show "Add your name" if empty
    if (savedName == null || savedName.isEmpty) {
      savedName = '';
    }
    
    Color avatarColor;
    if (savedAvatarColor == null) {
      // Generate random avatar color
      avatarColor = _avatarColors[Random().nextInt(_avatarColors.length)];
      await prefs.setString('profile_avatar_color', avatarColor.value.toString());
    } else {
      avatarColor = Color(int.parse(savedAvatarColor));
    }
    
    // Generate initials from name (or 'U' if empty)
    String initials = savedName != null && savedName.isNotEmpty 
        ? _getInitials(savedName) 
        : 'U';
    
    if (mounted) {
      setState(() {
        _userName = savedName ?? '';
        _avatarColor = avatarColor;
        _avatarInitials = initials;
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Navy Blue Gradient Header
              _buildGradientHeader(),
              // White Card Menu Section
              _buildMenuSection(),
              // Logout Button (REMOVED)
              // _buildLogoutButton(),
              // Secured By Text
              _buildSecuredByText(),
              // App Version
              _buildAppVersion(),
              const SizedBox(height: 100), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3A5C), // Dark navy blue
            Color(0xFF2C5282), // Medium navy blue
          ],
        ),
      ),
      child: Column(
        children: [
          // Header Row with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              GestureDetector(
                onTap: () => _showEditProfileDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Avatar with green checkmark
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _avatarColor,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                        ),
                        child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _avatarInitials,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C5282),
                          ),
                        ),
                      ),
              ),
              // Green checkmark badge
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Name
                Text(
                  _userName.isEmpty ? 'Add your name' : _userName,
                  style: const TextStyle(
              fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
          const SizedBox(height: 16),
          // KYC Verified Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade700.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade400, width: 1.5),
                  ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user, color: Colors.green.shade300, size: 18),
                const SizedBox(width: 8),
                Text(
                  'KYC VERIFIED',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.locale.languageCode == 'en';
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.themeMode == ThemeMode.dark
            ? themeProvider.cardBackground
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
          child: Column(
            children: [
        _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF2196F3),
            title: 'My Loans',
            subtitle: 'Manage active & closed loans',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ViewLoanProfilesScreen(),
              ),
            );
          },
        ),
          _buildDivider(),
        _buildMenuItem(
            icon: Icons.trending_up,
            iconBgColor: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF9C27B0),
            title: 'Credit History',
            subtitle: 'View CIBIL score details',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CibilScoreScreen(),
              ),
            );
          },
        ),
          _buildDivider(),
        _buildMenuItem(
            icon: Icons.card_giftcard,
            iconBgColor: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF1E3A5F),
            title: 'Refer & Earn',
            subtitle: 'Invite friends and earn rewards',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ReferAndEarnScreen(),
              ),
            );
          },
        ),
          _buildDivider(),
        _buildMenuItem(
            icon: Icons.translate,
            iconBgColor: const Color(0xFFE0F2F1),
            iconColor: const Color(0xFF009688),
            title: 'App Language',
            subtitle: null,
            trailing: Text(
              isEnglish ? 'English' : 'हिंदी',
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _showLanguageDialog(),
        ),
          _buildDivider(),
        _buildMenuItem(
            icon: Icons.headset_mic_outlined,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF9800),
            title: 'Help & Support',
            subtitle: null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QAScreen(),
              ),
            );
          },
        ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: const Color(0xFF3F51B5),
            title: 'Privacy Policy',
            subtitle: null,
            onTap: () {
              _showPrivacyPolicyDialog();
            },
            showArrow: true,
          ),
      ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon with circular background
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                icon,
                  color: iconColor,
                size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                        fontWeight: FontWeight.w600,
                    color: themeProvider.textPrimary,
                  ),
                ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeProvider.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing widget or arrow
              if (trailing != null)
                trailing
              else if (showArrow)
              Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                color: themeProvider.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 16,
      color: themeProvider.themeMode == ThemeMode.dark
          ? themeProvider.borderColor
          : Colors.grey.shade200,
    );
  }

  // Logout Button (REMOVED)
  /* Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutDialog(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red.shade600, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  } */

  Widget _buildSecuredByText() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, color: Colors.grey.shade400, size: 16),
          const SizedBox(width: 6),
          Text(
            'SECURED BY FINSAFE BANK',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppVersion() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'App Version $_appVersion',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final localizations = lang.AppLocalizations.of(context);
    final isEnglish = languageProvider.locale.languageCode == 'en';

    showDialog(
      context: context,
      builder: (context) {
        final dialogThemeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor: dialogThemeProvider.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            localizations?.selectLanguage ?? 'Select Language',
            style: TextStyle(color: dialogThemeProvider.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language, color: Colors.blue),
                title: Text(
                  'English',
                  style: TextStyle(color: dialogThemeProvider.textPrimary),
                ),
                trailing: isEnglish ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  languageProvider.setLanguage(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.orange),
                title: Text(
                  'हिंदी (Hindi)',
                  style: TextStyle(color: dialogThemeProvider.textPrimary),
                ),
                trailing: !isEnglish ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  languageProvider.setLanguage(const Locale('hi'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyPolicyDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Privacy Policy',
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Text(
              'Your privacy is important to us. This app collects and stores data locally on your device for calculation purposes. No personal data is shared with third parties without your consent.\n\nFor more information, please contact our support team.',
              style: TextStyle(
                color: themeProvider.textPrimary,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Logout Dialog (REMOVED)
  /* void _showLogoutDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeProvider.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text(
            'Logout',
            style: TextStyle(
              color: themeProvider.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: themeProvider.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: themeProvider.textSecondary),
                ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
        );
      },
    );
  } */

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    Color selectedColor = _avatarColor;
    
    showDialog(
      context: context,
      builder: (context) {
        final dialogThemeProvider = Provider.of<ThemeProvider>(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogThemeProvider.cardBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: dialogThemeProvider.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Color Selection
                    Text(
                      'Avatar Color',
                      style: TextStyle(
                        color: dialogThemeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _avatarColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF1A3A5C) : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Color(0xFF1A3A5C), size: 24)
                                : null,
                                    ),
                                  );
                                }).toList(),
                    ),
                    const SizedBox(height: 20),
                    // Name Field
                    Text(
                      'Full Name',
                      style: TextStyle(
                        color: dialogThemeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: dialogThemeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: dialogThemeProvider.textSecondary),
                        filled: true,
                        fillColor: dialogThemeProvider.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dialogThemeProvider.borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: dialogThemeProvider.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1A3A5C), width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: dialogThemeProvider.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Allow empty name - will show "Add your name" when empty
                    setState(() {
                      _userName = nameController.text.trim();
                      _avatarColor = selectedColor;
                      _avatarInitials = _userName.isNotEmpty 
                          ? _getInitials(_userName) 
                          : 'U';
                    });
                    
                    // Save to local storage
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('profile_user_name', _userName);
                    await prefs.setString('profile_avatar_color', selectedColor.value.toString());
                    
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile updated successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3A5C),
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
      },
    );
  }
}
