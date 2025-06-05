import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart'; // تأكد من إضافة حزمة uuid إلى pubspec.yaml

// استبدل 'warehouse' باسم الحزمة الفعلي من pubspec.yaml
// تأكد من تطابق أسماء هذه الملفات تمامًا مع مجلد النماذج الخاص بك:
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
import 'package:warehouse/providers/product_provider.dart';

// --- Initial Mock Data Lists ---
final Uuid uuid = Uuid();

final List<Category> _mockCategories = [
  Category(id: uuid.v4(), name: "معدات"),
  Category(id: uuid.v4(), name: "ملحقات"),
  Category(id: uuid.v4(), name: "قطع غيار"),
  Category(id: uuid.v4(), name: "أجهزة"),
  Category(id: uuid.v4(), name: "أثاث"),
];

final List<Customer> _mockCustomers = [
  Customer(
      id: uuid.v4(),
      name: "شركة الخليج",
      contactPerson: "اسم1",
      phoneNumber: "0551234567",
      address: "عنوان1",
      invoiceIds: [],
      contact: "اسم1 - 0551234567"), // دمج contactPerson و phoneNumber
  Customer(
      id: uuid.v4(),
      name: "شركة النور",
      contactPerson: "اسم2",
      phoneNumber: "0549876543",
      address: "عنوان2",
      invoiceIds: [],
      contact: "اسم2 - 0549876543"),
  Customer(
      id: uuid.v4(),
      name: "مؤسسة الأمل",
      contactPerson: "اسم3",
      phoneNumber: "0501112222",
      address: "عنوان3",
      invoiceIds: [],
      contact: "اسم3 - 0501112222"),
];

final List<DistributionCenter> _mockDistributionCenters = [
  DistributionCenter(id: uuid.v4(), name: "مركز الرياض", address: "الرياض"),
  DistributionCenter(id: uuid.v4(), name: "مركز جدة", address: "جدة"),
  DistributionCenter(id: uuid.v4(), name: "مركز الدمام", address: "الدمام"),
];

final List<Employee> _mockEmployees = [
  Employee(id: uuid.v4(), name: "أحمد الزهراني", position: "مدير مستودع"),
  Employee(id: uuid.v4(), name: "سارة الحربي", position: "مسؤولة طلبات"),
  Employee(id: uuid.v4(), name: "خالد العتيبي", position: "سائق"),
  Employee(id: uuid.v4(), name: "ليلى الشمري", position: "محاسبة"),
];

final List<GarageItem> _mockGarageItems = [
  GarageItem(
      id: uuid.v4(),
      vehicleId: _mockVehicles.isNotEmpty
          ? _mockVehicles[1].id
          : "شاحنة 2", // استخدام ID فعلي إذا أمكن
      status: MaintenanceStatus.inProgress,
      reportedIssue: 'صوت غريب',
      startDate: DateTime.now().subtract(Duration(days: 3))),
  GarageItem(
      id: uuid.v4(),
      vehicleId: _mockVehicles.length > 4
          ? _mockVehicles[4].id
          : "شاحنة 5", // استخدام ID فعلي إذا أمكن
      status: MaintenanceStatus.scheduled,
      reportedIssue: 'فحص دوري',
      startDate: DateTime.now().add(Duration(days: 1))),
];

