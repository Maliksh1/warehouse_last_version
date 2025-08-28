// lib/services/import_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/models/storage_media.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';

class ImportApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  static void _log(String methodName, String message) {
    if (kDebugMode) {
      debugPrint(
          '===== [ImportApi - $methodName] =====\n$message\n===================================');
    }
  }

  // --- دالة موحدة لجلب الـ Headers بالطريقة الصحيحة ---
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

  /// Fetches latest pending import operations from cache.
  static Future<List<PendingImportOperation>>
      fetchPendingImportOperations() async {
    const methodName = 'fetchPendingImportOperations';
    final url = Uri.parse('$_baseUrl/show_latest_import_op_storage_media');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final operationsMap =
            data['import_operations'] as Map<String, dynamic>? ?? {};
        final operations = operationsMap.values
            .map((opJson) => PendingImportOperation.fromJson(opJson))
            .toList();
        _log(methodName,
            'Success: Fetched ${operations.length} pending operations.');
        return operations;
      }
      lastErrorMessage = 'Failed to load pending operations.';
      return [];
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  /// Accepts a pending import operation.
  static Future<bool> acceptImportOperation({
    required String importKey,
    required String storageKey,
  }) async {
    const methodName = 'acceptImportOperation';
    final url = Uri.parse('$_baseUrl/accept_import_op_storage_media');
    final payload = {
      'import_operation_key': importKey,
      'storage_media_key': storageKey,
    };
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        _log(methodName, 'Success: Operation accepted.');
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to accept operation.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  /// Rejects a pending import operation.
  static Future<bool> rejectImportOperation({
    required String importKey,
    required String storageKey,
  }) async {
    const methodName = 'rejectImportOperation';
    final url = Uri.parse('$_baseUrl/reject_import_op');
    final payload = {
      'import_operation_key': importKey,
      'key': storageKey,
    };
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        _log(methodName, 'Success: Operation rejected.');
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to reject operation.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  static Future<List<StorageMedia>> fetchStorageMedia() async {
    const methodName = 'fetchStorageMedia';
    final url = Uri.parse('$_baseUrl/show_storage_media');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final media = (data['storage_media'] as List)
            .map((m) => StorageMedia.fromJson(m))
            .toList();
        return media;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load storage media: $e');
    }
  }

  static Future<List<Supplier>> fetchSuppliersForMedia(
      int storageMediaId) async {
    const methodName = 'fetchSuppliersForMedia';
    final url =
        Uri.parse('$_baseUrl/show_supplier_of_storage_media/$storageMediaId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final suppliers = (data['suppliers'] as List)
            .map((s) => Supplier.fromJson(s))
            .toList();
        return suppliers;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load suppliers for media: $e');
    }
  }

  /// Step 3: Fetch warehouses that support a specific storage media.
  static Future<List<Warehouse>> fetchWarehousesForMedia(
      int storageMediaId) async {
    const methodName = 'fetchWarehousesForMedia';
    final url =
        Uri.parse('$_baseUrl/show_warehouse_of_storage_media/$storageMediaId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      // --- هنا تم التصحيح ---
      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = jsonDecode(res.body);
        // 1. قراءة البيانات ككائن (Map)
        final warehousesMap = data['warehouses'] as Map<String, dynamic>? ?? {};
        // 2. تحويل قيم الكائن إلى قائمة
        final warehouses =
            warehousesMap.values.map((w) => Warehouse.fromJson(w)).toList();
        return warehouses;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load warehouses for media: $e');
    }
  }

  static Future<List<WarehouseSection>> fetchSectionsForPlace(
      int storageMediaId, String placeType, int placeId) async {
    const methodName = 'fetchSectionsForPlace';
    final url = Uri.parse(
        '$_baseUrl/show_sections_of_storage_media_on_place/$storageMediaId/$placeType/$placeId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final sections = (data['sections'] as List)
            .map((s) => WarehouseSection.fromJson(s))
            .toList();
        return sections;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load sections: $e');
    }
  }

  /// Step 4b: Fetch distribution centers in a warehouse for a specific storage media.
  static Future<List<DistributionCenter>> fetchDistributionCentersForWarehouse(
      int warehouseId, int storageMediaId) async {
    const methodName = 'fetchDistributionCentersForWarehouse';
    final url = Uri.parse(
        '$_baseUrl/show_distribution_centers_of_storage_media_in_warehouse/$warehouseId/$storageMediaId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);

        // --- هنا تم التصحيح ---
        // 1. قراءة البيانات ككائن (Map)
        final centersMap =
            data['distribution_centers'] as Map<String, dynamic>? ?? {};
        // 2. تحويل قيم الكائن إلى قائمة
        final centers = centersMap.values
            .map((dc) => DistributionCenter.fromJson(dc))
            .toList();
        _log(methodName,
            'Success: Fetched ${centers.length} distribution centers.');
        return centers;
      }
      return [];
    } catch (e) {
      // --- تمت إضافة طباعة مفصلة للخطأ هنا ---
      final errorMsg = 'Failed to load distribution centers: $e';
      _log(methodName, 'EXCEPTION: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  static Future<bool> createPendingImportOperation({
    required Supplier supplier,
    required Warehouse warehouse,
    required StorageMedia storageMedia,
    required List<Map<String, dynamic>> items,
  }) async {
    const methodName = 'createPendingImportOperation';
    // نفترض أن هذا هو اسم الراوت بناءً على منطق الباك إند
    final url = Uri.parse('$_baseUrl/create_import_op_storage_media');

    // تجميع الحمولة النهائية
    final payload = {
      "supplier_id": supplier.id,
      "location": warehouse.location,
      "latitude": warehouse.latitude,
      "longitude": warehouse.longitude,
      "storage_media": items
          .map((item) => {
                "storage_media_id": storageMedia.id,
                "quantity": item['quantity'],
                "section_id": item['section_id'],
              })
          .toList(),
    };

    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      // عادةً ما يكون الإنشاء الناجح 201
      if (res.statusCode == 201 || res.statusCode == 200) {
        _log(methodName, 'Success: Pending import operation created.');
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to create pending operation.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }
}
