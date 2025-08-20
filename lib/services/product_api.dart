// lib/services/product_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/supported_product_request.dart';

class ProductApi {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

  static Future<bool> supportNewProduct(SupportedProductRequest req) async {
    // قراءة التوكن بنفس نمط مشروعك
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    // تجهيز الحمولة
    final payload = Map<String, dynamic>.from(req.toJson());

    // في حال كان الباك يتوقع 'type_id' بدل 'typeId'
    if (!payload.containsKey('type_id') && payload.containsKey('typeId')) {
      final raw = payload['typeId'];
      final asInt = int.tryParse(raw?.toString() ?? '');
      payload['type_id'] = asInt ?? raw;
      // payload.remove('typeId'); // فعّل هذا السطر إذا كان السيرفر يرفض وجود الحقلين معاً
    }

    final uri = Uri.parse('$_baseUrl/support_new_product');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    debugPrint('support_new_product -> ${res.statusCode}');
    debugPrint('support_new_product body -> ${res.body}');

    // اعتبر النجاح 200/201/202 (حسب نمط بقية الـ APIs عندك)
    return res.statusCode == 200 ||
        res.statusCode == 201 ||
        res.statusCode == 202;
  }
}