final List<Invoice> _mockInvoices = [
  Invoice(
      id: uuid.v4(),
      number: "#INV1001",
      status: InvoiceStatus.pending,
      amount: 320.5, // يفترض أن يكون هذا هو الإجمالي، أو قم بتسميته subtotal
      type: InvoiceType.sale,
      entityId: _mockCustomers.isNotEmpty
          ? _mockCustomers[0].id
          : 'c1', // استخدام ID فعلي
      issueDate: DateTime.now().subtract(Duration(days: 10)),
      items: [], // يجب أن تحتوي على InvoiceItem إذا كان amount لا يمثل الإجمالي
      totalAmount:
          320.5), // إذا كان amount هو الإجمالي، اجعل totalAmount نفس القيمة
  Invoice(
      id: uuid.v4(),
      number: "#INV1002",
      status: InvoiceStatus.paid,
      amount: 200.0,
      type: InvoiceType.purchase,
      entityId: _mockSuppliers.isNotEmpty
          ? _mockSuppliers[0].id
          : 'sup1', // استخدام ID فعلي
      issueDate: DateTime.now().subtract(Duration(days: 20)),
      paymentDate: DateTime.now().subtract(Duration(days: 15)),
      items: [],
      totalAmount: 200.0),
  Invoice(
      id: uuid.v4(),
      number: "#INV1003",
      status: InvoiceStatus.overdue,
      amount: 550.0,
      type: InvoiceType.sale,
      entityId: _mockCustomers.length > 1
          ? _mockCustomers[1].id
          : 'c2', // استخدام ID فعلي
      issueDate: DateTime.now().subtract(Duration(days: 35)),
      dueDate: DateTime.now().subtract(Duration(days: 5)),
      items: [],
      totalAmount: 550.0),
  Invoice(
      id: uuid.v4(),
      number: "#INV1004",
      status: InvoiceStatus.paid,
      amount: 120.0,
      type: InvoiceType.sale,
      entityId: _mockCustomers.length > 2
          ? _mockCustomers[2].id
          : 'c3', // استخدام ID فعلي
      issueDate: DateTime.now().subtract(Duration(days: 5)),
      paymentDate: DateTime.now().subtract(Duration(days: 1)),
      items: [],
      totalAmount: 120.0),
];

final List<Product> _mockProducts = [];

final List<Specialization> _mockSpecializations = [
  Specialization(id: uuid.v4(), name: "إدارة المستودع", title: "مدير مستودع"),
  Specialization(id: uuid.v4(), name: "توزيع", title: "مسؤول توزيع"),
  Specialization(id: uuid.v4(), name: "مراقبة جودة", title: "مراقب جودة"),
  Specialization(
      id: uuid.v4(), name: "تشغيل رافعات شوكية", title: "مشغل رافعة"),
];

final List<Supplier> _mockSuppliers = [
  Supplier(
      id: uuid.v4(),
      name: "مؤسسة التوريد الشامل",
      contactPerson: "كونتاكت 1",
      phoneNumber: '111222333',
      address: 'عنوان مورد 1',
      paymentTerms: 'Net 30',
      contact: "كونتاكت 1 - 111222333"),
  Supplier(
      id: uuid.v4(),
      name: "مورد الأجهزة الذكية",
      contactPerson: "كونتاكت 2",
      phoneNumber: '444555666',
      address: 'عنوان مورد 2',
      paymentTerms: 'Net 60',
      contact: "كونتاكت 2 - 444555666"),
  Supplier(
      id: uuid.v4(),
      name: "شركة الإمداد السريع",
      contactPerson: "كونتاكت 3",
      phoneNumber: '777888999',
      address: 'عنوان مورد 3',
      paymentTerms: 'Due on Receipt',
      contact: "كونتاكت 3 - 777888999"),
];

final List<Vehicle> _mockVehicles = [
  Vehicle(
      id: uuid.v4(), // شاحنة 1
      status: VehicleStatus.available,
      licensePlate: 'ABC-111',
      model: 'Truck A',
      capacity: 10000,
      capacityUnit: 'kg'),
  Vehicle(
      id: uuid.v4(), // شاحنة 2
      status: VehicleStatus.underMaintenance,
      licensePlate: 'XYZ-222',
      model: 'Van B',
      capacity: 2000,
      capacityUnit: 'kg'),
  Vehicle(
      id: uuid.v4(), // شاحنة 3
      status: VehicleStatus.inTransit,
      licensePlate: 'JKL-333',
      model: 'Truck C',
      capacity: 10000,
      capacityUnit: 'kg'),
  Vehicle(
      id: uuid.v4(), // شاحنة 4
      status: VehicleStatus.available,
      licensePlate: 'MNO-444',
      model: 'Van D',
      capacity: 2000,
      capacityUnit: 'kg'),
  Vehicle(
      id: uuid.v4(), // شاحنة 5
      status: VehicleStatus.underMaintenance,
      licensePlate: 'QRS-555',
      model: 'Forklift E',
      capacity: 2000,
      capacityUnit: 'kg'),
];

