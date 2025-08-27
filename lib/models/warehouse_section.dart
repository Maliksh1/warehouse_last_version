// lib/models/warehouse_section.dart
import 'package:warehouse/models/imported_product.dart';

class WarehouseSection {
  final String id;
  final String warehouseId; // من existable_id
  final String name;
  final String supportedTypeId; // من product_id
  final double
      capacity; // max_storage_media_area أو مشتقة من (floors*classes*positions)
  final String capacityUnit; // للعرض فقط (مثلاً: "موقع")
  final double
      occupied; // capacity - avilable_storage_media_area (أو actual_load_product)
  final String status; // active / deleted
  final List<ImportedProduct> products;
  final Map<String, dynamic>? existable;
  final double? storageMediaAvailableArea;
  final double? storageMediaMaxArea;

  WarehouseSection({
    required this.id,
    required this.warehouseId,
    required this.name,
    required this.supportedTypeId,
    required this.capacity,
    required this.capacityUnit,
    required this.occupied,
    required this.status,
    this.products = const [],
    this.existable,
    this.storageMediaAvailableArea,
    this.storageMediaMaxArea,
  });
  static double _calculateCapacity(Map<String, dynamic> json) {
    final floors = (json['num_floors'] as num?)?.toDouble() ?? 1.0;
    final classes = (json['num_classes'] as num?)?.toDouble() ?? 1.0;
    final positions =
        (json['num_positions_on_class'] as num?)?.toDouble() ?? 1.0;
    return floors * classes * positions;
  }

  factory WarehouseSection.fromJson(Map<String, dynamic> json) {
    num? _n(dynamic v) => (v is num) ? v : num.tryParse('$v');

    final double floors = (_n(json['num_floors']) ?? 0).toDouble();
    final double classes = (_n(json['num_classes']) ?? 0).toDouble();
    final double posOnCls =
        (_n(json['num_positions_on_class']) ?? 0).toDouble();

    // إن وُجد max_storage_media_area نأخذه، وإلا نشتق من (floors * classes * positions)
    final double maxArea = (_n(json['max_storage_media_area'])?.toDouble()) ??
        (floors * classes * posOnCls);

    final double? availableArea =
        _n(json['avilable_storage_media_area'])?.toDouble();

    // الإشغال: الفرق بين القصوى والمتاحة، أو actual_load_product كبديل
    final double occupiedCalc = (availableArea != null)
        ? (maxArea - availableArea)
        : (_n(json['actual_load_product'])?.toDouble() ?? 0);

    final String statusStr = (json['status'] ?? 'active').toString();
    

    return WarehouseSection(
      id: '${json['id']}',
      warehouseId: '${json['existable_id']}',
      name: (json['name'] ?? '').toString(),
      supportedTypeId: '${json['product_id']}',
      capacity: maxArea,
      capacityUnit: 'موقع',
      occupied: occupiedCalc.clamp(0, maxArea).toDouble(),
      status: statusStr,
      existable: json['existable'] as Map<String, dynamic>?,
      products: const [], // لا توجد منتجات مفصلة في هذا الـ response
      storageMediaAvailableArea:
    (json['storage_media_avilable_area'] as num?)?.toDouble(),
    storageMediaMaxArea:
    (json['storage_media_max_area'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final remaining = (capacity - occupied);
    return {
      'id': id,
      'existable_id': warehouseId,
      'name': name,
      'product_id': supportedTypeId,
      'max_storage_media_area': capacity,
      'avilable_storage_media_area': remaining < 0 ? 0 : remaining,
      'status': status,
      'capacity_unit': capacityUnit,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  double get usageRate => capacity > 0 ? (occupied / capacity) : 0.0;
  bool get isDeleted => status.toLowerCase() == 'deleted';

  WarehouseSection copyWith({
    String? id,
    String? warehouseId,
    String? name,
    String? supportedTypeId,
    double? capacity,
    String? capacityUnit,
    double? occupied,
    String? status,
    List<ImportedProduct>? products,
  }) {
    return WarehouseSection(
      id: id ?? this.id,
      warehouseId: warehouseId ?? this.warehouseId,
      name: name ?? this.name,
      supportedTypeId: supportedTypeId ?? this.supportedTypeId,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      occupied: occupied ?? this.occupied,
      status: status ?? this.status,
      products: products ?? this.products,
    );
  }
}
