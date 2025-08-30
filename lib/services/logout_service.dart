// lib/services/logout_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LogoutResult {
  final bool ok;
  final int statusCode;
  final String message;
  const LogoutResult(
      {required this.ok, required this.statusCode, required this.message});
}

class LogoutService {
  // عدّل المسار إذا كان مختلفاً لديك (مثلاً /api/logout أو /api/logout_user)
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static const String _logoutPath = '/logout_user';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// ينفّذ تسجيل الخروج على السيرفر (JWT invalidate) ثم ينظّف التوكن محلياً.
  /// يعيد رسالة السيرفر، ويتعامل باحترام مع الحالات:
  /// 202 نجاح، 400 "No Token Found"، 500 خطأ عام.
  static Future<LogoutResult> logout() async {
    const method = 'LogoutService.logout';
    final url = Uri.parse('$_baseUrl$_logoutPath');

    try {
      if (kDebugMode) debugPrint('[$method] POST $url');

      final res = await http.post(url, headers: await _headers());

      if (kDebugMode) {
        debugPrint('[$method] status: ${res.statusCode}');
        debugPrint('[$method] body  : ${res.body}');
      }

      Map<String, dynamic>? body;
      try {
        body = res.body.isNotEmpty
            ? jsonDecode(res.body) as Map<String, dynamic>
            : null;
      } catch (_) {}

      final msg =
          (body?['msg']?.toString() ?? body?['message']?.toString() ?? '')
              .trim();

      // نجاح السيرفر
      if (res.statusCode == 202) {
        await _clearLocalSession();
        return LogoutResult(
            ok: true,
            statusCode: 202,
            message: msg.isEmpty ? 'تم تسجيل الخروج بنجاح' : msg);
      }

      // لا يوجد توكن على السيرفر — نعتبرها شبه نجاح (سنمسح محليًا أيضًا)
      if (res.statusCode == 400 && msg.contains('No Token Found')) {
        await _clearLocalSession();
        return LogoutResult(
            ok: true,
            statusCode: 400,
            message: 'تم إنهاء الجلسة محليًا (لا يوجد توكن على السيرفر)');
      }

      // أخطاء أخرى
      return LogoutResult(
          ok: false,
          statusCode: res.statusCode,
          message: msg.isEmpty ? 'فشل تسجيل الخروج' : msg);
    } catch (e) {
      if (kDebugMode) debugPrint('[$method] exception: $e');
      // حتى مع الاستثناءات، ننظّف محليًا لحماية المستخدم
      await _clearLocalSession();
      return const LogoutResult(
          ok: false,
          statusCode: 0,
          message: 'تعذّر الاتصال بالخادم. تم مسح الجلسة محليًا.');
    }
  }

  static Future<void> _clearLocalSession() async {
    try {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'employee'); // إن كنت تخزن بيانات الموظف
      // لا تستخدم deleteAll إن كنت تحفظ أشياء أخرى مهمة للمستخدم
    } catch (e) {
      if (kDebugMode) debugPrint('[LogoutService] clearLocalSession error: $e');
    }
  }
}
