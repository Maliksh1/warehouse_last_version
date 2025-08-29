// lib/models/unified_pending_operation.dart
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/models/pending_product_import.dart';
import 'package:warehouse/models/pending_vehicle_import.dart';

// Sealed class لتمثيل جميع أنواع العمليات المعلقة الممكنة
sealed class UnifiedPendingOperation {}

class StorageMediaOperation extends UnifiedPendingOperation {
  final PendingImportOperation operation;
  StorageMediaOperation(this.operation);
}

class ProductOperation extends UnifiedPendingOperation {
  final PendingProductImport operation;
  ProductOperation(this.operation);
}

class VehicleOperation extends UnifiedPendingOperation {
  final PendingVehicleImport operation;
  VehicleOperation(this.operation);
}

// يمكنك إضافة أنواع أخرى في المستقبل هنا
// class VehicleOperation extends UnifiedPendingOperation { ... }
