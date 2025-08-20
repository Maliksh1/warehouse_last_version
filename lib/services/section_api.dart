import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';
import 'package:warehouse/models/warehouse.dart';

class SectionApi {
  static const String _base = 'http://127.0.0.1:8000/api';

  // ✅ هيدر موحّد: يقرأ التوكن المخزّن (عدّل اسم المفتاح إذا لزم)
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    // غيّر اسم المفتاح حسب ما تستخدمه فعليًا: 'token' / 'access_token' ...
    final token = prefs.getString('token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// ✅ النسخة الأساسية: تستقبل الـ payload فقط (بدون name/warehouseId كوسائط)
  static Future<bool> createSection(Map<String, dynamic> payload) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final url = Uri.parse('$_base/create_new_section');
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    if (kDebugMode) {
      debugPrint('[POST] $url');
      debugPrint('Headers: $headers');
      debugPrint('Payload: ${jsonEncode(payload)}');
    }

    final res =
        await http.post(url, headers: headers, body: jsonEncode(payload));

    if (kDebugMode) {
      debugPrint('Status: ${res.statusCode}');
      debugPrint('Body  : ${res.body}');
    }

    final ct = res.headers['content-type'] ?? '';
    Map<String, dynamic>? body;
    if (ct.contains('application/json')) {
      try {
        body = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {}
    }

    if (res.statusCode == 201) return true;

    // أعرض رسالة الباك للمستخدم
    final msg = body?['msg']?.toString() ??
        body?['message']?.toString() ??
        'Failed (${res.statusCode})';
    throw Exception(msg);
  }

  /// ✅ دالة راحة: تبني الـ payload تلقائيًا من كائن المستودع
  static Future<bool> createSectionForWarehouse({
    required Warehouse warehouse,
    required int productId,
    required int numFloors,
    required int numClasses,
    required int numPositionsOnClass,
    required String name,
  }) async {
    final wid = int.tryParse(warehouse.id);
    if (wid == null) {
      throw Exception('Warehouse id is invalid: ${warehouse.id}');
    }

    final payload = {
      "existable_type": "Warehouse",
      "existable_id": wid,
      "product_id": productId,
      "num_floors": numFloors,
      "num_classes": numClasses,
      "num_positions_on_class": numPositionsOnClass,
      "name": name,
    };

    return createSection(payload);
  }

  static Future<bool> editSection({
    required int sectionId,
    String? name,
    int? numFloors,
    int? numClasses,
    int? numPositionsOnClass,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/edit_section'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'section_id': sectionId,
        'name': name,
      }),
    );

    debugPrint("Edit section: ${response.statusCode}");
    return response.statusCode == 200;
  }

  Future<bool> deleteSection(int id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/delete_section/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("Delete section: ${response.statusCode}");
    return response.statusCode == 200;
  }

  Future<List<WarehouseSection>> fetchSectionsByWarehouse(
      int warehouseId) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final url = Uri.parse(
      'http://127.0.0.1:8000/api/show_sections_on_place/Warehouse/$warehouseId',
    );

    final res = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    debugPrint('Fetch sections status: ${res.statusCode}');
    debugPrint('Body: ${res.body}');

    // ✅ اعتبر أي 2xx نجاحًا
    if (res.statusCode ~/ 100 == 2) {
      final data = jsonDecode(res.body);
      final List list = (data['sections'] as List?) ?? const [];
      return list
          .map((e) => WarehouseSection.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    } else {
      // اطبع الخطأ ليسهّل التشخيص
      debugPrint('Fetch sections failed: ${res.statusCode} - ${res.body}');
      throw Exception('Failed to load sections (${res.statusCode})');
    }
  }
  // Future<List<WarehouseSection>> fetchSectionsByDistrbution(
  //     int warehouseId) async {
  //   final storage = const FlutterSecureStorage();
  //   final token = await storage.read(key: 'token');

  //   final url = Uri.parse(
  //     'http://127.0.0.1:8000/api/show_sections_on_place/DistributionCenter/$DistributionCenterid',
  //   );

  //   final res = await http.get(url, headers: {
  //     'Authorization': 'Bearer $token',
  //     'Accept': 'application/json',
  //   });

  //   debugPrint('Fetch sections status: ${res.statusCode}');
  //   debugPrint('Body: ${res.body}');

  //   // ✅ اعتبر أي 2xx نجاحًا
  //   if (res.statusCode ~/ 100 == 2) {
  //     final data = jsonDecode(res.body);
  //     final List list = (data['sections'] as List?) ?? const [];
  //     return list
  //         .map((e) => WarehouseSection.fromJson(
  //               Map<String, dynamic>.from(e as Map),
  //             ))
  //         .toList();
  //   } else {
  //     // اطبع الخطأ ليسهّل التشخيص
  //     debugPrint('Fetch sections failed: ${res.statusCode} - ${res.body}');
  //     throw Exception('Failed to load sections (${res.statusCode})');
  //   }
  // }
}
