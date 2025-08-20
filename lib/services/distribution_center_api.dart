// lib/services/distribution_center_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/distribution_center.dart';

class DistributionCenterApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  static Future<Map<String, String>> _headers() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /show_distrebution_centers_of_warehouse/{wid}
  static Future<List<DistributionCenter>> fetchByWarehouse(int wid) async {
    final h = await _headers();
    final url = Uri.parse('$_base/show_distrebution_centers_of_warehouse/$wid');

    final res = await http.get(url, headers: h);
    if (kDebugMode) {
      debugPrint('[GET] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }

    if (res.statusCode ~/ 100 != 2) {
      lastErrorMessage = 'فشل الجلب (${res.statusCode})';
      throw Exception(lastErrorMessage);
    }

    final data = jsonDecode(res.body);
    // ✅ الحقل الفعلي من الباك:
    final raw = (data['distribuction_centers'] // الاسم المرسل من الباك
        ??
        data['distribution_centers'] // احتياط لأسماء أخرى
        ??
        data['centers'] ??
        data['data'] ??
        []) as List;

    return raw
        .map((e) => DistributionCenter.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  /// POST /create_new_distribution_center
  static Future<bool> create({
    required String name,
    required String location,
    required double latitude,
    required double longitude,
    required int warehouseId,
    required int numSections,
  }) async {
    final h = await _headers();
    final url = Uri.parse('$_base/create_new_distribution_center');
    final body = {
      "name": name,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "warehouse_id": warehouseId,
      "num_sections": numSections,
    };

    final res = await http.post(url, headers: h, body: jsonEncode(body));
    if (kDebugMode) {
      debugPrint('[POST] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }

    if (res.statusCode == 201) return true;
    try {
      final d = jsonDecode(res.body);
      lastErrorMessage = d['msg']?.toString() ?? d['message']?.toString();
    } catch (_) {}
    return false;
  }

  /// POST /edit_distribution_center
  static Future<bool> edit({
    required int id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    int? warehouseId,
    int? numSections,
  }) async {
    final h = await _headers();
    final url = Uri.parse('$_base/edit_distribution_center');
    final body = <String, dynamic>{
      "dis_center_id": id,
      if (name != null) "name": name,
      if (location != null) "location": location,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
      if (warehouseId != null) "warehouse_id": warehouseId,
      if (numSections != null) "num_sections": numSections,
    };

    final res = await http.post(url, headers: h, body: jsonEncode(body));
    if (kDebugMode) {
      debugPrint('[POST] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }
    if (res.statusCode ~/ 100 == 2) return true;

    try {
      final d = jsonDecode(res.body);
      lastErrorMessage = d['msg']?.toString() ?? d['message']?.toString();
    } catch (_) {}
    return false;
  }

  /// DELETE /delete_distribution_center/{id}
  static Future<bool> delete(int id) async {
    final h = await _headers();
    final url = Uri.parse('$_base/delete_distribution_center/$id');

    final res = await http.get(url, headers: h); // ✅ GET بدلاً من DELETE

    if (kDebugMode) {
      debugPrint('[GET] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }

    // اعتبر أي 2xx نجاحًا (بما فيها 202 من الباك)
    if (res.statusCode ~/ 100 == 2) return true;

    // حفظ رسالة سبب الفشل (إن وُجدت)
    try {
      final d = jsonDecode(res.body);
      if (d is Map) {
        final msg = d['msg']?.toString() ?? d['message']?.toString();
        final hasSections = d['has_sections'] == true;
        final hasEmployees =
            d['has_employes'] == true || d['has_employees'] == true;
        lastErrorMessage = msg ??
            'فشل الحذف (${res.statusCode})' +
                (hasSections || hasEmployees ? ' — مرتبط بأقسام/موظفين' : '');
      }
    } catch (_) {
      lastErrorMessage = 'فشل الحذف (${res.statusCode})';
    }

    return false;
  }
}
