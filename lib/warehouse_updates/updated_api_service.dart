import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // يمكن تغيير عنوان الخادم حسب بيئة التطوير
  final String baseUrl = 'http://127.0.0.1:8000/api';

  // إضافة منتج جديد
  Future<Map<String, dynamic>> addProduct(
      Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_new_product'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_API_TOKEN', // يمكن استبدالها بتوكن حقيقي
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // تم إنشاء المنتج بنجاح
        return jsonDecode(response.body);
      } else {
        // حدث خطأ أثناء إنشاء المنتج
        throw Exception(
            'فشل إضافة المنتج: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // إضافة نوع منتج جديد
  Future<Map<String, dynamic>> addProductType(
      String name, String specification) async {
    try {
      final Map<String, dynamic> typeData = {
        'name': name,
        'specification': specification,
      };

      // تصحيح الإملاء في عنوان API
      final response = await http.post(
        Uri.parse('$baseUrl/create_new_specification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer YOUR_API_TOKEN', // يمكن استبدالها بتوكن حقيقي
        },
        body: jsonEncode(typeData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // تم إنشاء النوع بنجاح
        return jsonDecode(response.body);
      } else {
        // حدث خطأ أثناء إنشاء النوع
        throw Exception(
            'فشل إضافة النوع: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // الحصول على قائمة المنتجات
  Future<List<dynamic>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل الحصول على المنتجات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // الحصول على قائمة أنواع المنتجات
  Future<List<dynamic>> getProductTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product_types'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'فشل الحصول على أنواع المنتجات: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // الحصول على تفاصيل منتج محدد
  Future<Map<String, dynamic>> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل الحصول على تفاصيل المنتج: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // تحديث منتج موجود
  Future<Map<String, dynamic>> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('فشل تحديث المنتج: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // حذف منتج
  Future<bool> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/products/$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_API_TOKEN',
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
}
