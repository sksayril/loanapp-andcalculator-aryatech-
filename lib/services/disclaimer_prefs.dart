import 'package:shared_preferences/shared_preferences.dart';

class DisclaimerPrefs {
  static const String _agreedKey = 'disclaimer_agreed_v1';

  static Future<bool> isAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_agreedKey) ?? false;
  }

  static Future<void> setAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_agreedKey, true);
  }
}

