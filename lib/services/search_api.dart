// search_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/search_filter.dart';
import 'package:warehouse/models/search_results.dart';

class SearchApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headersForm() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static final RegExp _asciiPattern = RegExp(r'^[a-zA-Z0-9 ]+$');

  static void _validateClient(String filter, String value) {
    final allowed = SearchFilter.defaults.map((e) => e.key).toSet();
    if (!allowed.contains(filter)) {
      throw Exception('فلتر غير مدعوم: $filter');
    }
    if (value.trim().isEmpty || !_asciiPattern.hasMatch(value)) {
      throw Exception(
          'حسب منطق الباك: البحث يقبل أحرف إنجليزية وأرقام ومسافة فقط (مثال: apple 123).');
    }
  }

  /// ينفّذ POST /api/search كـ form-urlencoded:
  /// filter=ModelName&value=Query
  static Future<SearchResultBundle> search({
    required String filter,
    required String value,
  }) async {
    const method = 'SearchApi.search';
    filter = filter.trim();
    value = value.trim();

    _validateClient(filter, value);

    final url = Uri.parse('$_base/search');
    final formBody = {
      'filter': filter,
      'value': value,
    };

    if (kDebugMode) {
      debugPrint('[$method] POST $url (form)');
      debugPrint('[$method] body: $formBody');
    }

    final res =
        await http.post(url, headers: await _headersForm(), body: formBody);

    Map<String, dynamic>? json;
    try {
      json = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('[$method] status: ${res.statusCode}');
      debugPrint('[$method] body  : ${res.body}');
    }

    if (res.statusCode == 202) {
      final filterName = (json?['filter']?.toString() ?? filter);
      final List raw = (json?['results'] as List?) ?? [];
      final items = raw
          .whereType<Map<String, dynamic>>()
          .map((m) => SearchItem(m))
          .toList();
      return SearchResultBundle(filter: filterName, items: items);
    }

    if (res.statusCode == 422) {
      final errors = json?['errors'];
      throw Exception('خطأ في التحقق: ${jsonEncode(errors)}');
    }

    // 400 عام: قد يأتي من طبقة وسطية؛ أظهر رسالة أوضح
    throw Exception(json?['msg'] ??
        json?['message'] ??
        'فشل تنفيذ البحث (${res.statusCode})');
  }
}
