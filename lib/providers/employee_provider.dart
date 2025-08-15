import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';
import 'package:warehouse/widgets/Dialogs/add_product_type_dialog.dart';

// مزود الموظفين لجميع الموظفين
final allEmployeesProvider = FutureProvider<List<Employee>>((ref) async {
  final api = ref.read(apiServiceProvider);
  return await api.getAllEmployees();
});
// مزود الموظفين لمستودع محدد
final employeesOfWarehouseProvider =
    FutureProvider.family<List<Employee>, String>((ref, warehouseId) async {
  final api = ref.read(apiServiceProvider);
  return await api.getEmployeesByWarehouse(warehouseId);
});
