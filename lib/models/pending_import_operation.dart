// lib/models/pending_import_operation.dart
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/warehouse_section.dart';

// يمثل عملية الاستيراد الكاملة المعلقة
class PendingImportOperation {
  final String importOperationKey;
  final String storageMediaKey;
  final Supplier supplier;
  final String location;
  final double latitude;
  final double longitude;
  final List<PendingStorageItem> storageItems;

  PendingImportOperation({
    required this.importOperationKey,
    required this.storageMediaKey,
    required this.supplier,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.storageItems,
  });

  factory PendingImportOperation.fromJson(Map<String, dynamic> json) {
    final storageMediaMap =
        json['storage_media'] as Map<String, dynamic>? ?? {};
    final storageItems = storageMediaMap.values
        .map((itemJson) => PendingStorageItem.fromJson(itemJson))
        .toList();

    return PendingImportOperation(
      importOperationKey: json['import_operation_key'],
      storageMediaKey: json['storage_media_key'],
      supplier: Supplier.fromJson(json['supplier']),
      location: json['location'],
      // --- هنا تم التصحيح: تحويل آمن من أي نوع رقمي أو نصي ---
      latitude: double.tryParse(json['latitude'].toString()) ?? 0.0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0.0,
      storageItems: storageItems,
    );
  }
}

// يمثل كل عنصر سيتم تخزينه في قسم معين
class PendingStorageItem {
  final int storageMediaId;
  final int quantity;
  final int sectionId;
  final int emptyCapacity;
  final WarehouseSection section;

  PendingStorageItem({
    required this.storageMediaId,
    required this.quantity,
    required this.sectionId,
    required this.emptyCapacity,
    required this.section,
  });

  factory PendingStorageItem.fromJson(Map<String, dynamic> json) {
    return PendingStorageItem(
      // --- هنا تم التصحيح: تحويل آمن من أي نوع رقمي أو نصي ---
      storageMediaId: int.tryParse(json['storage_media_id'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      sectionId: int.tryParse(json['section_id'].toString()) ?? 0,
      emptyCapacity: json['empty_capacity'],
      section: WarehouseSection.fromJson(json['section']),
    );
  }
}
