// lib/services/suppliers_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/storage_media.dart';
import 'package:warehouse/models/supplier.dart';

class SuppliersApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  static void _log(String methodName, String message) {
    if (kDebugMode) {
      debugPrint(
          '===== [SuppliersApi - $methodName] =====\n$message\n===================================');
    }
  }

  // --- دالة موحدة لجلب الـ Headers (تم التصحيح هنا) ---
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

    _log('_getHeaders', 'Headers prepared with token: ${token != null}');
    return headers;
  }

  /// Fetches all suppliers.
  static Future<List<Supplier>> fetchSuppliers() async {
    const methodName = 'fetchSuppliers';
    final url = Uri.parse('$_baseUrl/show_suppliers');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final suppliers = (data['suppliers'] as List)
            .map((s) => Supplier.fromJson(s))
            .toList();
        _log(methodName, 'Success: Fetched ${suppliers.length} suppliers.');
        return suppliers;
      }
      lastErrorMessage = 'Failed to load suppliers. Status: ${res.statusCode}';
      return [];
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  /// Creates a new supplier.
  static Future<bool> createSupplier(Map<String, dynamic> payload) async {
    const methodName = 'createSupplier';
    final url = Uri.parse('$_baseUrl/create_new_supplier');
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 201) {
        _log(methodName, 'Success: Supplier created.');
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to create supplier.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  /// Deletes a supplier by their ID.
  static Future<bool> deleteSupplier(int supplierId) async {
    const methodName = 'deleteSupplier';
    final url = Uri.parse('$_baseUrl/delete_supplier/$supplierId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.delete(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        _log(methodName, 'Success: Supplier deleted.');
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to delete supplier.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  /// Fetches products for a specific supplier.

  static Future<bool> addSupplyToSupplier(Map<String, dynamic> payload) async {
    const methodName = 'addSupplyToSupplier';
    final url = Uri.parse('$_baseUrl/add_new_supplies_to_supplier');
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 201) {
        _log(methodName, 'Success: Supply added to supplier.');
        return true;
      }
      lastErrorMessage = jsonDecode(res.body)['msg'] ?? 'Failed to add supply.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  // --- دالة جديدة لجلب وسائط التخزين الخاصة بمورد معين ---
  // ملاحظة: ستحتاج إلى إضافة هذا الراوت في الباك إند
  static Future<List<StorageMedia>> fetchStorageMediaForSupplier(
      int supplierId) async {
    const methodName = 'fetchStorageMediaForSupplier';
    // نفترض أن هذا هو اسم الراوت، قد تحتاج لتعديله
    final url =
        Uri.parse('$_baseUrl/show_storage_media_of_supplier/$supplierId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        // تأكد من أن اسم المفتاح صحيح
        final media = (data['supplier_storage_media'] as List)
            .map((m) => StorageMedia.fromJson(m))
            .toList();
        return media;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load storage media for supplier: $e');
    }
  }

  static Future<List<Product>> fetchAllProducts() async {
    const methodName = 'fetchAllProducts';
    final url = Uri.parse('$_baseUrl/show_all_products');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = jsonDecode(res.body);
        // تأكد من أن اسم المفتاح صحيح (e.g., 'products' or 'data')
        final products =
            (data['products'] as List).map((p) => Product.fromJson(p)).toList();
        _log(methodName, 'Success: Fetched ${products.length} products.');
        return products;
      }
      lastErrorMessage = 'Failed to load products.';
      return [];
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  static Future<List<Product>> fetchProductsForSupplier(int supplierId) async {
    const methodName = 'fetchProductsForSupplier';
    final url = Uri.parse('$_baseUrl/show_products_of_supplier/$supplierId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final List list = (data['supplier_products'] as List?) ?? const [];
        return list.map((e) => Product.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      throw Exception('Failed to load products for supplier');
    }
  }
}
