import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/api_service_provider.dart';

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
  (ref) => ProductNotifier(ref),
);

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier(this.ref) : super([]);
  final Ref ref;

  // ApiService من مزود مشترك عندك
  dynamic get _api => ref.read(apiServiceProvider);

  /// تحميل المنتجات من السيرفر عند بدء التشغيل
  Future<void> loadFromBackend() async {
    try {
      final dynamic raw = await _api.getProducts();

      List<dynamic> _fromMap(Map map) {
        final m = Map<String, dynamic>.from(map);
        if (m['products'] is List) return List<dynamic>.from(m['products']);
        if (m['data'] is List) return List<dynamic>.from(m['data']);
        if (m['items'] is List) return List<dynamic>.from(m['items']);
        return const [];
      }

      List<dynamic> _fromString(String s) {
        String t = s.trim();
        final start = t.indexOf(RegExp(r'[\{\[]')); // أول { أو [
        if (start == -1) return const [];
        t = t.substring(start);
        final lastBrace = t.lastIndexOf('}');
        final lastBracket = t.lastIndexOf(']');
        final end = (lastBrace > lastBracket) ? lastBrace : lastBracket;
        if (end != -1) t = t.substring(0, end + 1);

        final decoded = jsonDecode(t);
        if (decoded is List) return decoded;
        if (decoded is Map) return _fromMap(decoded);
        return const [];
      }

      List<dynamic> listDyn = const [];

      if (raw is List) {
        listDyn = raw;
      } else if (raw is Map) {
        listDyn = _fromMap(raw);
      } else if (raw is String) {
        listDyn = _fromString(raw);
      }

      final products = listDyn
          .whereType<Map>()
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      state = products;
    } catch (e, st) {
      debugPrint('خطأ في تحميل المنتجات: $e');
      debugPrintStack(stackTrace: st);
      state = const [];
    }
  }

  /// إضافة منتج (إرسال للـ API ثم مزامنة الحالة)
  Future<void> add(Product product) async {
    try {
      final createdJson = await _api.addProduct(product.toApiJson());
      final created = Product.fromJson(
        Map<String, dynamic>.from(createdJson is Map ? createdJson : {}),
      );
      state = [...state, created];
    } catch (e, st) {
      debugPrint('فشل في إضافة المنتج: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// تحديث منتج
  Future<void> update(Product updated) async {
    try {
      final updatedJson =
          await _api.updateProduct(updated.id, updated.toApiJson());
      final fresh = Product.fromJson(
        Map<String, dynamic>.from(updatedJson is Map ? updatedJson : {}),
      );
      state = [
        for (final p in state)
          if (p.id == updated.id) fresh else p,
      ];
    } catch (e, st) {
      debugPrint('فشل تحديث المنتج: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  /// حذف منتج
  Future<void> remove(String id) async {
    final old = state;
    state = state.where((p) => p.id != id).toList(); // تفاؤليًا
    try {
      final ok = await _api.deleteProduct(id);
      if (!ok) {
        state = old;
        throw Exception('حذف المنتج فشل من الخادم');
      }
    } catch (e, st) {
      state = old;
      debugPrint('فشل حذف المنتج: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Product? getById(String id) => state.firstWhere((p) => p.id == id);
}
