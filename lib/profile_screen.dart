import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/language_provider.dart' as lang;
import 'screens/qa_screen.dart';
import 'screens/account_screen.dart';
import 'screens/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = 'Miranda West';
  String _userHandle = '@mirandawest';
  String _nickName = 'User'; // Default nickname
  
  // List of animal emojis
  static const List<String> _animalEmojis = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
    '🦁', '🐮', '🐷', '🐽', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤',
    '🦆', '🦅', '🦉', '🦇', '🐺', '🐗', '🐴', '🦄', '🐝', '🐛',
    '🦋', '🐌', '🐞', '🐜', '🦟', '🦗', '🕷️', '🦂', '🐢', '🐍',
    '🦎', '🦖', '🦕', '🐙', '🦑', '🦐', '🦞', '🦀', '🐡', '🐠',
    '🐟', '🐬', '🐳', '🐋', '🦈', '🐊', '🐅', '🐆', '🦓', '🦍',
    '🦧', '🐘', '🦛', '🦏', '🐪', '🐫', '🦒', '🦘', '🦡', '🐾',
  ];
  
  String _animalEmoji = '🐱'; // Default emoji
  bool _isLoadingEmoji = true;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if profile has been initialized before
    final isProfileInitialized = prefs.getBool('profile_initialized') ?? false;
    
    if (!isProfileInitialized) {
      // Set default profile values for first-time users
      await prefs.setString('profile_user_name', 'Miranda West');
      await prefs.setString('profile_nickname', 'User');
      await prefs.setString('profile_user_handle', '@mirandawest');
      await prefs.setBool('profile_initialized', true);
    }
    
    // Load user name, handle, and nickname with defaults
    setState(() {
      _userName = prefs.getString('profile_user_name') ?? 'Miranda West';
      _userHandle = prefs.getString('profile_user_handle') ?? '@mirandawest';
      _nickName = prefs.getString('profile_nickname') ?? 'User';
    });
    
    // Load animal emoji
    String? savedEmoji = prefs.getString('device_animal_emoji');
    
    if (savedEmoji == null || savedEmoji.isEmpty) {
      // Generate random emoji for this device
      final random = Random();
      savedEmoji = _animalEmojis[random.nextInt(_animalEmojis.length)];
      await prefs.setString('device_animal_emoji', savedEmoji);
    }
    
    if (mounted) {
      setState(() {
        _animalEmoji = savedEmoji!;
        _isLoadingEmoji = false;
        _isLoadingProfile = false;
      });
    }
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
              // Gradient Header with Profile
              _buildGradientHeader(),
              // Menu Items Section
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF87CEEB), // Light blue
            const Color(0xFF9370DB), // Purple
          ],
        ),
      ),
      child: Row(
        children: [
          // Profile Picture with Edit Icon Overlay
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _isLoadingEmoji
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF87CEEB),
                              const Color(0xFF9370DB),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _animalEmoji,
                            style: const TextStyle(fontSize: 50),
                          ),
                        ),
                      ),
              ),
              // Small house icon overlay
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade300,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.home,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Name, Nickname, and Username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (_nickName.isNotEmpty && _nickName != 'User') ...[
                  const SizedBox(height: 4),
                  Text(
                    _nickName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.95),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _userHandle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          // Edit Profile Button
          GestureDetector(
            onTap: () => _showEditProfileDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'Edit Profile',
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
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
        _buildMenuItem(
          icon: Icons.people,
          title: 'Account',
          color: const Color(0xFF87CEEB),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AccountScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.notifications,
          title: 'Notifications',
          color: const Color(0xFFDDA0DD), // Light purple
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.language,
          title: 'Language',
          color: const Color(0xFF87CEEB),
          onTap: () {
            _showLanguageDialog();
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.palette,
          title: 'Theme',
          color: Colors.indigo.shade300,
          onTap: () {
            _showThemeDialog();
          },
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Q&A',
          color: Colors.teal.shade300,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QAScreen(),
              ),
            );
          },
        ),
            ],
          ),
        ),
        // Add bottom padding to account for navigation bar
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: themeProvider.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: themeProvider.textPrimary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: themeProvider.textSecondary,
              ),
            ],
          ),
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
          title: Text(
            localizations?.selectLanguage ?? 'Select Language',
            style: TextStyle(color: dialogThemeProvider.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.language, color: Colors.blue),
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
                leading: Icon(Icons.translate, color: Colors.orange),
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

  void _showThemeDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (context) {
        final dialogThemeProvider = Provider.of<ThemeProvider>(context);
        return AlertDialog(
          backgroundColor: dialogThemeProvider.cardBackground,
          title: Text(
            'Select Theme',
            style: TextStyle(color: dialogThemeProvider.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.wb_sunny, color: Colors.orange),
                title: Text(
                  'Light Mode',
                  style: TextStyle(color: dialogThemeProvider.textPrimary),
                ),
                trailing: !isDark ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode, color: Colors.blue),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(color: dialogThemeProvider.textPrimary),
                ),
                trailing: isDark ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  themeProvider.setTheme(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userName);
    final handleController = TextEditingController(text: _userHandle);
    final nickNameController = TextEditingController(text: _nickName);
    String selectedEmoji = _animalEmoji;
    
    showDialog(
      context: context,
      builder: (context) {
        final dialogThemeProvider = Provider.of<ThemeProvider>(context);
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: dialogThemeProvider.cardBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                    // Emoji Selection
                    Text(
                      'Profile Picture (Emoji)',
                      style: TextStyle(
                        color: dialogThemeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: dialogThemeProvider.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dialogThemeProvider.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF87CEEB),
                                  const Color(0xFF9370DB),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                selectedEmoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: _animalEmojis.map((emoji) {
                                  return GestureDetector(
                                    onTap: () {
                                      setDialogState(() {
                                        selectedEmoji = emoji;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: selectedEmoji == emoji
                                            ? const Color(0xFF5DADE2).withOpacity(0.2)
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: selectedEmoji == emoji
                                              ? const Color(0xFF5DADE2)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                          borderSide: const BorderSide(color: Color(0xFF5DADE2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nickname Field
                    Text(
                      'Nickname',
                      style: TextStyle(
                        color: dialogThemeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nickNameController,
                      style: TextStyle(color: dialogThemeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter your nickname',
                        hintStyle: TextStyle(color: dialogThemeProvider.textSecondary),
                        prefixIcon: const Icon(Icons.badge, size: 20),
                        prefixIconColor: dialogThemeProvider.textSecondary,
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
                          borderSide: const BorderSide(color: Color(0xFF5DADE2), width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Handle Field
                    Text(
                      'Username (Handle)',
                      style: TextStyle(
                        color: dialogThemeProvider.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: handleController,
                      style: TextStyle(color: dialogThemeProvider.textPrimary),
                      decoration: InputDecoration(
                        hintText: '@username',
                        hintStyle: TextStyle(color: dialogThemeProvider.textSecondary),
                        prefixIcon: const Icon(Icons.alternate_email, size: 20),
                        prefixIconColor: dialogThemeProvider.textSecondary,
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
                          borderSide: const BorderSide(color: Color(0xFF5DADE2), width: 2),
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
                    if (nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    
                    setState(() {
                      _userName = nameController.text.trim();
                      _nickName = nickNameController.text.trim().isEmpty 
                          ? 'User' 
                          : nickNameController.text.trim();
                      _userHandle = handleController.text.trim().startsWith('@')
                          ? handleController.text.trim()
                          : '@${handleController.text.trim()}';
                      _animalEmoji = selectedEmoji;
                    });
                    
                    // Save to local storage
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('profile_user_name', _userName);
                    await prefs.setString('profile_nickname', _nickName);
                    await prefs.setString('profile_user_handle', _userHandle);
                    await prefs.setString('device_animal_emoji', selectedEmoji);
                    
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
      },
    );
  }
}
