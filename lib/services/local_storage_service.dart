import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

class LocalStorageService {
  static const String _userBoxName = 'users_box';
  static const String _wishlistBoxName = 'wishlist_box';
  static const String _cartBoxName = 'cart_box';
  static const String _keyLogin = 'loginData';
  static const String _keyUsername = 'username';
  static const String _keyName = 'name';

  // ==================== AUTENTIKASI ====================
  static Box<UserModel> getUserBox() {
    return Hive.box<UserModel>(_userBoxName);
  }

  static Future<bool> registerUser({
    required String username,
    required String password,
    required String name,
  }) async {
    final box = getUserBox();
    for (var i = 0; i < box.length; i++) {
      final user = box.getAt(i);
      if (user != null &&
          user.username.toLowerCase() == username.toLowerCase()) {
        return false;
      }
    }
    await box.add(
      UserModel(username: username, password: password, name: name),
    );
    return true;
  }

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

  // ==================== SESSION ====================
  static Future<void> setLoginSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, true);
    await prefs.setString(_keyUsername, user.username);
    await prefs.setString(_keyName, user.name);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLogin) ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername) ?? '';
  }

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_keyName);
    if (name != null && name.isNotEmpty) return name;
    return prefs.getString(_keyUsername) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLogin, false);
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyName);
  }

  // ==================== WISHLIST ====================
  static Box getWishlistBox() {
    return Hive.box(_wishlistBoxName);
  }

  static List<ProductModel> getWishlist() {
    final box = getWishlistBox();
    final List<ProductModel> list = [];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          list.add(
            ProductModel.fromJson(Map<String, dynamic>.from(data as Map)),
          );
        } catch (_) {}
      }
    }
    return list;
  }

  static Future<void> addWishlist(ProductModel product) async {
    final box = getWishlistBox();
    await box.put(product.id.toString(), product.toJson());
  }

  static Future<void> removeWishlist(int productId) async {
    final box = getWishlistBox();
    await box.delete(productId.toString());
  }

  static bool isWishlist(int productId) {
    final box = getWishlistBox();
    return box.containsKey(productId.toString());
  }

  // ==================== KERANJANG BELANJA ====================
  static Box getCartBox() {
    return Hive.box(_cartBoxName);
  }

  static List<CartItemModel> getCartItems() {
    final box = getCartBox();
    final List<CartItemModel> items = [];
    for (final key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        try {
          items.add(
            CartItemModel.fromJson(Map<String, dynamic>.from(data as Map)),
          );
        } catch (_) {}
      }
    }
    return items;
  }

  static Future<void> addToCart(ProductModel product, int qty) async {
    final box = getCartBox();
    final key = product.id.toString();

    if (box.containsKey(key)) {
      final existing = CartItemModel.fromJson(
        Map<String, dynamic>.from(box.get(key) as Map),
      );
      final newQty = (existing.quantity + qty).clamp(1, product.stock);
      existing.quantity = newQty;
      await box.put(key, existing.toJson());
    } else {
      final newItem = CartItemModel(
        productId: product.id,
        title: product.title,
        price: product.price,
        thumbnail: product.thumbnail.isNotEmpty
            ? product.thumbnail
            : (product.images.isNotEmpty ? product.images[0] : ''),
        quantity: qty.clamp(1, product.stock > 0 ? product.stock : 1),
        stock: product.stock,
      );
      await box.put(key, newItem.toJson());
    }
  }

  static Future<void> updateCartQuantity(int productId, int qty) async {
    final box = getCartBox();
    final key = productId.toString();
    if (!box.containsKey(key)) return;

    if (qty <= 0) {
      await box.delete(key);
    } else {
      final item = CartItemModel.fromJson(
        Map<String, dynamic>.from(box.get(key) as Map),
      );
      item.quantity = qty.clamp(1, item.stock);
      await box.put(key, item.toJson());
    }
  }

  static Future<void> removeFromCart(int productId) async {
    final box = getCartBox();
    await box.delete(productId.toString());
  }

  static double getCartTotal() {
    final items = getCartItems();
    double total = 0.0;
    for (final item in items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  static int getCartCount() {
    final box = getCartBox();
    return box.length;
  }
}
