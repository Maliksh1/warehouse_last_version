// transfers_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:warehouse/models/transfer.dart';

class TransfersApi {
  static const String _base = 'http://127.0.0.1:8000/api';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.read(key: 'token');
    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static String _normalizePlaceType(String raw) {
    final t = raw.trim().replaceAll('_', ' ').toLowerCase();
    if (t.startsWith('ware')) return 'Warehouse';
    if (t.startsWith('dist')) return 'DistributionCenter';
    if (raw == 'Warehouse' || raw == 'DistributionCenter') return raw;
    return 'Warehouse';
  }

  static Future<TransferBuckets> fetchIncoming(
      String placeType, int placeId) async {
    final norm = _normalizePlaceType(placeType);
    final url = Uri.parse('$_base/show_incoming_transfers/$norm/$placeId');
    if (kDebugMode) debugPrint('[TransfersApi] GET $url');
    final res = await http.get(url, headers: await _headers());
    Map<String, dynamic>? body;
    try {
      body = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('[TransfersApi] status: ${res.statusCode}');
      debugPrint('[TransfersApi] body  : ${res.body}');
    }

    if (res.statusCode == 202) {
      return _parseBuckets(body);
    }
    if (res.statusCode == 404) {
      // لا توجد تحويلات واردة
      return const TransferBuckets(live: [], archiv: [], wait: []);
    }
    throw Exception(body?['msg'] ?? 'Failed to load incoming transfers');
  }

  static Future<TransferBuckets> fetchOutgoing(
      String placeType, int placeId) async {
    final norm = _normalizePlaceType(placeType);
    final url = Uri.parse('$_base/show_left_transfers_on_place/$norm/$placeId');
    if (kDebugMode) debugPrint('[TransfersApi] GET $url');
    final res = await http.get(url, headers: await _headers());
    Map<String, dynamic>? body;
    try {
      body = res.body.isNotEmpty
          ? jsonDecode(res.body) as Map<String, dynamic>
          : null;
    } catch (_) {}

    if (kDebugMode) {
      debugPrint('[TransfersApi] status: ${res.statusCode}');
      debugPrint('[TransfersApi] body  : ${res.body}');
    }

    if (res.statusCode == 202) {
      return _parseBuckets(body);
    }
    if (res.statusCode == 404) {
      // لا توجد تحويلات صادرة
      return const TransferBuckets(live: [], archiv: [], wait: []);
    }
    throw Exception(body?['msg'] ?? 'Failed to load outgoing transfers');
  }

  static TransferBuckets _parseBuckets(Map<String, dynamic>? body) {
    final live = ((body?['live'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TransferItem.fromJson)
        .toList();
    final archiv = ((body?['archiv'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TransferItem.fromJson)
        .toList();
    final wait = ((body?['wait'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TransferItem.fromJson)
        .toList();
    return TransferBuckets(live: live, archiv: archiv, wait: wait);
  }
}
