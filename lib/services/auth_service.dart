import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warehouse/core/exceptions.dart';
import 'package:warehouse/models/login_response.dart';

final authServiceProvider = Provider((ref) => AuthService());

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// 1. إنشاء حساب سوبر أدمن مبسط
  Future<void> registerAdmin({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/create_admin');
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        throw AppException(responseBody['msg'] ?? 'فشل إنشاء المشرف');
      }

      await _secureStorage.write(key: 'is_admin_created', value: 'true');
      await _secureStorage.write(key: 'is_logged_in', value: 'false');
    } catch (e) {
      throw AppException('خطأ في الاتصال بالسيرفر: $e');
    }
  }

  /// 2. إنشاء حساب سوبر أدمن بكامل التفاصيل
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

    print('📤 إرسال البيانات إلى السيرفر: $body');

    try {
      final response = await http.post(
        url,
        body: body,
      );

      print('📥 الرد من السيرفر: ${response.body}');

      if (response.statusCode != 201 && response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw AppException(error['msg'] ?? 'فشل إنشاء السوبر أدمن');
      }

      await _secureStorage.write(key: 'is_admin_created', value: 'true');
    } catch (e) {
      throw AppException('فشل في إنشاء التطبيق: $e');
    }
  }

  /// 3. تسجيل الدخول
  Future<LoginResponse> login({
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final url = Uri.parse('$_baseUrl/login_employe');

    try {
      print('🚀 إرسال تسجيل الدخول:');
      print('Email: $email');
      print('Password: $password');
      print('Phone: $phoneNumber');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
        }),
      );

      print('📥 الرد من السيرفر: ${response.statusCode}');
      print('📥 البيانات: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return LoginResponse.fromJson(json);
      } else {
        final error = jsonDecode(response.body);
        final msg = error['msg'] ?? 'فشل تسجيل الدخول';
        throw AppException(msg);
      }
    } catch (e) {
      throw AppException('فشل الاتصال بالسيرفر: $e');
    }
  }

  /// 4. حفظ بيانات الجلسة بشكل آمن
  Future<void> saveSession(LoginResponse response) async {
    await _secureStorage.write(key: 'token', value: response.token);
    await _secureStorage.write(key: 'is_logged_in', value: 'true');

    /// 5. تسجيل الخروج
    Future<void> logout() async {
      await _secureStorage.deleteAll(); // آمن وسهل
    }

    /// 6. التحقق من وجود جلسة
    Future<bool> isLoggedIn() async {
      final value = await _secureStorage.read(key: 'is_logged_in');
      return value == 'true';
    }
  }
}
