import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/parent_storage_media.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';
import 'package:warehouse/models/warehouse.dart';

class SectionApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;
  // ✅ هيدر موحّد: يقرأ التوكن المخزّن (عدّل اسم المفتاح إذا لزم)
  static Future<Map<String, String>> _headers({bool withJson = false}) async {
    final storage = const FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    final headers = <String, String>{
      'Accept': 'application/json',
      if (withJson) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return headers;
  }

  static String? _msgFromBody(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map) {
        if (d['msg'] != null) return d['msg'].toString();
        if (d['message'] != null) return d['message'].toString(); // <-- جديد
        if (d['errors'] != null) return d['errors'].toString();
      }
    } catch (_) {}
    return null;
  }

  static String? _extractMsg(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map && d['msg'] != null) return d['msg'].toString();
    } catch (_) {}
    return null;
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
    final wid = (warehouse.id);
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
    return (response.statusCode == 200 || response.statusCode == 202);
  }

  static Future<bool> deleteSection(int sectionId) async {
    lastErrorMessage = null;

    final h = await _headers();
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    // 1) DELETE /api/delete_section/{id}
    final urlDelete =
        Uri.parse('http://127.0.0.1:8000/api/delete_section/$sectionId');
    try {
      final res = await http.get(urlDelete, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      debugPrint('[DELETE] $urlDelete -> ${res.statusCode}\nBody: ${res.body}');
      if (res.statusCode ~/ 100 == 2) return true;

      lastErrorMessage = _msgFromBody(res.body) ??
          'تعذّر حذف القسم (DELETE) — كود ${res.statusCode}';
      // بعض السيرفرات تعيد 400 "Error" لهذا النداء. نكمل بمحاولة أخرى.
    } catch (e) {
      lastErrorMessage = 'خطأ اتصال أثناء DELETE: $e';
    }

    return false;
  }

  static Future<List<WarehouseSection>> fetchSectionsByPlace(
      String placeType, int placeId) async {
    final url = Uri.parse('$_base/show_sections_on_place/$placeType/$placeId');

    if (kDebugMode) debugPrint('[SectionApi] GET $url');
    final res = await http.get(url, headers: await _headers());

    Map<String, dynamic>? json;
    try {
      json = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('[SectionApi] status: ${res.statusCode}');
      debugPrint('[SectionApi] body  : ${res.body}');
    }

    if (res.statusCode == 202) {
      final raw = (json?['sections'] as List?) ?? <dynamic>[];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(WarehouseSection.fromJson)
          .toList();
    }

    if (res.statusCode == 404) {
      final msg = (json?['msg']?.toString() ?? '').toLowerCase();
      // حالتان شائعتان من الباك: لا توجد أقسام، أو خطأ num_floors على null
      if (msg.contains('no sections') ||
          msg.contains('there are no sections') ||
          msg.contains('num_floors')) {
        return <WarehouseSection>[];
      }
    }

    throw Exception(json?['msg'] ?? 'Failed to load sections');
  }

// لو عندك fetchSectionsByWarehouse هنا، تأكد من قبول 200/202 (انظر القسم 3 أدناه)

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

  static Future<StorageElementsResult> fetchStorageElementsOnSection(
      int sectionId) async {
    final url = Uri.parse('$_base/show_storage_elements_on_section/$sectionId');
    final res = await http.get(url, headers: await _headers());
    debugPrint('[GET] $url -> ${res.statusCode}\n${res.body}');

    if (res.statusCode ~/ 100 == 2) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final parent = data['parent_storage_media'] as Map<String, dynamic>?;
      final list = (data['storage_elements'] as List?) ?? const [];

      return StorageElementsResult(
        parent: parent == null ? null : ParentStorageMedia.fromJson(parent),
        elements: list
            .map((e) => StorageElement.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .toList(),
      );
    }

    // 404 عند عدم وجود وسائط ⇒ نرجّع نتيجة فارغة بدون رمي استثناء
    if (res.statusCode == 404) {
      return StorageElementsResult(parent: null, elements: const []);
    }

    throw Exception(_msgFromBody(res.body) ?? 'Failed (${res.statusCode})');
  }

  static Future<List<Continer>> fetchContainersOnStorageElement(
      int storageElementId) async {
    final url =
        Uri.parse('$_base/show_continers_on_storage_element/$storageElementId');
    final res = await http.get(url, headers: await _headers());
    debugPrint('[GET] $url -> ${res.statusCode}\n${res.body}');

    if (res.statusCode ~/ 100 == 2) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (data['continers'] as List?) ?? const [];
      return list
          .map((e) => Continer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (res.statusCode == 404) {
      // لا يوجد حاويات
      return const <Continer>[];
    }

    throw Exception(_msgFromBody(res.body) ?? 'Failed (${res.statusCode})');
  }

  static Future<List<WarehouseSection>> fetchSectionsByDistributionCenter(
      int dcId) async {
    final url =
        Uri.parse('$_base/show_sections_on_place/DistributionCenter/$dcId');
    final res = await http.get(url, headers: await _headers());
    debugPrint('[GET] $url -> ${res.statusCode}\n${res.body}');

    if (res.statusCode ~/ 100 == 2) {
      final data = jsonDecode(res.body);
      final List list = (data['sections'] as List?) ?? const [];
      return list
          .map((e) => WarehouseSection.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();
    }

    throw Exception('Failed to load sections (${res.statusCode})');
  }
}
