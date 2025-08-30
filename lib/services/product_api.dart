// lib/services/product_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supported_product_request.dart';

class ProductApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  // دالة مساعدة لطباعة الرسائل بشكل منظم
  static void _log(String methodName, String message) {
    if (kDebugMode) {
      debugPrint(
          '===== [ProductApi - $methodName] =====\n$message\n===================================');
    }
  }

  // دالة موحدة لجلب الـ Headers مع طباعة للـ token
  static Future<Map<String, String>> _getHeaders() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    _log('_getHeaders', 'Headers prepared: $headers');
    return headers;
  }

  static Future<List<Product>> fetchProductsForPlace(
      String placeType, int placeId) async {
    const methodName = 'fetchProductsForPlace';
    // لا حاجة للتحويل هنا، سيتم إرسال النوع الصحيح من الواجهة مباشرة
    // Normalize the place type to match backend model names (e.g. "Warehouse" or "DistributionCenter").
    final normalizedPlaceType = _normalizePlaceType(placeType);
    final uri = Uri.parse(
        '$_baseUrl/show_products_of_place/$normalizedPlaceType/$placeId');
    _log(methodName, 'Calling API: $uri');

    try {
      final res = await http.get(uri, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final productsMap = data['products'] as Map<String, dynamic>? ?? {};
        // التحقق من أن القيمة هي خريطة، ثم أخذ قيمها كقائمة
        final productList =
            productsMap.values.map((p) => Product.fromJson(p)).toList();
        _log(methodName,
            'Success: Fetched ${productList.length} products for $placeType $placeId.');
        return productList;
      } else {
        lastErrorMessage =
            jsonDecode(res.body)['msg'] ?? 'Failed to load products for place.';
        _log(methodName, 'Error: $lastErrorMessage');
        // Throw an exception for non-202 status codes
        throw Exception(lastErrorMessage);
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  /// Normalizes a place type string into a canonical model class name expected by the backend.
  ///
  /// Example inputs and outputs:
  /// - "warehouse" -> "Warehouse"
  /// - "DistributionCenter" -> "DistributionCenter"
  /// - "distribution_center" -> "DistributionCenter"
  /// - "distribution center" -> "DistributionCenter"
  static String _normalizePlaceType(String type) {
    if (type.isEmpty) return type;
    // Replace underscores, hyphens and other non-letter chars with space
    final cleaned = type
        .replaceAll(RegExp(r'[^A-Za-z]+'), ' ')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .toList();
    // Capitalize each part and join
    final capitalized = cleaned
        .map((p) => p.isNotEmpty
            ? p[0].toUpperCase() + p.substring(1).toLowerCase()
            : p)
        .join();
    return capitalized;
  }

  static Future<bool> supportNewProduct(SupportedProductRequest req) async {
    const methodName = 'supportNewProduct';
    final uri = Uri.parse('$_baseUrl/support_new_product');

    final payload = Map<String, dynamic>.from(req.toJson());

    if (!payload.containsKey('type_id') && payload.containsKey('typeId')) {
      final raw = payload['typeId'];
      final asInt = int.tryParse(raw?.toString() ?? '');
      payload['type_id'] = asInt ?? raw;
    }

    _log(methodName, 'Calling API: $uri\nPayload: ${jsonEncode(payload)}');

    try {
      final res = await http.post(
        uri,
        headers: await _getHeaders(),
        body: jsonEncode(payload),
      );

      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _log(methodName, 'Success: New product supported.');
        return true;
      } else {
        lastErrorMessage =
            jsonDecode(res.body)['msg'] ?? 'Failed to support new product';
        _log(methodName, 'Error: $lastErrorMessage');
        return false;
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  static Future<List<Product>> fetchAllProducts() async {
    const methodName = 'fetchAllProducts';
    final uri = Uri.parse('$_baseUrl/show_products');
    _log(methodName, 'Calling API: $uri');
    try {
      final res = await http.get(uri, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final productsData = data['products'];
        if (productsData is List) {
          return productsData.map<Product>((p) => Product.fromJson(p)).toList();
        } else if (productsData is Map<String, dynamic>) {
          return productsData.values
              .map<Product>((p) => Product.fromJson(p))
              .toList();
        } else {
          return <Product>[];
        }
      } else {
        final body = jsonDecode(res.body);
        lastErrorMessage =
            body['msg'] ?? body['message'] ?? 'Failed to load products';
        throw Exception(lastErrorMessage);
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      throw Exception(lastErrorMessage);
    }
  }
}
