// lib/services/garage_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/models/vehicle.dart';

class GarageApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static String? lastErrorMessage;

  static Future<Map<String, String>> _getHeaders() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<List<Vehicle>> fetchVehiclesInGarage(int garageId) async {
    final url = Uri.parse('$_base/show_vehicles_of_garage/$garageId');
    final res = await http.get(url, headers: await _getHeaders());

    if (res.statusCode == 202) {
      final data = jsonDecode(res.body);
      final vehicles = (data['vehicles'] as List? ?? []);
      return vehicles.map((v) => Vehicle.fromJson(v)).toList();
    } else if (res.statusCode == 404) {
      return [];
    } else {
      lastErrorMessage = 'Failed to load vehicles';
      throw Exception(lastErrorMessage);
    }
  }

  static Future<Map<String, dynamic>?> createImportOperation(
      Map<String, dynamic> payload) async {
    final url = Uri.parse('$_base/create_import_op_vehicles');
    final res = await http.post(url,
        headers: await _getHeaders(), body: jsonEncode(payload));

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }

    lastErrorMessage =
        jsonDecode(res.body)['msg'] ?? 'Failed to create import operation';
    return null;
  }

  static Future<List<GarageItem>> fetchAllGarages() async {
    final url = Uri.parse('$_base/show_all_garages');
    final res = await http.get(url, headers: await _getHeaders());

    if (res.statusCode == 202) {
      final data = jsonDecode(res.body);
      final garages = (data['data'] ?? data['garages'] ?? []) as List;
      return garages.map((g) => GarageItem.fromJson(g)).toList();
    } else {
      lastErrorMessage = 'Failed to load all garages';
      throw Exception(lastErrorMessage);
    }
  }

  static Future<List<GarageItem>> fetchGaragesForPlace(
      String placeType, int placeId) async {
    final url = Uri.parse('$_base/show_garages_on_place/$placeType/$placeId');
    final res = await http.get(url, headers: await _getHeaders());

    if (res.statusCode == 200 || res.statusCode == 202) {
      final data = jsonDecode(res.body);
      final garages = (data['data'] ?? data['garages'] ?? []) as List;
      return garages.map((g) => GarageItem.fromJson(g)).toList();
    } else {
      lastErrorMessage = 'Failed to load garages for place';
      throw Exception(lastErrorMessage);
    }
  }

  static Future<bool> createGarage(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_base/create_new_garage');
    final res = await http.post(url,
        headers: await _getHeaders(), body: jsonEncode(payload));

    if (res.statusCode == 201) return true;

    lastErrorMessage = jsonDecode(res.body)['msg'] ?? 'Failed to create garage';
    return false;
  }

  static Future<bool> editGarage(Map<String, dynamic> payload) async {
    final url = Uri.parse('$_base/edit_garage');
    final res = await http.post(url,
        headers: await _getHeaders(), body: jsonEncode(payload));

    if (res.statusCode == 202) return true;

    lastErrorMessage = jsonDecode(res.body)['msg'] ?? 'Failed to edit garage';
    return false;
  }

  static Future<bool> deleteGarage(int garageId) async {
    final url = Uri.parse('$_base/delete_garage/$garageId');
    final res = await http.delete(url, headers: await _getHeaders());

    if (res.statusCode == 202) return true;

    lastErrorMessage = jsonDecode(res.body)['msg'] ?? 'Failed to delete garage';
    return false;
  }
}
