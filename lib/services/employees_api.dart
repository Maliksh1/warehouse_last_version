import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/employee.dart';

class EmployeesApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  static Future<Map<String, String>> _headers({bool withJson = false}) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    final h = <String, String>{
      'Accept': 'application/json',
      if (withJson) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if (kDebugMode)
      debugPrint(
          '[EmployeesApi.headers] hasToken=${h.containsKey('Authorization')}');
    return h;
  }

  static String? _msg(String body) {
    try {
      final d = jsonDecode(body);
      if (d is Map) return (d['msg'] ?? d['message'])?.toString();
    } catch (_) {}
    return null;
  }

  /// **[NEW]** GET /show_all_employees
  /// Fetches all employees from all specializations and flattens the list.
  static Future<List<Employee>> fetchAllEmployees() async {
    final url = Uri.parse('$_base/show_all_employees');
    final res = await http.get(url, headers: await _headers());

    if (kDebugMode) {
      debugPrint('[GET] $url -> ${res.statusCode}');
    }

    if (res.statusCode == 202) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final specializations = (data['employees'] as List?) ?? [];
      final List<Employee> allEmployees = [];

      // Loop through each specialization and extract its employees
      for (var spec in specializations) {
        if (spec is Map && spec['employees'] is List) {
          for (var empJson in spec['employees']) {
            allEmployees.add(
                Employee.fromJson(Map<String, dynamic>.from(empJson as Map)));
          }
        }
      }
      return allEmployees;
    }

    lastErrorMessage =
        _msg(res.body) ?? 'Failed to fetch all employees (${res.statusCode})';
    throw Exception(lastErrorMessage);
  }

  /// GET /show_employees_on_place/{placeType}/{placeId}
  static Future<List<Employee>> fetchOnPlace({
    required String placeType,
    required int placeId,
  }) async {
    final url = Uri.parse('$_base/show_employees_on_place/$placeType/$placeId');
    final res = await http.get(url, headers: await _headers());
    if (kDebugMode) {
      debugPrint('[GET] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }

    if (res.statusCode ~/ 100 == 2) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (data['employees'] as List?) ?? const [];
      return list
          .map((e) => Employee.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    if (res.statusCode == 404) return const <Employee>[];
    lastErrorMessage = _msg(res.body) ?? 'Failed (${res.statusCode})';
    throw Exception(lastErrorMessage);
  }

  /// POST /create_new_employe (Multipart بسبب الصورة)
  static Future<bool> create({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    required int specializationId,
    required String salary,
    String? birthDay, // YYYY-MM-DD
    required String country,
    required String startTime, // "09:00:00"
    required String workHours, // "8"
    required String workableType, // "Warehouse" or "DistributionCenter"
    required int workableId,
    String? imagePath,
  }) async {
    final url = Uri.parse('$_base/create_new_employe');
    final h = await _headers();
    final req = http.MultipartRequest('POST', url)..headers.addAll(h);

    req.fields.addAll({
      'name': name,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      'specialization_id': specializationId.toString(),
      'salary': salary,
      if (birthDay != null) 'birth_day': birthDay,
      'country': country,
      'start_time': startTime,
      'work_hours': workHours,
      'workable_type': workableType,
      'workable_id': workableId.toString(),
    });

    if (imagePath != null && imagePath.isNotEmpty) {
      req.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);
    if (kDebugMode) {
      debugPrint('[POST] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }

    if (res.statusCode == 201) return true;
    lastErrorMessage = _msg(res.body) ?? 'فشل إضافة الموظف (${res.statusCode})';
    return false;
  }

  /// تعديل موظف: POST /edit_employe
  /// **[NEW]** POST /edit_employe
  static Future<bool> edit({required Map<String, dynamic> payload}) async {
    final url = Uri.parse('$_base/edit_employe');
    final res = await http.post(
      url,
      headers: await _headers(withJson: true),
      body: jsonEncode(payload),
    );

    if (kDebugMode) {
      debugPrint('[POST] $url -> ${res.statusCode}');
      debugPrint('Payload: ${jsonEncode(payload)}');
      debugPrint('Body: ${res.body}');
    }

    if (res.statusCode == 202) return true; // 202 = editing succesfully!

    lastErrorMessage = _msg(res.body) ?? 'فشل تعديل الموظف (${res.statusCode})';
    return false;
  }

  /// GET /cancel_employe/{id}
  static Future<bool> delete(int employeeId) async {
    final url = Uri.parse('$_base/cancel_employe/$employeeId');
    final res = await http.get(url, headers: await _headers());
    if (kDebugMode) {
      debugPrint('[GET] $url -> ${res.statusCode}');
      debugPrint(res.body);
    }
    if (res.statusCode ~/ 100 == 2) return true;
    lastErrorMessage = _msg(res.body) ?? 'فشل حذف الموظف (${res.statusCode})';
    return false;
  }
}