final List<Warehouse> _initialMockWarehouses = [
  Warehouse(
      id: uuid.v4(), // w1
      name: "المستودع الرئيسي",
      address: 'عنوان المستودع الرئيسي',
      capacity: 1000,
      capacityUnit: 'm³', // تغيير إلى m³ ليتوافق مع وحدة سعة النموذج
      occupied: 650,
      productIds: null,
      location: '',
      used: 1,
      manager: '',
      usedCapacity: null),
  Warehouse(
      id: uuid.v4(), // w2
      name: "مستودع الجنوب",
      address: 'عنوان مستودع الجنوب',
      capacity: 500,
      capacityUnit: 'm³',
      occupied: 400,
      productIds: null,
      location: '',
      used: 1,
      manager: '',
      usedCapacity: null),
  Warehouse(
      id: uuid.v4(), // w3
      name: "مستودع الشمال",
      address: 'عنوان مستودع الشمال',
      capacity: 750,
      capacityUnit: 'm³',
      occupied: 700,
      productIds: null,
      location: '',
      used: 1,
      manager: '',
      usedCapacity: null),
];

final List<TransportTask> _initialMockTransportTasks = [
  TransportTask(
      id: uuid.v4(),
      taskIdNumber: "T-001",
      status: TransportTaskStatus.completed,
      fromLocation: _initialMockWarehouses[0].name, // استخدام اسم المستودع
      toLocation: _mockDistributionCenters[0].name, // استخدام اسم المركز
      vehicleId: _mockVehicles[0].id, // استخدام ID فعلي
      driverId: _mockEmployees[2].id, // استخدام ID فعلي
      scheduledStartTime: DateTime.now().subtract(Duration(days: 1)),
      itemsDescription: 'أجهزة إلكترونية',
      fromLocationId: _initialMockWarehouses[0].id,
      toLocationId: _mockDistributionCenters[0].id,
      items: []),
  TransportTask(
      id: uuid.v4(),
      taskIdNumber: "T-002",
      status: TransportTaskStatus.delayed,
      fromLocation: _initialMockWarehouses[1].name,
      toLocation: _mockCustomers[0].name, // التسليم لزبون
      vehicleId: _mockVehicles[2].id,
      driverId: _mockEmployees[2].id,
      scheduledStartTime: DateTime.now().subtract(Duration(hours: 5)),
      itemsDescription: 'أثاث مكتبي',
      fromLocationId: _initialMockWarehouses[1].id,
      toLocationId: _mockCustomers[0].id, // يمكن أن يكون Customer ID
      items: []),
  TransportTask(
      id: uuid.v4(),
      taskIdNumber: "T-003",
      status: TransportTaskStatus.scheduled,
      fromLocation: _mockDistributionCenters[1].name,
      toLocation: _initialMockWarehouses[2].name,
      vehicleId: _mockVehicles[3].id,
      driverId: _mockEmployees[2].id,
      scheduledStartTime: DateTime.now().add(Duration(hours: 2)),
      itemsDescription: 'قطع غيار',
      fromLocationId: _mockDistributionCenters[1].id,
      toLocationId: _initialMockWarehouses[2].id,
      items: []),
];

