import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warehouse/core/exceptions.dart';
import 'package:warehouse/models/login_response.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static const Duration _httpTimeout = Duration(seconds: 10);

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // ---------------- Helpers ----------------
  Future<Map<String, String>> _jsonHeaders({String? token}) async {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _safePost(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) =>
      http.post(url, headers: headers, body: body).timeout(_httpTimeout);

  Future<http.Response> _safeGet(
    Uri url, {
    Map<String, String>? headers,
  }) =>
      http.get(url, headers: headers).timeout(_httpTimeout);

  String? _extractBearerFromHeader(Map<String, String> headers) {
    final auth = headers['authorization'] ?? headers['Authorization'];
    if (auth == null) return null;
    final parts = auth.split(' ');
    if (parts.length == 2 && parts[0].toLowerCase() == 'bearer') {
      return parts[1];
    }
    return null;
  }

  String? _extractTokenFromBody(String body) {
    // يحاول يلتقط token إن كان موجودًا في النص
    final mJson = RegExp(r'"token"\s*:\s*"([^"]+)"').firstMatch(body);
    if (mJson != null) return mJson.group(1);
    final mLoose =
        RegExp(r'token\s*[:=]\s*([A-Za-z0-9\.\-\_]+)').firstMatch(body);
    return mLoose?.group(1);
  }

  // 1) إنشاء حساب سوبر أدمن مبسط
  Future<void> registerAdmin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/create_admin');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await _safePost(
        url,
        headers: await _jsonHeaders(),
        body: body,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // حاول قراءة JSON للرسالة، وإلا أعرض النص كما هو
        try {
          final responseBody = jsonDecode(response.body);
          throw AppException(responseBody['msg'] ?? 'فشل إنشاء المشرف');
        } catch (_) {
          throw AppException(
              'فشل إنشاء المشرف: ${response.statusCode} - ${response.body}');
        }
      }

      await _secureStorage.write(key: 'is_admin_created', value: 'true');
      await _secureStorage.write(key: 'is_logged_in', value: 'false');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال بالخادم (Timeout).');
    } catch (e) {
      throw AppException('خطأ في الاتصال بالسيرفر: $e');
    }
  }

  // 2) إنشاء حساب سوبر أدمن بكامل التفاصيل
  Future<void> registerAdminExtended({
    required String password,
    required String email,
    required String name,
    required String phoneNumber,
    required String salary,
    required String birthDay,
    required String country,
    required String startTime,
    required String workHours,
  }) async {
    final url = Uri.parse('$_baseUrl/start_application');
    // هذا الاندبوينت يقبل form-data/x-www-form-urlencoded
    final body = {
      'name': name,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'salary': salary,
      'birth_day': birthDay,
      'country': country,
      'start_time': startTime,
      'work_hours': workHours,
    };

    try {
      final response = await http
          .post(url, body: body)
          .timeout(_httpTimeout); // بدون JSON headers

      if (response.statusCode != 201 && response.statusCode != 200) {
        try {
          final error = jsonDecode(response.body);
          throw AppException(error['msg'] ?? 'فشل إنشاء السوبر أدمن');
        } catch (_) {
          throw AppException(
              'فشل إنشاء السوبر أدمن: ${response.statusCode} - ${response.body}');
        }
      }

      await _secureStorage.write(key: 'is_admin_created', value: 'true');
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال بالخادم (Timeout).');
    } catch (e) {
      throw AppException('فشل في إنشاء التطبيق: $e');
    }
  }

  // 3) تسجيل الدخول (يتعامل مع JSON أو نص عادي)
  Future<LoginResponse> login({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/login_employe');

    try {
      final response = await _safePost(
        url,
        headers: await _jsonHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
        }),
      );

      final ok = response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202;

      if (!ok) {
        try {
          final error = jsonDecode(response.body);
          final msg = error['msg']?.toString() ?? 'فشل تسجيل الدخول';
          throw AppException(msg);
        } catch (_) {
          throw AppException(
              'فشل تسجيل الدخول: ${response.statusCode} - ${response.body}');
        }
      }

      final contentType = response.headers['content-type'] ?? '';

      // الحالة 1: JSON طبيعي
      if (contentType.contains('application/json')) {
        final data = jsonDecode(response.body);
        return LoginResponse.fromJson(data);
      }

      // الحالة 2: نص عادي (مثل "Logged in successfully")
      // جرّب نستخرج التوكن من الهيدر أو النص
      String? token = _extractBearerFromHeader(response.headers);
      token ??= _extractTokenFromBody(response.body);

      if (token == null || token.isEmpty) {
        throw AppException(
          'الخادم أعاد نجاحًا بدون JSON وبلا توكن.\n'
          'رجاءً عدّل الـ API ليعيد JSON يحوي token أو يرسل Authorization: Bearer <token>.',
        );
      }

      // ابنِ JSON مصطنعًا ليقبله LoginResponse
      final fake = {'token': token, 'msg': response.body};
      return LoginResponse.fromJson(fake);
    } on TimeoutException {
      throw AppException('انتهت مهلة الاتصال بالخادم (Timeout).');
    } catch (e) {
      throw AppException('فشل الاتصال بالسيرفر: $e');
    }
  }

  // 4) حفظ بيانات الجلسة بشكل آمن
  Future<void> saveSession(
    LoginResponse response, {
    bool keepSignedIn = false, // يبقى مسجلاً بعد الريلود؟
  }) async {
    await _secureStorage.write(key: 'token', value: response.token);
    await _secureStorage.write(key: 'is_logged_in', value: 'true');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keep_signed_in', keepSignedIn);
  }

  // 5) تسجيل الخروج (استدعاء API + تنظيف محلي)
  Future<void> logout() async {
    try {
      final token = await _secureStorage.read(key: 'token');

      if (token != null && token.isNotEmpty) {
        final url = Uri.parse('$_baseUrl/logout_employe');
        await _safePost(
          url,
          headers: await _jsonHeaders(token: token),
          body: jsonEncode({}), // بعض السيرفرات ترفض body فارغ مع JSON
        ).catchError((_) {});
      }
    } finally {
      // نظّف الجلسة محليًا دائمًا
      await _secureStorage.delete(key: 'token');
      await _secureStorage.write(key: 'is_logged_in', value: 'false');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('keep_signed_in', false);
    }
  }

  // 6) التحقق من وجود جلسة صالحة (تستخدم في Splash)
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'token');
    final logged = await _secureStorage.read(key: 'is_logged_in');
    final prefs = await SharedPreferences.getInstance();
    final keep = prefs.getBool('keep_signed_in') ?? false;

    return (token != null && token.isNotEmpty) &&
        logged == 'true' &&
        keep == true;
  }
}
