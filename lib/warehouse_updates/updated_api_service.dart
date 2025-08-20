import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/employee.dart';

class ApiService {
  // يمكن تغيير عنوان الخادم حسب بيئة التطوير
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (!withAuth) return headers;

    // اقرأ التوكنات من التخزين الآمن (عدّل أسماء المفاتيح بحسب حفظك)
    const storage = FlutterSecureStorage();
    final bearer = await storage.read(key: 'authToken') ??
        await storage.read(key: 'token') ??
        await storage.read(key: 'access_token');

    final employeToken = await storage.read(key: 'employe_token') ??
        await storage.read(key: 'employee_token'); // إن كان عندك اسم مختلف

    // Debug (من دون طباعة القيم)
    debugPrint(
        '[headers] bearer? ${bearer != null} | employe? ${employeToken != null}');

    // أغلب لارفيل يقبل Authorization: Bearer
    if (bearer != null && bearer.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearer';
    }

    // الباك عندك يطلب "employe token" باسم رأس مخصص — ضع الاسم الذي يتوقعه الباك بدقة
    if (employeToken != null && employeToken.isNotEmpty) {
      headers['employe_token'] =
          employeToken; // <-- غيّرها إذا كان الباك ينتظر 'employe' أو 'employee'
      // headers['employe'] = employeToken;     // جرّب هذا في حال كان الاسم مختلف
    }

