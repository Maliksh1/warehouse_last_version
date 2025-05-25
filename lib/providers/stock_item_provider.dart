import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/stock_item.dart';

final stockItemProvider =
    StateNotifierProvider<StockItemNotifier, List<StockItem>>(
  (ref) => StockItemNotifier(),
);

class StockItemNotifier extends StateNotifier<List<StockItem>> {
  StockItemNotifier() : super([]);

  void add(StockItem item) {
    state = [...state, item];
  }

  void remove(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  List<StockItem> getByWarehouse(String warehouseId) {
    return state.where((item) => item.warehouseId == warehouseId).toList();
  }

  List<StockItem> getByProduct(String productId) {
    return state.where((item) => item.productId == productId).toList();
  }

  int getTotalQuantity(String productId) {
    return state
        .where((item) => item.productId == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }
}
