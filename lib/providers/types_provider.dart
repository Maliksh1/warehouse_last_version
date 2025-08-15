// import 'dart:convert';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// final typesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
//   const storage = FlutterSecureStorage();
//   final token = await storage.read(key: 'token');

//   if (token == null) {
//     throw Exception("Missing token");
//   }

//   final response = await http.get(
//     Uri.parse('http://127.0.0.1:8000/api/show_all_types'),
//     headers: {
//       'Authorization': 'Bearer $token',
//       'Accept': 'application/json',
//     },
//   );

//   if (response.statusCode == 200 || response.statusCode == 202) {
//     final data = jsonDecode(response.body);
//     return (data['types'] as List).cast<Map<String, dynamic>>();
//   } else {
//     throw Exception('فشل تحميل الأنواع: ${response.statusCode}');
//   }
// });
