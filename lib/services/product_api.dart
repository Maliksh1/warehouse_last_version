import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/product.dart';

class ProductApi {
  static const String baseUrl = 'https://api.example.com/products';

  static Future<List<Product>> fetchAllProducts() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('فشل في تحميل المنتجات');
    }
  }

  static Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      body: jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      throw Exception('فشل في إضافة المنتج');
    }
  }

  static Future<void> updateProduct(Product product) async {
    final url = '$baseUrl/${product.id}';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(product.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('فشل في تحديث المنتج');
    }
  }

  static Future<void> deleteProduct(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('فشل في حذف المنتج');
    }
  }
}
