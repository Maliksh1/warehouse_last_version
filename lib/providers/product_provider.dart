import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:collection/collection.dart'; // ✅ ضروري لـ firstWhereOrNull

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>(
  (ref) => ProductNotifier(),
);

class ProductNotifier extends StateNotifier<List<Product>> {
  ProductNotifier() : super([]);

  void add(Product product) {
    state = [...state, product];
  }

  Product? getById(String id) {
    return state.firstWhereOrNull((p) => p.id == id);
  }
}

// ✅ مزود حسب ID باستخدام النوع Product?
final productByIdProvider =
    Provider.family<AsyncValue<Product>, String>((ref, id) {
  final products = ref.watch(productProvider);
  final match =
      products.firstWhere((p) => p.id == id, orElse: () => null as Product);

  if (match == null) {
    return AsyncValue.error('المنتج غير موجود', StackTrace.current);
  } else {
    return AsyncValue.data(match);
  }
});
