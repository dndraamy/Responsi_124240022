import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/wishlist_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _favKey = 'favorite_wishlists_sp';
  static const String _loginKey = 'loginData';
  static const String _userSessionKey = 'current_user';
  static const String _userBoxName = 'users_box';

  // ==================== AUTHENTICATION ====================
  static Box<UserModel> getUserBox() {
    return Hive.box<UserModel>(_userBoxName);
  }

  // Register user baru ke Hive
  static Future<bool> registerUser({
    required String username,
    required String password,
    required String name,
  }) async {
    final box = getUserBox();
    // Cek apakah username sudah ada
    for (var i = 0; i < box.length; i++) {
      final user = box.getAt(i);
      if (user?.username.toLowerCase() == username.toLowerCase()) {
        return false; // username duplicate
      }
    }
    await box.add(UserModel(
      username: username,
      password: password,
      name: name,
    ));
    return true;
  }

  // Validasi login user dari Hive
  static Future<UserModel?> validateLogin({
    required String username,
    required String password,
  }) async {
    final box = getUserBox();
    for (var i = 0; i < box.length; i++) {
      final user = box.getAt(i);
      if (user != null &&
          user.username == username &&
          user.password == password) {
        return user;
      }
    }
    return null;
  }

  // Set session login di SharedPreferences
  static Future<void> setLoginSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
    await prefs.setString(_userSessionKey, jsonEncode({
      'username': user.username,
      'name': user.name,
    }));
  }

  // Cek session login dari SharedPreferences
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // Ambil current user session
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userSessionKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Logout - clear SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    await prefs.remove(_userSessionKey);
  }

  // ==================== FAVORITES ====================
  static Future<List<WishlistModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_favKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List decoded = jsonDecode(jsonString);
      return decoded.map((e) => WishlistModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveFavorites(List<WishlistModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((e) => e.toMap()).toList();
    await prefs.setString(_favKey, jsonEncode(jsonList));
  }

  static Future<bool> addFavorite(WishlistModel wishlist) async {
    final list = await getFavorites();
    if (!list.any((w) => w.productId == wishlist.productId)) {
      list.add(wishlist);
      await saveFavorites(list);
      return true;
    }
    return false;
  }

  static Future<bool> removeFavorite(int id) async {
    final list = await getFavorites();
    final initialCount = list.length;
    list.removeWhere((w) => w.productId == id);
    if (list.length != initialCount) {
      await saveFavorites(list);
      return true;
    }
    return false;
  }

  static Future<bool> isFavorite(int id) async {
    final list = await getFavorites();
    return list.any((w) => w.productId == id);
  }
}
