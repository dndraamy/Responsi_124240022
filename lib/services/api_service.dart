import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static Future<List<ProductModel>> getProducts() async {
    final res = await http.get(Uri.parse('https://dummyjson.com/products'));

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return (data['products'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Gagal memuat produk');
    }
  }
}