import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/warehouse.dart';

class WarehouseApi {
  static Future<bool> createNewWarehouse(Map<String, dynamic> data) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/create_new_warehouse'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      print("Response body: ${response.body}");
      print("Warehouse creation response: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating warehouse: $e');
      debugPrint("Sending warehouse data: $data");

      return false;
    }
  }

  static Future<List<Warehouse>> fetchAllWarehouses() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/show_all_warehouses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List warehousesJson = decoded['warehouses'] ?? [];
      return warehousesJson.map((e) => Warehouse.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load warehouses");
    }
  }

  // services/warehouse_api.dart
  static Future<bool> deleteWarehouse(int id) async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      final url = Uri.parse('http://127.0.0.1:8000/api/delete_warehouse/$id');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("Delete warehouse response: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 202) {
        return true; // ✅ نجاح فعلي
      } else {
        print("Failed to delete warehouse, status: ${response.statusCode}");
        return false; // ❌ لا ترمِ استثناء
      }
    } catch (e) {
      print("Exception in deleteWarehouse: $e");
      return false;
    }
  }
}
