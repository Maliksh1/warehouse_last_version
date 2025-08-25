// lib/providers/data_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// نماذج المشروع
import 'package:warehouse/models/category.dart';
import 'package:warehouse/models/customer.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/models/invoice.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/specialization.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/transport_task.dart';
import 'package:warehouse/models/vehicle.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/stock_item.dart';

// في المشروع لديك productProvider منفصل
import 'package:warehouse/providers/product_provider.dart';

/// ======================
///  Fetch (بدون Mock)
/// ======================
/// مبدئيًا: نعطي قوائم فاضية. لاحقًا يمكن ربط كل واحدة بخدمة API مناسبة.

Future<List<Category>> fetchCategories() async {
  // TODO: اربط مع API التصنيفات إن وجِد
  return const <Category>[];
}

Future<List<Customer>> fetchCustomers() async {
  // TODO: اربط مع API الزبائن
  return const <Customer>[];
}

Future<List<DistributionCenter>> fetchDistributionCenters() async {
  // ملاحظة: لديك بالفعل مزود مخصص حسب الـ warehouse (distributionCentersProvider),
  // هذا مزود عام يعود بقائمة فاضية حتى لا يتعارض مع شيء.
  return const <DistributionCenter>[];
}

Future<List<Employee>> fetchEmployees() async {
  // لديك شاشة EmployeesScreen التي تجلب حسب المكان، هنا إبقها عامة وفارغة.
  return const <Employee>[];
}

Future<List<GarageItem>> fetchGarageItems() async {
  return const <GarageItem>[];
}

Future<List<Invoice>> fetchInvoices() async {
  return const <Invoice>[];
}

Future<List<Product>> fetchProducts() async {
  // لديك productProvider الخاص بك — هذا احتياطي إن كنت تحتاجه في مكان عام.
  return const <Product>[];
}

Future<List<Specialization>> fetchSpecializations() async {
  return const <Specialization>[];
}

Future<List<Supplier>> fetchSuppliers() async {
  return const <Supplier>[];
}

Future<List<Vehicle>> fetchVehicles() async {
  return const <Vehicle>[];
}

/// ======================
///  State Notifiers
/// ======================

class WarehouseNotifier extends StateNotifier<AsyncValue<List<Warehouse>>> {
  WarehouseNotifier() : super(const AsyncValue.data(<Warehouse>[]));

  /// استدعِ هذه من الخارج بعد ربط API المستودعات
  Future<void> refresh(List<Warehouse> items) async {
    state = AsyncValue.data(List<Warehouse>.from(items));
  }

  /// عمليات محلية على الستيت — اختيارية
  Future<void> addWarehouse(Warehouse w) async {
    final current = state.value ?? const <Warehouse>[];
    state = AsyncValue.data([...current, w]);
  }

  Future<void> setWarehouses(List<Warehouse> items) async {
    state = AsyncValue.data(List<Warehouse>.from(items));
  }
}

class TransportTaskNotifier
    extends StateNotifier<AsyncValue<List<TransportTask>>> {
  TransportTaskNotifier() : super(const AsyncValue.data(<TransportTask>[]));

  Future<void> refresh(List<TransportTask> items) async {
    state = AsyncValue.data(List<TransportTask>.from(items));
  }

  Future<void> addTask(TransportTask t) async {
    final current = state.value ?? const <TransportTask>[];
    state = AsyncValue.data([...current, t]);
  }
}

class StockItemNotifier extends StateNotifier<AsyncValue<List<StockItem>>> {
  StockItemNotifier() : super(const AsyncValue.data(<StockItem>[]));

  Future<void> refresh(List<StockItem> items) async {
    state = AsyncValue.data(List<StockItem>.from(items));
  }

  Future<void> addStockItem(StockItem s) async {
    final current = state.value ?? const <StockItem>[];
    state = AsyncValue.data([...current, s]);
  }
}

/// ======================
///  Riverpod Providers
/// ======================

final warehousesProvider =
    StateNotifierProvider<WarehouseNotifier, AsyncValue<List<Warehouse>>>(
  (ref) => WarehouseNotifier(),
);

final transportTasksProvider = StateNotifierProvider<TransportTaskNotifier,
    AsyncValue<List<TransportTask>>>(
  (ref) => TransportTaskNotifier(),
);

final stockItemsProvider =
    StateNotifierProvider<StockItemNotifier, AsyncValue<List<StockItem>>>(
  (ref) => StockItemNotifier(),
);

final categoriesListProvider =
    FutureProvider<List<Category>>((ref) => fetchCategories());

