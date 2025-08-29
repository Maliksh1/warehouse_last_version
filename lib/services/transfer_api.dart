// lib/services/transfer_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/transfer_request.dart';

class TransferApi {
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

  /// POST /send_products_from_To
  /// يتعامل مع جميع الاستجابات المحتملة المذكورة في منطق الباك
  static Future<TransferResult> sendProducts(TransferRequest req) async {
    const method = 'sendProducts';
    final url = Uri.parse('$_base/send_products_from_To');
    try {
      final body = jsonEncode(req.toJson());
      if (kDebugMode) {
        debugPrint('===== [$method] -> POST $url');
        debugPrint(
            'Headers: ${(await _headers())..removeWhere((k, v) => k == "Authorization")}');
        debugPrint('Body: $body');
      }

      final res = await http.post(url, headers: await _headers(), body: body);

      if (kDebugMode) {
        debugPrint('[$method] Status: ${res.statusCode}');
        debugPrint('[$method] Body: ${res.body}');
      }

      Map<String, dynamic>? json;
      try {
        json = res.body.isNotEmpty
            ? jsonDecode(res.body) as Map<String, dynamic>
            : null;
      } catch (_) {}

      final msg = json?['msg']?.toString() ??
          json?['message']?.toString() ??
          'Unknown response';

      // نجاح متوقع من الباك 202
      if (res.statusCode == 202) {
        return TransferResult.success(msg, res.statusCode);
      }

      // أخطاء تحقق 422 (Validation failed)
      if (res.statusCode == 422) {
        final errors = json?['errors'] as Map<String, dynamic>?;
        return TransferResult.fail(res.statusCode, msg, errors);
      }

      // تضارب المساحة 409
      if (res.statusCode == 409) {
        return TransferResult.fail(res.statusCode, msg, null);
      }

      // بقية حالات 4xx/5xx مع رسالة msg
      return TransferResult.fail(res.statusCode, msg, null);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$method] Exception: $e');
      }
      return const TransferResult(
        ok: false,
        statusCode: 0,
        message: 'Network or unexpected error.',
      );
    }
  }
}
