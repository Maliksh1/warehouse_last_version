import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/warehouse.dart';

final warehouseProvider =
    StateNotifierProvider<WarehouseNotifier, List<Warehouse>>(
  (ref) => WarehouseNotifier()..seedDefaultWarehouses(), // ✅ استدعاء التهيئة
);

// final warehouseProvider =
//     StateNotifierProvider<WarehouseNotifier, List<Warehouse>>(
//   (ref) => WarehouseNotifier(),

// );

class WarehouseNotifier extends StateNotifier<List<Warehouse>> {
  WarehouseNotifier() : super([]);

  void add(Warehouse warehouse) {
    state = [...state, warehouse];
  }

  void update(Warehouse updated) {
    state = state.map((w) => w.id == updated.id ? updated : w).toList();
  }

  void delete(String id) {
    state = state.where((w) => w.id != id).toList();
  }

  void seedDefaultWarehouses() {
    final mock = [
      Warehouse(
        id: 'w1',
        name: 'المستودع الرئيسي',
        address: 'دمشق - المزة',
        capacity: 1000,
        capacityUnit: 'وحدة',
        occupied: 200,
        managerId: 'manager1',
        location: '',
        used: 1,
        manager: '',
        productIds: null,
        usedCapacity: null,
      ),
      Warehouse(
        id: 'w2',
        name: 'مستودع الشرق',
        address: 'حمص - بابا عمرو',
        capacity: 800,
        capacityUnit: 'وحدة',
        occupied: 400,
        managerId: 'manager2',
        location: '',
        used: 1,
        manager: '',
        productIds: null,
        usedCapacity: null,
      ),
      Warehouse(
        id: 'w3',
        name: 'مستودع الجنوب',
        address: 'درعا - السوق',
        capacity: 600,
        capacityUnit: 'وحدة',
        occupied: 300,
        managerId: 'manager3',
        location: '',
        used: 1,
        manager: '',
        productIds: null,
        usedCapacity: null,
      ),
    ];

    state = mock;
  }
}
