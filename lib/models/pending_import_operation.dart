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
  final List<ImportedStorageItem> storageItems;

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
    return PendingImportOperation(
      importOperationKey: json['import_operation_key'] as String,
      storageMediaKey: json['storage_media_key'] as String,
      supplier: Supplier.fromJson(Map<String, dynamic>.from(json['supplier'])),
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      // ✅ استدعاء الدالة المساعدة الذكية لتحليل القائمة المعقدة
      storageItems: _parseStorageItems(json['storage_media']),
    );
  }

  // ✅ دالة مساعدة لدمج بيانات العناصر والأقسام من القائمة غير المتجانسة
  static List<ImportedStorageItem> _parseStorageItems(dynamic rawItems) {
    if (rawItems is! List) return [];

    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
        rawItems.map((item) => Map<String, dynamic>.from(item)));

    // 1. فصل الكائنات إلى نوعين: طلبات وتفاصيل أقسام
    final itemRequests =
        items.where((i) => i.containsKey('section_id')).toList();
    final sectionDetails =
        items.where((i) => i.containsKey('section')).toList();

    // 2. إنشاء خريطة للبحث السريع عن تفاصيل القسم بواسطة المعرف
    final sectionMap = <int, Map<String, dynamic>>{};
    for (var detail in sectionDetails) {
      final section = detail['section'] as Map<String, dynamic>?;
      if (section != null && section['id'] != null) {
        sectionMap[int.parse(section['id'].toString())] = section;
      }
    }

    // 3. بناء القائمة النهائية عن طريق دمج الطلب مع تفاصيل القسم المطابق
    final List<ImportedStorageItem> result = [];
    for (var request in itemRequests) {
      final sectionId = request['section_id'] as int?;
      if (sectionId != null && sectionMap.containsKey(sectionId)) {
        // تم العثور على قسم مطابق، قم بدمج البيانات
        final combinedJson = {
          ...request, // يحتوي على storage_media_id, quantity, section_id
          'section': sectionMap[sectionId], // إضافة كائن القسم الكامل
        };
        result.add(ImportedStorageItem.fromJson(combinedJson));
      }
    }
    return result;
  }
}

class ImportedStorageItem {
  final int storageMediaId;
  final int quantity;
  final WarehouseSection section; // الآن لدينا كائن القسم الكامل

  ImportedStorageItem({
    required this.storageMediaId,
    required this.quantity,
    required this.section,
  });

  factory ImportedStorageItem.fromJson(Map<String, dynamic> json) {
    if (json['storage_media_id'] == null ||
        json['quantity'] == null ||
        json['section'] == null) {
      throw FormatException(
          "Invalid ImportedStorageItem JSON after merge: $json");
    }
    return ImportedStorageItem(
      storageMediaId: json['storage_media_id'] as int,
      quantity: json['quantity'] as int,
      section:
          WarehouseSection.fromJson(Map<String, dynamic>.from(json['section'])),
    );
  }
}
