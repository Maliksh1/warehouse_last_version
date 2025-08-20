import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/warehouse.dart';

class WarehouseApi {
  static const String _base = 'http://127.0.0.1:8000/api';

  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ---------- جلب كل المستودعات ----------
  static Future<List<Warehouse>> fetchAllWarehouses() async {
    final url = Uri.parse('$_base/show_all_warehouses');
    final res = await http.get(url, headers: await _headers());

    debugPrint('[GET] $url  => ${res.statusCode}');
    debugPrint('CT: ${res.headers['content-type']}');
    if (res.statusCode == 401) {
      throw Exception('Unauthorized');
    }
    if (!(res.statusCode == 200 ||
        res.statusCode == 201 ||
        res.statusCode == 202)) {
      throw Exception(
          'Failed to load warehouses (${res.statusCode}) - ${res.body}');
    }

    try {
      String body = res.body.trim();

      // قصّ أي ضجيج نصي قبل JSON (مثل "i am herer")
      final start = body.indexOf(RegExp(r'[\{\[]')); // أول { أو [
      if (start > 0) body = body.substring(start);
      // قصّ أي ضجيج بعد JSON (لو وجد)
      final lastBrace = body.lastIndexOf('}');
      final lastBracket = body.lastIndexOf(']');
      final end = (lastBrace > lastBracket) ? lastBrace : lastBracket;
      if (end != -1 && end + 1 < body.length) body = body.substring(0, end + 1);

      final decoded = jsonDecode(body);

      List<dynamic> listDyn = const [];
      if (decoded is List) {
        listDyn = decoded;
      } else if (decoded is Map) {
        final m = Map<String, dynamic>.from(decoded);
        if (m['warehouses'] is List) {
          listDyn = List<dynamic>.from(m['warehouses']);
        } else if (m['data'] is List) {
          listDyn = List<dynamic>.from(m['data']);
        } else if (m['items'] is List) {
          listDyn = List<dynamic>.from(m['items']);
        } else {
          listDyn = const [];
        }
      }

      return listDyn
          .whereType<Map>()
          .map((e) => Warehouse.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('Warehouse parse error: $e');
      throw Exception('Bad warehouses JSON: $e');
    }
  }

  // ---------- إضافة مستودع ----------

static Future<bool> createWarehouse(Map<String, dynamic> payload) async {
  // غيّر المسار لو مختلف في باكك
  final url = Uri.parse('$_base/create_new_warehouse');

  final headers = {
    ...await _headers(), // لازم يحتوي التوكنات المطلوبة
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  debugPrint('[POST] $url');
  debugPrint('Headers: ${headers.map((k, v) => MapEntry(k, k.toLowerCase().contains("auth") ? "***" : v))}');
  debugPrint('Payload: ${jsonEncode(payload)}');

  final res = await http.post(url, headers: headers, body: jsonEncode(payload));

  debugPrint('Status: ${res.statusCode}');
  debugPrint('CT    : ${res.headers['content-type']}');
  debugPrint('Body  : ${res.body}');

  if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 202) {
    return true;
  }

  // حاول استخراج رسالة مفيدة
  try {
    final d = jsonDecode(res.body);
    final msg = (d['msg'] ?? d['message'] ?? d['error'] ?? d.toString()).toString();
    throw Exception('فشل إنشاء المستودع: ${res.statusCode} - $msg');
  } catch (_) {
    throw Exception('فشل إنشاء المستودع: ${res.statusCode} - ${res.body}');
  }
}


  // ---------- تعديل مستودع ----------
  // يرسل warehouse_id + أي حقل تريد تعديله
  static Future<bool> editWarehouse({
    required int warehouseId,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    int? typeId,
    int? numSections,
  }) async {
    final payload = <String, dynamic>{
      'warehouse_id': warehouseId,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (typeId != null) 'type_id': typeId,
      if (numSections != null) 'num_sections': numSections,
    };

    final res = await http.post(
      Uri.parse('$_base/edit_warehouse'),
      headers: await _headers(),
      body: jsonEncode(payload),
    );

    debugPrint("Edit warehouse status: ${res.statusCode}");
    debugPrint("Edit body: ${res.body}");

    return res.statusCode == 200 || res.statusCode == 202;
  }

  // ---------- حذف مستودع ----------
  static Future<bool> deleteWarehouse(int id) async {
    try {
      final res = await http.get(
        Uri.parse('$_base/delete_warehouse/$id'),
        headers: await _headers(),
      );

      debugPrint("Delete warehouse status: ${res.statusCode}");
      debugPrint("Delete body: ${res.body}");

      return res.statusCode == 200 || res.statusCode == 202;
    } catch (e) {
      debugPrint("Exception in deleteWarehouse: $e");
      return false;
    }
  }
}
