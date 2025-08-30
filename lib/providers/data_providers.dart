// lib/providers/data_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/imported_vehicle_info.dart';
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/models/pending_product_import.dart';
import 'package:warehouse/models/pending_vehicle_import.dart';
import 'package:warehouse/models/storage_media.dart';
import 'package:warehouse/models/unified_pending_operation.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/services/distribution_center_api.dart';
import 'package:warehouse/services/garage_api.dart';
import 'package:warehouse/services/import_api.dart';

// services
import 'package:warehouse/services/product_api.dart'; // <-- استيراد جديد

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
import 'package:warehouse/services/suppliers_api.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

// ======================
//  Providers
// ======================

/// ======================
///  Fetch (بدون Mock)
/// ======================
/// مبدئيًا: نعطي قوائم فاضية. لاحقًا يمكن ربط كل واحدة بخدمة API مناسبة.

Future<List<Category>> fetchCategories() async {
  return const <Category>[];
}

Future<List<Customer>> fetchCustomers() async {
  return const <Customer>[];
}

Future<List<DistributionCenter>> fetchDistributionCenters() async {
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
///  State Notifiers
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
///  Riverpod Providers
/// ======================

final warehousesProvider =
    FutureProvider<List<Warehouse>>((ref) => WarehouseApi.fetchAllWarehouses());

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
        (ref) => DistributionCenterApi.fetchAllDistributionCenters());

final employeesListProvider =
    FutureProvider<List<Employee>>((ref) => fetchEmployees());

// final garageItemsListProvider =
//     FutureProvider<List<GarageItem>>((ref) => GarageApi.fetchAllGarages());

final invoicesListProvider =
    FutureProvider<List<Invoice>>((ref) => fetchInvoices());

final productsListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  try {
    // استدعاء endpoint show_products مباشرة عبر ProductApi
    final products = await ProductApi.fetchAllProducts();
    return products;
  } catch (e) {
    // في حال فشل الاتصال بالخادم، نحاول استخدام المنتجات
    // المخزنة في productProvider. إذا لم تكن موجودة، نحاول تحميلها من الخلفية.
    try {
      final notifier = ref.read(productProvider.notifier);
      if (ref.read(productProvider).isEmpty) {
        await notifier.loadFromBackend();
      }
      return List<Product>.from(ref.read(productProvider));
    } catch (_) {
      return const <Product>[];
    }
  }
});
final specializationsListProvider =
    FutureProvider<List<Specialization>>((ref) => fetchSpecializations());

// final suppliersListProvider =
//     FutureProvider<List<Supplier>>((ref) => fetchSuppliers());

// final vehiclesListProvider =
//     FutureProvider<List<Vehicle>>((ref) => fetchVehicles());

final importItemsProvider =
    StateProvider.autoDispose<List<Map<String, dynamic>>>((ref) => []);

// --- Providers for Wizard Steps (Corrected) ---

// final warehousesForMediaProvider =
//     FutureProvider.autoDispose.family<List<Warehouse>, int>((ref, storageMediaId) {
//   return ImportApi.fetchWarehousesForMedia(storageMediaId);
// });

// // ✅ --- تصحيح Sections Provider لاستخدام Tuple ---
// final sectionsForPlaceProvider = FutureProvider.autoDispose
//     .family<List<WarehouseSection>, (int, String, int)>((ref, params) {

//   ref.keepAlive(); // منع إعادة الطلب عند كل rebuild

//   final int storageMediaId = params.$1;
//   final String placeType = params.$2;
//   final int placeId = params.$3;
//   return ImportApi.fetchSectionsForPlace(storageMediaId, placeType, placeId);
// });

/// البحث عن مستودع بالـ id (String) — يعتمد على warehousesProvider
final warehouseByIdProvider =
    Provider.family<AsyncValue<Warehouse?>, String>((ref, warehouseId) {
  final warehousesAsync = ref.watch(warehousesProvider);
  return warehousesAsync.when(
    data: (ws) {
      try {
        return AsyncValue.data(
            ws.firstWhere((w) => w.id.toString() == warehouseId));
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
    (items) =>
        items.where((it) => it.warehouseId.toString() == warehouseId).toList(),
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
    (items) =>
        items.where((it) => it.productId.toString() == productId).toList(),
  );
});

/// منتج بالـ id اعتمادًا على productProvider لديك
final productByIdProvider =
    Provider.family<AsyncValue<Product>, String>((ref, id) {
  final products = ref.watch(productProvider);
  try {
    final product = products.firstWhere((p) => p.id.toString() == id);
    return AsyncValue.data(product);
  } catch (_) {
    return AsyncValue.error('المنتج غير موجود', StackTrace.current);
  }
});

/// إحصائيات/عدادات مبسّطة تعمل حتى على قوائم فاضية:

final overdueTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasks = ref.watch(transportTasksProvider);
  return tasks
      .whenData((list) => list.where((t) => t.status == 'delayed').length);
});

final totalTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasks = ref.watch(transportTasksProvider);
  return tasks.whenData((list) => list.length);
});

final availableVehiclesCountProvider = Provider<AsyncValue<int>>((ref) {
  final vehicles = ref.read(vehiclesListProvider);
  return vehicles
      .whenData((list) => list.where((v) => v.status == 'available').length);
});

final pendingInvoicesCountProvider = Provider<AsyncValue<int>>((ref) {
  final invoices = ref.watch(invoicesListProvider);
  return invoices
      .whenData((list) => list.where((i) => i.status == 'pending').length);
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
// final garageItemsByPlaceProvider =
//     FutureProvider.family<List<GarageItem>, Map<String, dynamic>>(
//         (ref, params) {
//   final String placeType = params['placeType'] as String;
//   final int placeId = params['placeId'] as int;
//   return GarageApi.fetchGaragesForPlace(placeType, placeId);
// });

@immutable
class PlaceParameter {
  final String placeType;
  final int placeId;

  const PlaceParameter({required this.placeType, required this.placeId});

  //重写 == 和 hashCode ليتأكد Riverpod من أن الكائنين متطابقان
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceParameter &&
          runtimeType == other.runtimeType &&
          placeType == other.placeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeType.hashCode ^ placeId.hashCode;
}

// --- 2. تحديث الـ Provider ليستخدم الكلاس الجديد ---
// استخدام .autoDispose لحذف البيانات عند الخروج من الشاشة (ممارسة جيدة)
final productsByPlaceProvider = FutureProvider.autoDispose
    .family<List<Product>, PlaceParameter>((ref, params) {
  // نحافظ على الحالة حتى لا يتم التخلص منها فور خروج المستخدم من الشاشة
  ref.keepAlive();
  return ProductApi.fetchProductsForPlace(params.placeType, params.placeId);
});
final suppliersListProvider = FutureProvider.autoDispose<List<Supplier>>((ref) {
  return SuppliersApi.fetchSuppliers();
});

/// Provider لجلب منتجات مورد معين
final supplierProductsProvider =
    FutureProvider.autoDispose.family<List<Product>, int>((ref, supplierId) {
  return SuppliersApi.fetchProductsForSupplier(supplierId);
});
final pendingImportsProvider =
    FutureProvider.autoDispose<List<PendingImportOperation>>((ref) {
  return ImportApi.fetchPendingImportOperations();
});

/// Provider لجلب قائمة جميع وسائط التخزين (الخطوة الأولى)
final storageMediaListProvider =
    FutureProvider.autoDispose<List<StorageMedia>>((ref) {
  return ImportApi.fetchStorageMedia();
});

/// Provider لجلب الموردين لوسيط تخزين معين (الخطوة الثانية)
final suppliersForMediaProvider = FutureProvider.autoDispose
    .family<List<Supplier>, int>((ref, storageMediaId) {
  return ImportApi.fetchSuppliersForMedia(storageMediaId);
});

/// Provider لجلب المستودعات لوسيط تخزين معين (الخطوة الثالثة)
final warehousesForMediaProvider = FutureProvider.autoDispose
    .family<List<Warehouse>, int>((ref, storageMediaId) {
  return ImportApi.fetchWarehousesForMedia(storageMediaId);
});

/// Provider لجلب قائمة جميع وسائط التخزين (الخطوة الأولى)

// --- Providers جديدة للخطوة الرابعة ---

final supplierStorageMediaProvider = FutureProvider.autoDispose
    .family<List<StorageMedia>, int>((ref, supplierId) {
  return SuppliersApi.fetchStorageMediaForSupplier(supplierId);
});
final sectionsForPlaceProvider = FutureProvider.autoDispose
    .family<List<WarehouseSection>, (int, String, int)>((ref, params) {
  // ✅ ---  هنا التعديل ---
  // أخبر الـ Provider أن يحتفظ بالحالة ولا يعيد الطلب عند كل rebuild
  ref.keepAlive();

  final (mediaId, placeType, placeId) = params;
  return ImportApi.fetchSectionsForPlace(mediaId, placeType, placeId);
});

/// Provider لجلب مراكز التوزيع لمستودع معين
final distributionCentersForWarehouseProvider = FutureProvider.autoDispose
    .family<List<DistributionCenter>, (int warehouseId, int mediaId)>(
        (ref, params) {
  // ✅ ---  وهنا أيضًا ---
  ref.keepAlive();

  final (warehouseId, mediaId) = params;
  return ImportApi.fetchDistributionCentersForWarehouse(warehouseId, mediaId);
});

// Provider لإدارة حالة عملية الاستيراد التي يتم بناؤها
final productImportWizardProvider = StateNotifierProvider.autoDispose<
    ProductImportNotifier,
    List<ImportedProductInfo>>((ref) => ProductImportNotifier());

// Provider لجلب قائمة المنتجات لمورد معين
final productsForSupplierProvider =
    FutureProvider.autoDispose.family<List<Product>, int>((ref, supplierId) {
  return SuppliersApi.fetchProductsForSupplier(supplierId);
});

// Provider لجلب المستودعات المتوافقة مع منتج معين
final warehousesForProductProvider =
    FutureProvider.autoDispose.family<List<Warehouse>, int>((ref, productId) {
  return ImportApi.fetchWarehousesForProduct(productId);
});

// ✅ --- State Notifier لإدارة الحالة المعقدة للمعالج ---
class ProductImportNotifier extends StateNotifier<List<ImportedProductInfo>> {
  ProductImportNotifier() : super([]);

  // إضافة منتج جديد إلى القائمة
  void addProduct(Product product, List<Warehouse> compatibleWarehouses) {
    state = [
      ...state,
      ImportedProductInfo(
        product: product,
        // إنشاء قائمة توزيع فارغة لكل مستودع متوافق
        distribution: compatibleWarehouses
            .map((wh) => ProductDistributionInfo(warehouse: wh))
            .toList(),
      )
    ];
  }

  // إزالة منتج من القائمة
  void removeProduct(int productId) {
    state = state.where((p) => p.product.id != productId).toList();
  }

  void clearProducts() {
    state = [];
  }

  // تحديث بيانات منتج معين
  void updateProduct(ImportedProductInfo updatedProduct) {
    state = [
      for (final p in state)
        if (p.product.id == updatedProduct.product.id) updatedProduct else p,
    ];
  }
}

final pendingProductImportsProvider =
    FutureProvider.autoDispose<List<PendingProductImport>>((ref) {
  return ImportApi.fetchPendingProductImports();
});

// ✅ --- StateNotifier جديد لإدارة قائمة العمليات المدمجة ---
// class AllPendingOperationsNotifier
//     extends StateNotifier<AsyncValue<List<UnifiedPendingOperation>>> {
//   final Ref _ref;

//   AllPendingOperationsNotifier(this._ref) : super(const AsyncValue.loading()) {
//     fetchOperations();
//   }

//   Future<void> fetchOperations() async {
//     state = const AsyncValue.loading();
//     try {
//       List<PendingImportOperation> storageMediaOps = [];
//       List<PendingProductImport> productOps = [];
//       final combinedList = <UnifiedPendingOperation>[];

//       // جلب العمليات الأولى (وسائط التخزين)
//       try {
//         storageMediaOps = await ImportApi.fetchPendingImportOperations();
//         combinedList
//             .addAll(storageMediaOps.map((op) => StorageMediaOperation(op)));
//       } catch (e) {
//         debugPrint('Error fetching storage media imports: $e');
//       }

//       // جلب العمليات الثانية (المنتجات)
//       try {
//         productOps = await ImportApi.fetchPendingProductImports();
//         combinedList.addAll(productOps.map((op) => ProductOperation(op)));
//       } catch (e) {
//         debugPrint('Error fetching product imports: $e');
//       }

//       state = AsyncValue.data(combinedList);
//     } catch (e, s) {
//       // هذا الـ catch سيتم استخدامه فقط في حالات الفشل غير المتوقعة
//       state = AsyncValue.error(e, s);
//     }
//   }

//   // ✅ --- دالة لإزالة عملية من القائمة بشكل فوري ---
//   void removeOperation(UnifiedPendingOperation operationToRemove) {
//     state.whenData((operations) {
//       final newList = List<UnifiedPendingOperation>.from(operations);

//       String keyToRemove;
//       if (operationToRemove is StorageMediaOperation) {
//         keyToRemove = operationToRemove.operation.importOperationKey;
//         newList.removeWhere((op) =>
//             op is StorageMediaOperation &&
//             op.operation.importOperationKey == keyToRemove);
//       } else if (operationToRemove is ProductOperation) {
//         keyToRemove = operationToRemove.operation.importOperationKey;
//         newList.removeWhere((op) =>
//             op is ProductOperation &&
//             op.operation.importOperationKey == keyToRemove);
//       }

//       state = AsyncValue.data(newList);
//     });
//   }
// }

// ✅ --- استبدال الـ Provider القديم بالجديد ---
final allPendingOperationsProvider = StateNotifierProvider.autoDispose<
    AllPendingOperationsNotifier, AsyncValue<List<UnifiedPendingOperation>>>(
  (ref) {
    return AllPendingOperationsNotifier(ref);
  },
);
final pendingVehicleImportsProvider =
    FutureProvider.autoDispose<List<PendingVehicleImport>>((ref) {
  return ImportApi.fetchPendingVehicleImports();
});

// ... (بقية الـ providers)

// lib/providers/data_providers.dart
// ... (الكود الموجود)
class AllPendingOperationsNotifier
    extends StateNotifier<AsyncValue<List<UnifiedPendingOperation>>> {
  final Ref _ref;

  AllPendingOperationsNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchOperations();
  }

  Future<void> fetchOperations() async {
    state = const AsyncValue.loading();
    try {
      final storageMediaFuture = _ref.read(pendingImportsProvider.future);
      final productFuture = _ref.read(pendingProductImportsProvider.future);
      final vehicleFuture = _ref.read(pendingVehicleImportsProvider.future);

      final results = await Future.wait([
        storageMediaFuture,
        productFuture,
        vehicleFuture,
      ]);

      final storageMediaOps = results[0] as List<PendingImportOperation>;
      final productOps = results[1] as List<PendingProductImport>;
      final vehicleOps = results[2] as List<PendingVehicleImport>;

      final List<UnifiedPendingOperation> combinedList = [];
      combinedList
          .addAll(storageMediaOps.map((op) => StorageMediaOperation(op)));
      combinedList.addAll(productOps.map((op) => ProductOperation(op)));
      combinedList.addAll(vehicleOps.map((op) => VehicleOperation(op)));

      state = AsyncValue.data(combinedList);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // ✅ --- دالة لإزالة عملية من القائمة بشكل فوري ---
  void removeOperation(UnifiedPendingOperation operationToRemove) {
    state.whenData((operations) {
      final newList = List<UnifiedPendingOperation>.from(operations);

      String keyToRemove;
      if (operationToRemove is StorageMediaOperation) {
        keyToRemove = operationToRemove.operation.importOperationKey;
        newList.removeWhere((op) =>
            op is StorageMediaOperation &&
            op.operation.importOperationKey == keyToRemove);
      } else if (operationToRemove is ProductOperation) {
        keyToRemove = operationToRemove.operation.importOperationKey;
        newList.removeWhere((op) =>
            op is ProductOperation &&
            op.operation.importOperationKey == keyToRemove);
      }

      state = AsyncValue.data(newList);
    });
  }
}

final vehicleImportWizardProvider = StateNotifierProvider.autoDispose<
    VehicleImportWizardNotifier,
    List<ImportedVehicleInfo>>((ref) => VehicleImportWizardNotifier());

class VehicleImportWizardNotifier
    extends StateNotifier<List<ImportedVehicleInfo>> {
  VehicleImportWizardNotifier() : super([]);

  void addVehicle(ImportedVehicleInfo vehicle) {
    state = [...state, vehicle];
  }

  void removeVehicle(ImportedVehicleInfo vehicle) {
    state = state.where((v) => v != vehicle).toList();
  }

  void updateVehicle(
      ImportedVehicleInfo oldVehicle, ImportedVehicleInfo newVehicle) {
    state = [
      for (final vehicle in state)
        if (vehicle == oldVehicle) newVehicle else vehicle,
    ];
  }

  void clear() {
    state = [];
  }
}

int garageId = garageId;
// ✅ مزود جديد لجلب كل المركبات
final vehiclesListProvider =
    FutureProvider.autoDispose<List<Vehicle>>((ref) async {
  return GarageApi.fetchVehiclesInGarage(garageId);
});

// ✅ مزود جديد لجلب الجراجات ومراكز التوزيع
final placesListProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final warehouses = await ref.watch(warehousesProvider.future);
  final distributionCenters =
      await ref.watch(distributionCentersListProvider.future);
  return [...warehouses, ...distributionCenters];
});

class GarageParameter {
  final String placeType;
  final int placeId;

  const GarageParameter({required this.placeType, required this.placeId});

  // Riverpod يستخدم هاتين الدالتين للمقارنة حسب القيمة
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GarageParameter &&
          runtimeType == other.runtimeType &&
          placeType == other.placeType &&
          placeId == other.placeId;

  @override
  int get hashCode => placeType.hashCode ^ placeId.hashCode;
}

final garageItemsListProvider =
    FutureProvider.autoDispose<List<GarageItem>>((ref) {
  return GarageApi.fetchAllGarages();
});

// ✅ --- 2. تحديث الـ Provider ليستخدم الكلاس الجديد بدلاً من Map ---
final garageItemsByPlaceProvider = FutureProvider.autoDispose
    .family<List<GarageItem>, GarageParameter>((ref, params) {
  // استخدام keepAlive يمنع إعادة التحميل عند التنقل السريع بين الشاشات
  ref.keepAlive();
  return GarageApi.fetchGaragesForPlace(params.placeType, params.placeId);
});

class WarehouseOccupancyData {
  final String name;
  WarehouseOccupancyData(this.name);
}
