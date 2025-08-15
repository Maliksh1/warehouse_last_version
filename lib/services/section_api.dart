import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/warehouse_section.dart';

class SectionApi {
  static Future<bool> createSection({
    required int warehouseId,
    required String name,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/create_new_section'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'warehouse_id': warehouseId,
        'name': name,
      }),
    );

    debugPrint("Create section: ${response.statusCode}");
    return response.statusCode == 200 || response.statusCode == 201;
  }

  static Future<bool> editSection({
    required int id,
    required String name,
  }) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/edit_section'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'section_id': id,
        'name': name,
      }),
    );

    debugPrint("Edit section: ${response.statusCode}");
    return response.statusCode == 200;
  }

  static Future<bool> deleteSection(int id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/delete_section/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("Delete section: ${response.statusCode}");
    return response.statusCode == 200;
  }

  static Future<List<WarehouseSection>> fetchSectionsByWarehouse(
      int warehouseId) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final url = Uri.parse(
        'http://127.0.0.1:8000/api/show_sections_on_place/Warehouse/$warehouseId');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    debugPrint("Fetch sections status: ${response.statusCode}");
    debugPrint("Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List sectionsJson = data['sections'] ?? [];
      return sectionsJson.map((e) => WarehouseSection.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load sections');
    }
  }
}
