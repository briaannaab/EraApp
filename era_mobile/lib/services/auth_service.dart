import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static int? userId;
  static String? username;
  static String? token;

  static bool get isLoggedIn => userId != null && username != null;

  static Future<void> login({required int id, required String name, required String tok}) async {
    userId = id;
    username = name;
    token = tok;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', id);
    await prefs.setString('username', name);
    await prefs.setString('token', tok);
  }

  static Future<void> logout() async {
    userId = null;
    username = null;
    token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    final name = prefs.getString('username');
    final tok = prefs.getString('token');
    if (id != null && name != null) {
      userId = id;
      username = name;
      token = tok ?? '';
      return true;
    }
    return false;
  }
}
