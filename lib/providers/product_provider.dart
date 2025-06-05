import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/services/product_api.dart'; // خدمة API الخارجية

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
  (ref) => ProductNotifier(),
);

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]);

  /// تحميل المنتجات من السيرفر عند بدء التشغيل
  Future<void> loadFromBackend() async {
    try {
      final fetched = await ProductApi.fetchAllProducts(); // 👈 استدعاء API
      state = fetched;
    } catch (e) {
      print('خطأ في تحميل المنتجات: $e');
    }
  }

  /// إضافة منتج (محلي + API)
  Future<void> add(Product product) async {
    try {
      state = [...state, product]; // إضافة محليًا
      await ProductApi.createProduct(product); // مزامنة مع API
    } catch (e) {
      print('فشل في إضافة المنتج: $e');
    }
  }

  /// تحديث منتج (اختياري مستقبلًا)
  Future<void> update(Product updated) async {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p,
    ];
    await ProductApi.updateProduct(updated);
  }

  /// حذف منتج
  Future<void> remove(String id) async {
    state = state.where((p) => p.id != id).toList();
    await ProductApi.deleteProduct(id);
  }

  Product? getById(String id) {
    return state.firstWhere((p) => p.id == id);
  }
}
