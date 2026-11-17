import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyUsername = 'username';
  static const _keyIsLogin = 'isLogin';

  // Simpan session saat login berhasil
  static Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setBool(_keyIsLogin, true);
  }

  // Ambil username yang sedang login
  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? '';
  }

  // Cek sudah login atau belum
  static Future<bool> isLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLogin) ?? false;
  }

  // Hapus session saat logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyIsLogin);
  }
}