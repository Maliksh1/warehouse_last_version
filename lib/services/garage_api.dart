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

  // دالة مساعدة لطباعة الرسائل بشكل منظم
  static void _log(String methodName, String message) {
    if (kDebugMode) {
      debugPrint(
          '===== [GarageApi - $methodName] =====\n$message\n===================================');
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'token');

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    // طباعة الـ Headers للتأكد من وجود التوكن
    _log('_getHeaders', 'Headers prepared: $headers');
    return headers;
  }

  static Future<List<Vehicle>> fetchVehiclesInGarage(int garageId) async {
    const methodName = 'fetchVehiclesInGarage';
    final url = Uri.parse('$_base/show_vehicles_of_garage/$garageId');
    _log(methodName, 'Calling API: $url');

    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final vehicles = (data['vehicles'] as List? ?? []);
        _log(methodName, 'Success: Fetched ${vehicles.length} vehicles.');
        return vehicles.map((v) => Vehicle.fromJson(v)).toList();
      } else if (res.statusCode == 404) {
        _log(methodName,
            'Success: No vehicles found (404). Returning empty list.');
        return [];
      } else {
        lastErrorMessage = 'Failed to load vehicles. Status: ${res.statusCode}';
        _log(methodName, 'Error: $lastErrorMessage');
        throw Exception(lastErrorMessage);
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  static Future<Map<String, dynamic>?> createImportOperation(
      Map<String, dynamic> payload) async {
    const methodName = 'createImportOperation';
    final url = Uri.parse('$_base/create_import_op_vehicles');
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');

    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 201) {
        _log(methodName, 'Success: Import operation created.');
        return jsonDecode(res.body);
      }

      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to create import operation';
      _log(methodName, 'Error: $lastErrorMessage');
      return null;
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return null;
    }
  }

  static Future<List<GarageItem>> fetchAllGarages() async {
    const methodName = 'fetchAllGarages';
    final url = Uri.parse('$_base/show_all_garages');
    _log(methodName, 'Calling API: $url');

    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final garages = (data['data'] ?? data['garages'] ?? []) as List;
        _log(methodName, 'Success: Fetched ${garages.length} garages.');
        return garages.map((g) => GarageItem.fromJson(g)).toList();
      } else {
        lastErrorMessage =
            'Failed to load all garages. Status: ${res.statusCode}';
        _log(methodName, 'Error: $lastErrorMessage');
        throw Exception(lastErrorMessage);
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  static Future<List<GarageItem>> fetchGaragesForPlace(
      String placeType, int placeId) async {
    const methodName = 'fetchGaragesForPlace';
    final url = Uri.parse('$_base/show_garages_on_place/$placeType/$placeId');
    _log(methodName, 'Calling API: $url');

    try {
      final res = await http.get(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 200 || res.statusCode == 202) {
        final data = jsonDecode(res.body);
        final garages = (data['data'] ?? data['garages'] ?? []) as List;
        _log(methodName,
            'Success: Fetched ${garages.length} garages for $placeType $placeId.');
        return garages.map((g) => GarageItem.fromJson(g)).toList();
      } else {
        lastErrorMessage =
            'Failed to load garages for place. Status: ${res.statusCode}';
        _log(methodName, 'Error: $lastErrorMessage');
        throw Exception(lastErrorMessage);
      }
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      throw Exception(lastErrorMessage);
    }
  }

  static Future<bool> createGarage(Map<String, dynamic> payload) async {
    const methodName = 'createGarage';
    final url = Uri.parse('$_base/create_new_garage');
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');

    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 201) {
        _log(methodName, 'Success: Garage created.');
        return true;
      }

      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to create garage';
      _log(methodName, 'Error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  static Future<bool> editGarage(Map<String, dynamic> payload) async {
    const methodName = 'editGarage';
    final url = Uri.parse('$_base/edit_garage');
    _log(methodName, 'Calling API: $url\nPayload: ${jsonEncode(payload)}');

    try {
      final res = await http.post(url,
          headers: await _getHeaders(), body: jsonEncode(payload));
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        _log(methodName, 'Success: Garage edited.');
        return true;
      }

      lastErrorMessage = jsonDecode(res.body)['msg'] ?? 'Failed to edit garage';
      _log(methodName, 'Error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }

  static Future<bool> deleteGarage(int garageId) async {
    const methodName = 'deleteGarage';
    final url = Uri.parse('$_base/delete_garage/$garageId');
    _log(methodName, 'Calling API: $url');

    try {
      final res = await http.delete(url, headers: await _getHeaders());
      _log(methodName,
          'Response Status: ${res.statusCode}\nResponse Body: ${res.body}');

      if (res.statusCode == 202) {
        _log(methodName, 'Success: Garage deleted.');
        return true;
      }

      lastErrorMessage =
          jsonDecode(res.body)['msg'] ?? 'Failed to delete garage';
      _log(methodName, 'Error: $lastErrorMessage');
      return false;
    } catch (e) {
      lastErrorMessage = 'An exception occurred in $methodName: $e';
      _log(methodName, 'Exception: $lastErrorMessage');
      return false;
    }
  }
}
