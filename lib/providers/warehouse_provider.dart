import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/services/warehouse_api.dart';

class WarehousesNotifier extends StateNotifier<List<Warehouse>> {
  WarehousesNotifier() : super([]);

  Future<void> reload() async {
    final list = await WarehouseApi.fetchAllWarehouses();
    state = list;
  }

  void replaceOne(Warehouse updated) {
    state = [
      for (final w in state)
        if (w.id == updated.id) updated else w,
    ];
  }

  void removeById(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void addOne(Warehouse w) {
    state = [...state, w];
  }
}

final warehouseProvider =
    StateNotifierProvider<WarehousesNotifier, List<Warehouse>>(
  (ref) => WarehousesNotifier(),
);
