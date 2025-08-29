// lib/models/pending_vehicle_import.dart
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/vehicle.dart';

class PendingVehicleImport {
  final String importOperationKey;
  final String vehiclesKey;
  final Supplier supplier;
  final String location;
  final double latitude;
  final double longitude;
  final List<Vehicle> vehicles;

  PendingVehicleImport({
    required this.importOperationKey,
    required this.vehiclesKey,
    required this.supplier,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.vehicles,
  });

  factory PendingVehicleImport.fromJson(Map<String, dynamic> json) {
    // ✅ التعامل مع البيانات غير المتوقعة من الـ backend
    final List<Vehicle> vehiclesList = [];
    if (json['vehicles'] is List) {
      for (final item in json['vehicles']) {
        // إذا كان العنصر يحتوي على مفتاح 'name' فمن المحتمل أنه مركبة
        if (item is Map<String, dynamic> &&
            item.containsKey('name') &&
            item.containsKey('capacity')) {
          try {
            // ✅ محاولة تحليل المركبة وتجاهل الأخطاء
            final vehicle = Vehicle.fromJson(item);
            vehiclesList.add(vehicle);
          } catch (e) {
            // تجاهل الكائنات التي لا يمكن تحليلها كمركبة
            continue;
          }
        }
      }
    }

    return PendingVehicleImport(
      importOperationKey: json['import_operation_key']?.toString() ?? 'N/A',
      vehiclesKey: json['vehicles_key']?.toString() ?? 'N/A',
      supplier: Supplier.fromJson(Map<String, dynamic>.from(json['supplier'])),
      location:
          json['location']?.toString() ?? 'N/A', // التعامل مع القيمة الفارغة
      latitude: (json['latitude'] is num
          ? (json['latitude'] as num).toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '0') ??
              0.0), // التعامل مع القيمة الفارغة
      longitude: (json['longitude'] is num
          ? (json['longitude'] as num).toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '0') ??
              0.0), // التعامل مع القيمة الفارغة
      vehicles: vehiclesList,
    );
  }
}