final customersListProvider =
    FutureProvider<List<Customer>>((ref) => fetchCustomers());

final distributionCentersListProvider =
    FutureProvider<List<DistributionCenter>>(
        (ref) => fetchDistributionCenters());

final employeesListProvider =
    FutureProvider<List<Employee>>((ref) => fetchEmployees());

final garageItemsListProvider =
    FutureProvider<List<GarageItem>>((ref) => fetchGarageItems());

final invoicesListProvider =
    FutureProvider<List<Invoice>>((ref) => fetchInvoices());

final productsListProvider =
    FutureProvider<List<Product>>((ref) => fetchProducts());

final specializationsListProvider =
    FutureProvider<List<Specialization>>((ref) => fetchSpecializations());

final suppliersListProvider =
    FutureProvider<List<Supplier>>((ref) => fetchSuppliers());

final vehiclesListProvider =
    FutureProvider<List<Vehicle>>((ref) => fetchVehicles());

/// البحث عن مستودع بالـ id (String) — يعتمد على warehousesProvider
final warehouseByIdProvider =
    Provider.family<AsyncValue<Warehouse?>, String>((ref, warehouseId) {
  final warehousesAsync = ref.watch(warehousesProvider);
  return warehousesAsync.when(
    data: (ws) {
      try {
        return AsyncValue.data(ws.firstWhere((w) => w.id == warehouseId));
      } catch (_) {
        return const AsyncValue.data(null);
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (err, st) => AsyncValue.error(err, st),
  );
});

/// عناصر المخزون حسب المستودع — تعتمد على stockItemsProvider
final stockItemsByWarehouseProvider =
    Provider.family<AsyncValue<List<StockItem>>, String>((ref, warehouseId) {
  final stockAsync = ref.watch(stockItemsProvider);
  return stockAsync.whenData(
    (items) => items.where((it) => it.warehouseId == warehouseId).toList(),
  );
});

/// تبسيط: نرجع قائمة فاضية — يمكن لاحقًا احتسابها من stockItems/products/categories
final categoriesInWarehouseProvider =
    Provider.family<AsyncValue<List<Category>>, String>((ref, warehouseId) {
  return const AsyncValue.data(<Category>[]);
});

final stockItemsByWarehouseAndProductProvider =
    Provider.family<AsyncValue<List<StockItem>>, Map<String, String>>(
        (ref, params) {
  final warehouseId = params['warehouseId']!;
  final productId = params['productId']!;
  final stockAsync = ref.watch(stockItemsByWarehouseProvider(warehouseId));
  return stockAsync.whenData(
    (items) => items.where((it) => it.productId == productId).toList(),
  );
});

/// منتج بالـ id اعتمادًا على productProvider لديك
final productByIdProvider =
    Provider.family<AsyncValue<Product>, String>((ref, id) {
  final products = ref.watch(productProvider);
  try {
    final product = products.firstWhere((p) => p.id == id);
    return AsyncValue.data(product);
  } catch (_) {
    return AsyncValue.error('المنتج غير موجود', StackTrace.current);
  }
});

/// إحصائيات/عدادات مبسّطة تعمل حتى على قوائم فاضية:

final overdueTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasks = ref.watch(transportTasksProvider);
  return tasks.whenData((list) =>
      list.where((t) => t.status == TransportTaskStatus.delayed).length);
});

final totalTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasks = ref.watch(transportTasksProvider);
  return tasks.whenData((list) => list.length);
});

final availableVehiclesCountProvider = Provider<AsyncValue<int>>((ref) {
  final vehicles = ref.watch(vehiclesListProvider);
  return vehicles.whenData(
      (list) => list.where((v) => v.status == VehicleStatus.available).length);
});

final pendingInvoicesCountProvider = Provider<AsyncValue<int>>((ref) {
  final invoices = ref.watch(invoicesListProvider);
  return invoices.whenData(
      (list) => list.where((i) => i.status == InvoiceStatus.pending).length);
});

final totalWarehousesCountProvider = Provider<AsyncValue<int>>((ref) {
  final warehouses = ref.watch(warehousesProvider);
  return warehouses.whenData((list) => list.length);
});

final warehouseOccupancyProvider =
    Provider<AsyncValue<List<WarehouseOccupancyData>>>((ref) {
  final warehouses = ref.watch(warehousesProvider);
  return warehouses.whenData((list) {
    return list.map((w) => WarehouseOccupancyData(w.name)).toList();
  });
});

class WarehouseOccupancyData {
  final String name;
  WarehouseOccupancyData(this.name);
}