// تأكد من أن _mockProducts و _initialMockWarehouses معرفة قبل هذا
final List<StockItem> _initialMockStockItems =
    _initialMockWarehouses.isNotEmpty && _mockProducts.isNotEmpty
        ? [
            // Stock for Warehouse w1
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[0].id,
                productId: _mockProducts[0].id, // Laptop X1
                location: 'A1-Shelf 1',
                quantity: 15, // متوفر (minStockLevel: 10)
                expiryDate: null),
            StockItem(
                // منتج مختلف لنفس المستودع
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[0].id,
                productId: _mockProducts[1].id, // Office Chair
                location: 'A1-Shelf 2',
                quantity: 30, // متوفر (minStockLevel: 20)
                expiryDate: null),
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[0].id,
                productId: _mockProducts[2].id, // Product ABC
                location: 'B1-Area',
                quantity: 7, // منخفض (minStockLevel: 10)
                expiryDate: DateTime.now().add(Duration(days: 30))),
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[0].id,
                productId: _mockProducts[3].id, // Widget 4
                location: 'C1-Bin 5',
                quantity: 60, // متوفر (minStockLevel: 50)
                expiryDate: null),

            // Stock for Warehouse w2
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[1].id,
                productId: _mockProducts[1].id, // Office Chair
                location: 'A1-Area',
                quantity: 25, // متوفر (minStockLevel: 20)
                expiryDate: null),
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[1].id,
                productId: _mockProducts[4].id, // Thingamajig 5
                location: 'B1-Shelf 3',
                quantity: 8, // منخفض (minStockLevel: 10)
                expiryDate: DateTime.now().add(Duration(days: 90))),
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[1].id,
                productId: _mockProducts[5].id, // Another Item
                location: 'C1-Area',
                quantity: 0, // نافد (minStockLevel: 5)
                expiryDate: null),

            // Stock for Warehouse w3
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[2].id,
                productId: _mockProducts[0].id, // Laptop X1
                location: 'W3-A1',
                quantity: 5, // منخفض (minStockLevel: 10)
                expiryDate: null),
            StockItem(
                id: uuid.v4(),
                warehouseId: _initialMockWarehouses[2].id,
                productId: _mockProducts[3].id, // Widget 4
                location: 'W3-B2',
                quantity: 40, // منخفض (minStockLevel: 50)
                expiryDate: null),
          ]
        : [];

// --- Fetch Functions (Simulating Async Operations for FutureProviders) ---
Future<List<Category>> fetchCategories() async {
  await Future.delayed(const Duration(milliseconds: 500));
  return List.from(_mockCategories); // Return a copy
}

Future<List<Customer>> fetchCustomers() async {
  await Future.delayed(const Duration(milliseconds: 600));
  return List.from(_mockCustomers);
}

Future<List<DistributionCenter>> fetchDistributionCenters() async {
  await Future.delayed(const Duration(milliseconds: 700));
  return List.from(_mockDistributionCenters);
}

Future<List<Employee>> fetchEmployees() async {
  await Future.delayed(const Duration(milliseconds: 800));
  return List.from(_mockEmployees);
}

Future<List<GarageItem>> fetchGarageItems() async {
  await Future.delayed(const Duration(milliseconds: 400));
  return List.from(_mockGarageItems);
}

Future<List<Invoice>> fetchInvoices() async {
  await Future.delayed(const Duration(milliseconds: 750));
  return List.from(_mockInvoices);
}

Future<List<Product>> fetchProducts() async {
  await Future.delayed(const Duration(milliseconds: 650));
  return List.from(_mockProducts);
}

Future<List<Specialization>> fetchSpecializations() async {
  await Future.delayed(const Duration(milliseconds: 300));
  return List.from(_mockSpecializations);
}

Future<List<Supplier>> fetchSuppliers() async {
  await Future.delayed(const Duration(milliseconds: 550));
  return List.from(_mockSuppliers);
}

Future<List<Vehicle>> fetchVehicles() async {
  await Future.delayed(const Duration(milliseconds: 450));
  return List.from(_mockVehicles);
}

// --- StateNotifiers (for mutable lists) ---

class WarehouseNotifier extends StateNotifier<AsyncValue<List<Warehouse>>> {
  WarehouseNotifier() : super(const AsyncValue.loading()) {
    _fetchWarehouses();
  }
  Future<void> _fetchWarehouses() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      state = AsyncValue.data(List.from(_initialMockWarehouses));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addWarehouse(Warehouse newWarehouse) async {
    state.whenData((warehouses) async {
      // Make it async
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        state = AsyncValue.data([...warehouses, newWarehouse]);
      } catch (e, stack) {
        // Catch error during the async operation inside
        print("Error adding warehouse during state update: $e");
        // Optionally re-throw or set an error state if critical
        // state = AsyncValue.error(e, stack); // Example of setting error state
      }
    });
    // Handle cases where state is not data (e.g., loading or error)
    if (state is! AsyncData) {
      print(
          "Cannot add warehouse: current state is not data (${state.runtimeType})");
      // You might want to queue the operation or handle this error appropriately
    }
  }
}

