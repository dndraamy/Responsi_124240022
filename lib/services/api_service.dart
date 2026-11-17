import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String apiUrl = 'https://dummyjson.com/products';

  // Mengambil seluruh produk dari API
  static Future<List<ProductModel>> getProducts() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'] ?? [];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Mengambil satu produk berdasarkan ID
  static Future<ProductModel> getSingleProduct(int productId) async {
    final response = await http.get(Uri.parse('$apiUrl/$productId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ProductModel.fromJson(data);
    } else {
      throw Exception('Failed to load product details');
    }
  }

  // Alias untuk getSingleProduct
  static Future<ProductModel> getProductDetail(int productId) =>
      getSingleProduct(productId);

  // Mengambil seluruh kategori produk dari API
  static Future<List<String>> getCategories() async {
    final response = await http.get(Uri.parse('$apiUrl/category-list'));
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Mengambil produk berdasarkan kategori
  static Future<List<ProductModel>> getProductsByCategory(
    String category,
  ) async {
    final response = await http.get(Uri.parse('$apiUrl/category/$category'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List products = data['products'] ?? [];
      return products.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load products for category $category');
    }
  }
}
