// lib/providers/employees_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/providers/api_service_provider.dart'; // ✅ مهم
// احذف هذا الاستيراد لأنه غير مستخدم هنا:
// import 'package:warehouse/widgets/Dialogs/add_product_type_dialog.dart';

/// جميع الموظفين (مفلترة ومسطّحة من استجابة الباك)
final allEmployeesProvider = FutureProvider<List<Employee>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getAllEmployees();
});

/// موظفو مستودع محدد
final employeesOfWarehouseProvider =
    FutureProvider.family<List<Employee>, String>((ref, warehouseId) async {
  final api = ref.read(apiServiceProvider);
  return await api.getEmployeesByWarehouse(warehouseId);
});
// موظفو تخصص معيّن
final employeesOfSpecProvider =
    FutureProvider.family<List<Employee>, int>((ref, specId) async {
  final api = ref.read(apiServiceProvider);
  return await api.getEmployeesBySpecialization(specId);
});
