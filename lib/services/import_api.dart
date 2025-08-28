import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/models/pending_product_import.dart';
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

        // ✅ ---  المنطق الجديد والأكثر قوة ---

        // الحالة 1: الخادم يرسل قائمة (مثل ["no operation"])
        if (data is List) {
          _log(methodName, 'Response is a List. Assuming no operations.');
          return [];
        }

        // الحالة 2: الخادم يرسل كائنًا (Map)
        if (data is Map<String, dynamic>) {
          final operationsData = data['import_operations'];

          if (operationsData == null) {
            _log(methodName, 'Success: "import_operations" key not found.');
            return [];
          }

          if (operationsData is Map) {
            // التحويل الصريح إلى Map<String, dynamic>
            final castedOperationsData =
                Map<String, dynamic>.from(operationsData);
            final operations = castedOperationsData.values
                .map((opJson) => PendingImportOperation.fromJson(
                    opJson as Map<String, dynamic>))
                .toList();
            _log(methodName,
                'Success: Parsed ${operations.length} operations from MAP structure.');
            return operations;
          }
        }

        _log(methodName,
            'Warning: Response format is unexpected. Returning empty list.');
        return [];
      }

      return [];
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      throw Exception('Failed to load pending import operations: $e');
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

  /// Fetch warehouses that support a specific storage media.
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

      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final warehousesMap = data['warehouses'] as Map<String, dynamic>? ?? {};
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
        final List list = (data['sections'] as List?) ?? const [];
        final sections = list
            .map((e) =>
                WarehouseSection.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _log(methodName, 'Success: Fetched ${sections.length} sections.');
        return sections;
      }

      if (res.statusCode == 404) {
        _log(methodName,
            'Success: No sections found (404), returning empty list.');
        return [];
      }

      throw Exception('Failed with status code: ${res.statusCode}');
    } catch (e) {
      final errorMsg = 'Failed to load sections for $placeType/$placeId: $e';
      _log(methodName, 'EXCEPTION: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Fetch distribution centers in a warehouse for a specific storage media.
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
        final List centersList =
            (data['distribution_centers'] as List?) ?? const [];
        final centers =
            centersList.map((dc) => DistributionCenter.fromJson(dc)).toList();
        _log(methodName,
            'Success: Fetched ${centers.length} distribution centers.');
        return centers;
      }

      if (res.statusCode == 404) {
        _log(methodName,
            'Success: No distribution centers found (404), returning empty list.');
        return [];
      }

      throw Exception('Failed with status code: ${res.statusCode}');
    } catch (e) {
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
    final url = Uri.parse('$_baseUrl/create_new_imporet_op_storage_media');

    // تأكد من أن section_id هو رقم صحيح
    final correctedItems = items.map((item) {
      return {
        "storage_media_id": storageMedia.id,
        "quantity": item['quantity'],
        "section_id": int.tryParse(item['section_id'].toString()) ?? 0,
      };
    }).toList();

    final payload = {
      "supplier_id": supplier.id,
      "location": warehouse.location,
      "latitude": warehouse.latitude,
      "longitude": warehouse.longitude,
      "storage_media": correctedItems,
    };

    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 201 || res.statusCode == 200) {
        _log(methodName, 'Success: Pending import operation created.');
        return true;
      }
      // Capture error message more reliably
      try {
        lastErrorMessage = jsonDecode(res.body)['message'] ??
            jsonDecode(res.body)['msg'] ??
            'Failed to create operation.';
      } catch (_) {
        lastErrorMessage = 'An unknown error occurred.';
      }
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  static Future<List<Warehouse>> fetchWarehousesForProduct(
      int productId) async {
    const methodName = 'fetchWarehousesForProduct';
    final url = Uri.parse('$_baseUrl/show_warehouses_of_product/$productId');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        // الخادم يرسل كائنًا وليس قائمة، لذا يجب تحويله
        final warehousesMap = data['warehouses'] as Map<String, dynamic>? ?? {};
        return warehousesMap.values.map((e) => Warehouse.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      throw Exception('Failed to load warehouses for product');
    }
  }

  static Future<bool> createPendingProductImport({
    required Supplier supplier,
    required List<ImportedProductInfo> products,
  }) async {
    const methodName = 'createPendingProductImport';
    final url = Uri.parse('$_baseUrl/create_new_import_operation_product');

    final payload = {
      "supplier_id": supplier.id,
      "location": supplier.country, // أو أي موقع مناسب
      "latitude": 20.0, // قيمة افتراضية أو من المورد
      "longitude": -22.0, // قيمة افتراضية أو من المورد
      "products": products.map((p) => p.toJson()).toList(),
    };

    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 201) {
        return true;
      }
      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to create operation.';
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred: $e';
      _log(methodName, 'EXCEPTION: $e');
      return false;
    }
  }

  static Future<List<PendingProductImport>> fetchPendingProductImports() async {
    const methodName = 'fetchPendingProductImports';
    final url = Uri.parse('$_baseUrl/show_latest_import_op_products');
    _log(methodName, 'Calling API: $url');
    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data is List) {
          _log(methodName, 'Response is a List, assuming no operations.');
          return [];
        }
        if (data is Map<String, dynamic>) {
          final operationsData = data['import_operations'];
          if (operationsData is Map) {
            final castedData = Map<String, dynamic>.from(operationsData);
            return castedData.values
                .map((opJson) => PendingProductImport.fromJson(
                    opJson as Map<String, dynamic>))
                .toList();
          }
        }
      }
      return [];
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      throw Exception('Failed to load pending product imports: $e');
    }
  }

  static Future<bool> acceptProductImport({
    required String importKey,
    required String productsKey,
  }) async {
    const methodName = 'acceptProductImport';
    final url = Uri.parse('$_baseUrl/accept_import_op_products');
    final payload = {
      "import_operation_key": importKey,
      "products_key": productsKey,
    };
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName, 'Response Status: ${res.statusCode}');
      return res.statusCode == 202;
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      return false;
    }
  }

  // ملاحظة: الباك إند يستخدم نفس الدالة للرفض
  static Future<bool> rejectProductImport({
    required String importKey,
    required String productsKey,
  }) async {
    const methodName = 'rejectProductImport';
    final url = Uri.parse('$_baseUrl/reject_import_op');
    final payload = {
      "import_operation_key": importKey,
      "key": productsKey, // الباك إند يتوقع "key" هنا
    };
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');
    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName, 'Response Status: ${res.statusCode}');
      return res.statusCode == 202;
    } catch (e) {
      _log(methodName, 'EXCEPTION: $e');
      return false;
    }
  }
}