class TransportTaskNotifier
    extends StateNotifier<AsyncValue<List<TransportTask>>> {
  TransportTaskNotifier() : super(const AsyncValue.loading()) {
    _fetchTasks();
  }
  Future<void> _fetchTasks() async {
    try {
      await Future.delayed(const Duration(milliseconds: 850));
      state = AsyncValue.data(List.from(_initialMockTransportTasks));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(TransportTask newTask) async {
    state.whenData((tasks) async {
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        state = AsyncValue.data([...tasks, newTask]);
      } catch (e, stack) {
        print("Error adding task during state update: $e");
      }
    });
    if (state is! AsyncData) {
      print(
          "Cannot add task: current state is not data (${state.runtimeType})");
    }
  }
}

class StockItemNotifier extends StateNotifier<AsyncValue<List<StockItem>>> {
  StockItemNotifier() : super(const AsyncValue.loading()) {
    _fetchStockItems();
  }
  Future<void> _fetchStockItems() async {
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      state = AsyncValue.data(List.from(_initialMockStockItems));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addStockItem(StockItem newStockItem) async {
    state.whenData((stockItems) async {
      try {
        await Future.delayed(const Duration(milliseconds: 300));
        state = AsyncValue.data([...stockItems, newStockItem]);
      } catch (e, stack) {
        print("Error adding stock item during state update: $e");
      }
    });
    if (state is! AsyncData) {
      print(
          "Cannot add stock item: current state is not data (${state.runtimeType})");
    }
  }
}

// --- Riverpod Providers ---

final warehousesProvider =
    StateNotifierProvider<WarehouseNotifier, AsyncValue<List<Warehouse>>>(
        (ref) => WarehouseNotifier());
final transportTasksProvider = StateNotifierProvider<TransportTaskNotifier,
    AsyncValue<List<TransportTask>>>((ref) => TransportTaskNotifier());
final stockItemsProvider =
    StateNotifierProvider<StockItemNotifier, AsyncValue<List<StockItem>>>(
        (ref) => StockItemNotifier());

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

final warehouseByIdProvider =
    Provider.family<AsyncValue<Warehouse?>, String>((ref, warehouseId) {
  final warehousesAsyncValue = ref.watch(warehousesProvider);
  return warehousesAsyncValue.when(
    data: (warehouses) {
      try {
        return AsyncValue.data(
            warehouses.firstWhere((w) => w.id == warehouseId));
      } catch (e) {
        return const AsyncValue.data(null); // Not found
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

final stockItemsByWarehouseProvider =
    Provider.family<AsyncValue<List<StockItem>>, String>((ref, warehouseId) {
  final stockItemsAsyncValue = ref.watch(stockItemsProvider);
  return stockItemsAsyncValue.whenData(
    (stockItems) =>
        stockItems.where((item) => item.warehouseId == warehouseId).toList(),
  );
});

final categoriesInWarehouseProvider =
    Provider.family<AsyncValue<List<Category>>, String>((ref, warehouseId) {
  final stockItemsAsyncValue =
      ref.watch(stockItemsByWarehouseProvider(warehouseId));
  final productsAsyncValue = ref.watch(productsListProvider);
  final categoriesAsyncValue = ref.watch(categoriesListProvider);

  // 1. Check for loading state
  if (stockItemsAsyncValue.isLoading ||
      productsAsyncValue.isLoading ||
      categoriesAsyncValue.isLoading) {
    return const AsyncValue.loading();
  }

  // 2. Check for error states
  Object? error;
  StackTrace? stackTrace;

  if (stockItemsAsyncValue.hasError) {
    error = stockItemsAsyncValue.error;
    stackTrace = stockItemsAsyncValue.stackTrace;
  } else if (productsAsyncValue.hasError) {
    error = productsAsyncValue.error;
    stackTrace = productsAsyncValue.stackTrace;
  } else if (categoriesAsyncValue.hasError) {
    error = categoriesAsyncValue.error;
    stackTrace = categoriesAsyncValue.stackTrace;
  }

  if (error != null) {
    return AsyncValue.error(error, stackTrace!);
  }

  // 3. If all have data
  if (stockItemsAsyncValue.hasValue &&
      productsAsyncValue.hasValue &&
      categoriesAsyncValue.hasValue) {
    try {
      final List<StockItem> stockItems = stockItemsAsyncValue.value!;
      final List<Product> allProducts = productsAsyncValue.value!;
      final List<Category> allCategories = categoriesAsyncValue.value!;

      final Set<String> productIdsInWarehouse =
          stockItems.map((item) => item.productId).toSet();
    } catch (e, s) {
      // Catch any processing errors
      return AsyncValue.error(e, s);
    }
  }
  // Fallback, should not be reached if logic is correct
  return const AsyncValue.loading(); // Or some other default error state
});

final stockItemsByWarehouseAndProductProvider =
    Provider.family<AsyncValue<List<StockItem>>, Map<String, String>>(
        (ref, params) {
  final warehouseId = params['warehouseId']!;
  final productId = params['productId']!;

  final stockItemsAsyncValue =
      ref.watch(stockItemsByWarehouseProvider(warehouseId));

  return stockItemsAsyncValue.whenData(
    (stockItems) =>
        stockItems.where((item) => item.productId == productId).toList(),
  );
});

final productByIdProvider =
    Provider.family<AsyncValue<Product>, String>((ref, id) {
  final products = ref.watch(productProvider);
  final product = products.firstWhere(
    (p) => p.id == id,
    // orElse: () => null,
  );

  if (product == null) {
    return AsyncValue.error("المنتج غير موجود", StackTrace.current);
  }

  return AsyncValue.data(product);
});

final stockItemByIdProvider =
    Provider.family<AsyncValue<StockItem?>, String>((ref, stockItemId) {
  final stockItemsAsyncValue = ref.watch(stockItemsProvider);
  return stockItemsAsyncValue.when(
    data: (stockItems) {
      try {
        return AsyncValue.data(
            stockItems.firstWhere((item) => item.id == stockItemId));
      } catch (e) {
        return const AsyncValue.data(null); // Not found
      }
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Fallback

final overdueTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasksAsyncValue = ref.watch(transportTasksProvider);
  return tasksAsyncValue.whenData(
    (tasks) => tasks
        .where((task) => task.status == TransportTaskStatus.delayed)
        .length,
  );
});

final totalTasksCountProvider = Provider<AsyncValue<int>>((ref) {
  final tasksAsyncValue = ref.watch(transportTasksProvider);
  return tasksAsyncValue.whenData(
    (tasks) => tasks.length,
  );
});

final availableVehiclesCountProvider = Provider<AsyncValue<int>>((ref) {
  final vehiclesAsyncValue = ref.watch(vehiclesListProvider);
  return vehiclesAsyncValue.whenData(
    (vehicles) =>
        vehicles.where((v) => v.status == VehicleStatus.available).length,
  );
});

final pendingInvoicesCountProvider = Provider<AsyncValue<int>>((ref) {
  final invoicesAsyncValue = ref.watch(invoicesListProvider);
  return invoicesAsyncValue.whenData(
    (invoices) =>
        invoices.where((inv) => inv.status == InvoiceStatus.pending).length,
  );
});

final totalWarehousesCountProvider = Provider<AsyncValue<int>>((ref) {
  final warehousesAsyncValue = ref.watch(warehousesProvider);
  return warehousesAsyncValue.whenData(
    (warehouses) => warehouses.length,
  );
});

final warehouseOccupancyProvider =
    Provider<AsyncValue<List<WarehouseOccupancyData>>>((ref) {
  final warehousesAsyncValue = ref.watch(warehousesProvider);
  return warehousesAsyncValue.whenData((warehouses) {
    List<WarehouseOccupancyData> occupancyData = [];
    if (warehouses.isEmpty) return occupancyData;

    for (var w in warehouses) {
      occupancyData
          .add(WarehouseOccupancyData(w.name, (w.usageRate * 100).round()));
    }
    return occupancyData;
  });
});

class WarehouseOccupancyData {
  final String name;
  final int percentage;

  WarehouseOccupancyData(this.name, this.percentage);
}
