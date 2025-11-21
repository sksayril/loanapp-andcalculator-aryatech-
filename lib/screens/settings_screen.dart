import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../providers/language_provider.dart' as lang;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigo.shade400,
                    Colors.indigo.shade600,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
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
                      Icons.settings,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<lang.LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      final localizations = lang.AppLocalizations.of(context);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations?.appSettings ?? 'App Settings',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations?.customizeExperience ?? 'Customize your app experience',
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
            
            const SizedBox(height: 32),
            
            // Profile Theme Section
            Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return Text(
                  localizations?.profileTheme ?? 'Profile & Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            // Theme Mode Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeProvider.borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.palette,
                          color: themeProvider.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<lang.LanguageProvider>(
                              builder: (context, languageProvider, _) {
                                final localizations = lang.AppLocalizations.of(context);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations?.themeMode ?? 'Theme Mode',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizations?.chooseTheme ?? 'Choose light or dark mode',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.textSecondary,
                                      ),
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
                  const SizedBox(height: 20),
                  // Light Mode Option
                  _buildThemeOption(
                    context,
                    themeProvider,
                    'Light Mode',
                    Icons.light_mode,
                    ThemeMode.light,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),
                  // Dark Mode Option
                  _buildThemeOption(
                    context,
                    themeProvider,
                    'Dark Mode',
                    Icons.dark_mode,
                    ThemeMode.dark,
                    Colors.blue,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Language Section
            Text(
              'Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeProvider.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeProvider.borderColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.language,
                          color: themeProvider.textPrimary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer<lang.LanguageProvider>(
                              builder: (context, languageProvider, _) {
                                final localizations = lang.AppLocalizations.of(context);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations?.selectLanguage ?? 'Select Language',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: themeProvider.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      localizations?.chooseLanguage ?? 'Choose your preferred language',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: themeProvider.textSecondary,
                                      ),
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
                  const SizedBox(height: 20),
                  Consumer<lang.LanguageProvider>(
                    builder: (context, languageProvider, _) {
                      final localizations = lang.AppLocalizations.of(context);
                      return Column(
                        children: [
                          _buildLanguageOption(
                            context,
                            themeProvider,
                            localizations?.english ?? 'English',
                            'en',
                            Icons.language,
                            Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _buildLanguageOption(
                            context,
                            themeProvider,
                            localizations?.hindi ?? 'हिंदी (Hindi)',
                            'hi',
                            Icons.translate,
                            Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional Settings
            Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return Text(
                  localizations?.appInformation ?? 'App Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textPrimary,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            
            Consumer<lang.LanguageProvider>(
              builder: (context, languageProvider, _) {
                final localizations = lang.AppLocalizations.of(context);
                return _buildInfoCard(
                  themeProvider,
                  localizations?.appVersion ?? 'App Version',
                  '1.0.0',
                  Icons.info_outline,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String title,
    IconData icon,
    ThemeMode mode,
    Color iconColor,
  ) {
    final isSelected = themeProvider.themeMode == mode;
    
    return GestureDetector(
      onTap: () {
        themeProvider.setTheme(mode);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (mode == ThemeMode.dark
                  ? Colors.blue.shade50.withOpacity(0.3)
                  : Colors.orange.shade50.withOpacity(0.3))
              : themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? iconColor.withOpacity(0.5)
                : themeProvider.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: themeProvider.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageOption(
    BuildContext context,
    ThemeProvider themeProvider,
    String title,
    String languageCode,
    IconData icon,
    Color iconColor,
  ) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSelected = languageProvider.locale.languageCode == languageCode;
    
    return GestureDetector(
      onTap: () {
        languageProvider.setLanguage(Locale(languageCode));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withOpacity(0.1)
              : themeProvider.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? iconColor.withOpacity(0.5)
                : themeProvider.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: themeProvider.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: iconColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeProvider themeProvider,
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeProvider.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: themeProvider.borderColor,
          width: 1,
        ),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeProvider.textPrimary, size: 24),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  value,
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
    );
  }
}

