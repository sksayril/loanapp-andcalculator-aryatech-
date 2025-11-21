import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loanNotifications = true;
  bool _priceAlerts = true;
  bool _calculationReminders = false;
  bool _marketingEmails = false;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _loanNotifications = prefs.getBool('notif_loan') ?? true;
      _priceAlerts = prefs.getBool('notif_price') ?? true;
      _calculationReminders = prefs.getBool('notif_calculation') ?? false;
      _marketingEmails = prefs.getBool('notif_marketing') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveNotifications() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('notif_loan', _loanNotifications);
    await prefs.setBool('notif_price', _priceAlerts);
    await prefs.setBool('notif_calculation', _calculationReminders);
    await prefs.setBool('notif_marketing', _marketingEmails);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDA0DD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildSectionTitle('Notification Types'),
                      const SizedBox(height: 12),
                      _buildSwitchTile(
                        title: 'Loan Notifications',
                        subtitle: 'Get notified about new loan offers',
                        value: _loanNotifications,
                        onChanged: (value) => setState(() => _loanNotifications = value),
                        icon: Icons.account_balance_wallet,
                      ),
                      _buildSwitchTile(
                        title: 'Price Alerts',
                        subtitle: 'Alerts for commodity price changes',
                        value: _priceAlerts,
                        onChanged: (value) => setState(() => _priceAlerts = value),
                        icon: Icons.trending_up,
                      ),
                      _buildSwitchTile(
                        title: 'Calculation Reminders',
                        subtitle: 'Reminders to save your calculations',
                        value: _calculationReminders,
                        onChanged: (value) => setState(() => _calculationReminders = value),
                        icon: Icons.calculate,
                      ),
                      _buildSwitchTile(
                        title: 'Marketing Emails',
                        subtitle: 'Receive promotional offers and updates',
                        value: _marketingEmails,
                        onChanged: (value) => setState(() => _marketingEmails = value),
                        icon: Icons.campaign,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveNotifications,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDDA0DD),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: const Color(0xFFDDA0DD)),
        activeColor: const Color(0xFFDDA0DD),
      ),
    );
  }
}