    return headers;
  }

  // ========================= المنتجات =========================

  // إضافة منتج جديد
  Future<Map<String, dynamic>> addProduct(
      Map<String, dynamic> productData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/support_new_product'),
        headers: await _headers(),
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'فشل إضافة المنتج: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // الحصول على قائمة المنتجات
  Future<List<dynamic>> getProducts() async {
    try {
      final auth = await _headers(withAuth: true);
      final headers = {
        ...auth,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final url = Uri.parse('$baseUrl/show_products');
      final res = await http.get(url, headers: headers);

      debugPrint('[GET] $url');
      debugPrint('Status: ${res.statusCode}');
      debugPrint('CT    : ${res.headers['content-type']}');

      final raw = (res.body).trim();
      final isJsonLike = raw.startsWith('{') || raw.startsWith('[');

      // اعتبر 200/201/202/204 نجاح
      if (res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 202 ||
          res.statusCode == 204) {
        if (raw.isEmpty || raw == 'null') return <dynamic>[];
        if (!isJsonLike) {
          // السيرفر قال JSON لكنه رجّع نص — نتجنب الكسر ونرجع []
          debugPrint(
              'Non-JSON body preview: ${raw.length > 180 ? raw.substring(0, 180) + '…' : raw}');
          return <dynamic>[];
        }

        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
        if (decoded is Map) {
          if (decoded['products'] is List)
            return List<dynamic>.from(decoded['products']);
          if (decoded['data'] is List)
            return List<dynamic>.from(decoded['data']);
          if (decoded['items'] is List)
            return List<dynamic>.from(decoded['items']);
        }
        return <dynamic>[];
      }

      if (res.statusCode == 401) {
        throw Exception('401 Unauthorized: تأكد من التوكن/الصلاحيات');
      }

      // أخطاء أخرى: حاول استخراج رسالة مفهومة
      try {
        final err = jsonDecode(raw);
        final msg =
            (err['message'] ?? err['msg'] ?? err['error'] ?? err).toString();
        throw Exception('فشل الحصول على المنتجات: ${res.statusCode} - $msg');
      } catch (_) {
        throw Exception('فشل الحصول على المنتجات: ${res.statusCode} - $raw');
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
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
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
        headers: await _headers(),
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'فشل تحديث المنتج: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // حذف منتج
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// ...

// ...

  Future<bool> deleteProduct(String productId) async {
    final headers = {
      ...await _headers(), // فيها Authorization + employe إلخ
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    String _msg(http.Response r) {
      try {
        final j = jsonDecode(r.body);
        return (j['msg'] ?? j['message'] ?? r.body).toString();
      } catch (_) {
        return r.body;
      }
    }

    bool _ok(int s) => s == 200 || s == 201 || s == 202;

    // محاولة A: GET /delete_product/{id}  (كثير من الراآت لاراڤيل بتستخدمها)
    var url = Uri.parse('$baseUrl/delete_product/$productId');
    var res = await http.get(url, headers: headers);
    debugPrint('[GET] $url => ${res.statusCode} ${res.body}');
    if (_ok(res.statusCode)) return true;

    // محاولة B: DELETE /delete_product/{id}
    url = Uri.parse('$baseUrl/delete_product/$productId');
    res = await http.delete(url, headers: headers);
    debugPrint('[DELETE] $url => ${res.statusCode} ${res.body}');
    if (_ok(res.statusCode)) return true;

    // محاولة C: POST /delete_product  { product_id: ... }
    url = Uri.parse('$baseUrl/delete_product');
    res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'product_id': int.tryParse(productId) ?? productId}),
    );
    debugPrint('[POST] $url (product_id) => ${res.statusCode} ${res.body}');
    if (_ok(res.statusCode)) return true;

    // محاولات احتياط لمسارات بديلة إن وُجدت عندك
    url = Uri.parse('$baseUrl/products/$productId');
    res = await http.delete(url, headers: headers);
    debugPrint('[DELETE] $url => ${res.statusCode} ${res.body}');
    if (_ok(res.statusCode)) return true;

    url = Uri.parse('$baseUrl/products/delete');
    res = await http.post(
      url,
      headers: headers,
      body: jsonEncode({'id': int.tryParse(productId) ?? productId}),
    );
    debugPrint('[POST] $url (id) => ${res.statusCode} ${res.body}');
    if (_ok(res.statusCode)) return true;

    // فشل كل المحاولات — أظهر رسالة السيرفر الفعلية
    throw Exception('فشل الحذف: ${res.statusCode} - ${_msg(res)}');
  }

  Future<Map<String, dynamic>> editProduct(Map<String, dynamic> body) async {
    final headers = {
      ...await _headers(), // يحتوي Authorization / employe من التخزين الآمن
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final url = Uri.parse('$baseUrl/edit_product'); // نفس اسم دالة الباك
    final res = await http.post(url, headers: headers, body: jsonEncode(body));

    debugPrint('[POST] $url => ${res.statusCode} ${res.body}');

    bool ok(int s) => s == 200 || s == 201 || s == 202;

    if (ok(res.statusCode)) {
      final decoded = jsonDecode(res.body);
      return decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'msg': 'Product updated successfully.'};
    }

    // أظهر رسالة الباك الفعلية
    try {
      final j = jsonDecode(res.body);
      final msg = (j['msg'] ?? j['message'] ?? res.body).toString();
      throw Exception('فشل التعديل: ${res.statusCode} - $msg');
    } catch (_) {
      throw Exception('فشل التعديل: ${res.statusCode} - ${res.body}');
    }
  }
  // ====================== أنواع المنتجات ======================

  /// إضافة نوع منتج (الشاشة ترسل name فقط وتنتظر خريطة فيها msg)
  // updated_api_service.dart
  Future<Map<String, dynamic>> addProductType(String name, String _) async {
    try {
      final payload = {
        'name': name.trim(),
        'type_name': name.trim(),
        // إن كان الباك يرفض غياب specification:
        // 'specification': 'General',
      };

      final url = Uri.parse('$baseUrl/create_new_type');
      final response = await http.post(
        url,
        headers: await _headers(withAuth: true), // ✅ الآن التوكن موجود
        body: jsonEncode(payload),
      );

      debugPrint('[POST] $url');
      debugPrint('Payload: $payload');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body  : ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 202) {
        final decoded = jsonDecode(response.body);
        return decoded is Map<String, dynamic>
            ? decoded
            : {'msg': 'تمت الإضافة بنجاح'};
      }

      if (response.statusCode == 401) {
        throw Exception(
            '401 Unauthorized: تأكد من التوكن (تسجيل الدخول مطلوب)');
      }

      // حاول استخراج رسالة واضحة من الباك
      try {
        final err = jsonDecode(response.body);
        final msg =
            (err['message'] ?? err['msg'] ?? err['error'] ?? err).toString();
        throw Exception('فشل إضافة النوع: ${response.statusCode} - $msg');
      } catch (_) {
        throw Exception(
            'فشل إضافة النوع: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// تعديل اسم النوع — الشاشة تتوقع bool
  Future<bool> editProductType(int typeId, String newName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/edit_type'),
        headers: await _headers(),
        body: jsonEncode({'type_id': typeId, 'name': newName}),
      );
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// حذف النوع — الشاشة تتوقع bool
  Future<bool> deleteProductType(int typeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delete_type/$typeId'),
        headers: await _headers(),
      );
      return response.statusCode == 200 || response.statusCode == 202;
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  /// (اختياري) جلب الأنواع — يدعم /show_all_types أو /product_types
  Future<List<dynamic>> getProductTypes() async {
    try {
      // لو باكك يعتمد show_all_types ويعيد {types: [...]}
      final response = await http.get(
        Uri.parse('$baseUrl/show_all_types'),
        headers: await _headers(),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['types'] is List) {
          return decoded['types'] as List;
        }
        if (decoded is List) return decoded;
        return [];
      } else {
        throw Exception(
            'فشل الحصول على أنواع المنتجات: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
  // =================== الاختصاصات (Specializations) ===================

// جلب كل الاختصاصات
  Future<List<dynamic>> getSpecializations() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/show_all_specializations'),
        headers: await _headers(),
      );

      // الباك عندك يرجّع 202 عند النجاح
      if (res.statusCode == 200 || res.statusCode == 202) {
        final decoded = jsonDecode(res.body);
        // الشكل المتوقّع: { "msg": "...", "specializations": [...] }
        if (decoded is Map && decoded['specializations'] is List) {
          return decoded['specializations'] as List;
        }
        if (decoded is List) return decoded;
        return [];
      } else if (res.statusCode == 404) {
        // لا توجد اختصاصات بعد
        return [];
      } else {
        throw Exception('فشل جلب الاختصاصات: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

// إضافة اختصاص جديد
  Future<bool> addSpecialization(String name) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/create_new_specialization'),
        headers: await _headers(),
        body: jsonEncode({
          'specification': 'Specialization', // حسب الباك
          'name': name,
        }),
      );
      return res.statusCode == 200 ||
          res.statusCode == 201 ||
          res.statusCode == 202;
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

// تعديل اختصاص
  Future<bool> editSpecialization(int specId, String newName) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/edit_Specialization'),
        headers: await _headers(),
        body: jsonEncode({
          'spec_id': specId,
          'name': newName,
        }),
      );
      // الباك يرجّع 201 عند نجاح التعديل، و 403 لو مرّت 30 دقيقة
      if (res.statusCode == 201) return true;
      if (res.statusCode == 403)
        return false; // "You can't edit after 30 minutes."
      throw Exception('فشل تعديل الاختصاص: ${res.statusCode} - ${res.body}');
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

// حذف اختصاص
  Future<bool> deleteSpecialization(int specId) async {
    try {
      // بحسب أسامي الدوال في الباك، المسار عادةً يكون بالشكل التالي:
      final res = await http.get(
        Uri.parse('$baseUrl/delete_Specialization/$specId'),
        headers: await _headers(),
      );
      // الباك يرجّع 202 عند النجاح
      return res.statusCode == 200 || res.statusCode == 202;
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
  // ==================== الموظفون (Employees) ====================

// جلب كل الموظفين (الباك يعيد قائمة تخصصات ومع كل تخصص employees)
// نُسطّحها إلى List<Employee>
  Future<List<Employee>> getAllEmployees() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/show_all_employees'),
        headers: await _headers(),
      );

      if (res.statusCode == 200 || res.statusCode == 202) {
        final decoded = jsonDecode(res.body);

        // الشكل المتوقع: { "msg": "...", "employees": [ {spec... , employees:[...]} , ... ] }
        final List<Employee> out = [];
        if (decoded is Map && decoded['employees'] is List) {
          final List specs = decoded['employees'];
          for (final spec in specs) {
            final inner = (spec is Map) ? spec['employees'] : null;
            if (inner is List) {
              for (final e in inner) {
                if (e is Map<String, dynamic>) {
                  out.add(Employee.fromJson(e));
                } else if (e is Map) {
                  out.add(Employee.fromJson(e.cast<String, dynamic>()));
                }
              }
            }
          }
          return out;
        }

        // fallback لو رجّع قائمة موظفين مباشرة
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((m) => Employee.fromJson(m.cast<String, dynamic>()))
              .toList();
        }

        return <Employee>[];
      } else if (res.statusCode == 404) {
        // لا يوجد موظفون
        return <Employee>[];
      } else {
        throw Exception('فشل جلب الموظفين: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

// جلب موظفي مكان محدد (Warehouse) وفق باك: show_employees_on_place/{place_type}/{place_id}
  Future<List<Employee>> getEmployeesByWarehouse(String warehouseId) async {
    try {
      final id =
          warehouseId; // يمكن التحويل إلى int لو أردت: int.tryParse(warehouseId)
      final res = await http.get(
        Uri.parse('$baseUrl/show_employees_on_place/Warehouse/$id'),
        headers: await _headers(),
      );

      if (res.statusCode == 200 || res.statusCode == 202) {
        final decoded = jsonDecode(res.body);
        // المتوقع: { "msg": "...", "employees": [ ... ] }
        if (decoded is Map && decoded['employees'] is List) {
          final List list = decoded['employees'];
          return list
              .whereType<Map>()
              .map((m) => Employee.fromJson(m.cast<String, dynamic>()))
              .toList();
        }
        // fallback
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((m) => Employee.fromJson(m.cast<String, dynamic>()))
              .toList();
        }
        return <Employee>[];
      } else if (res.statusCode == 404) {
        return <Employee>[];
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized - Invalid or missing employe token');
      } else {
        throw Exception(
            'فشل جلب موظفي المستودع: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }

  // جلب موظفي تخصص معين /show_employees_of_spec/{spec_id}
  Future<List<Employee>> getEmployeesBySpecialization(int specId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/show_employees_of_spec/$specId'),
        headers: await _headers(),
      );

      if (res.statusCode == 200 || res.statusCode == 202) {
        final decoded = jsonDecode(res.body);
        // المتوقع من الباك: { "msg": "...", "employees": [ ... ] }
        if (decoded is Map && decoded['employees'] is List) {
          final List list = decoded['employees'];
          return list
              .whereType<Map>()
              .map((m) => Employee.fromJson(m.cast<String, dynamic>()))
              .toList();
        }
        // fallback لو رجّع قائمة مباشرة
        if (decoded is List) {
          return decoded
              .whereType<Map>()
              .map((m) => Employee.fromJson(m.cast<String, dynamic>()))
              .toList();
        }
        return <Employee>[];
      } else if (res.statusCode == 404) {
        // لا يوجد موظفون لهذا التخصص
        return <Employee>[];
      } else {
        throw Exception(
            'فشل جلب موظفي التخصص: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال بالخادم: $e');
    }
  }
}
