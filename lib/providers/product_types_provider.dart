import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

// مزود لجلب قائمة الأنواع من السيرفر
final productTypesProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final storage = const FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/show_all_types'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['types'] ?? [];
  } else {
    throw Exception('فشل جلب أنواع المنتجات');
  }
});
