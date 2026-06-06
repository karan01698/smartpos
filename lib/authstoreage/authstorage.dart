import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {

  // 🔥 SAVE LOGIN
  static Future<void> saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLoggedIn", value);
  }

  // 🔥 GET LOGIN
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userEmail", email);
  }

  // 🔥 GET EMAIL
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userEmail");
  }

  // 🔥 LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> setApprovedSeen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("approved_seen", value);
  }

  static Future<bool> isApprovedSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("approved_seen") ?? false;
  }
}