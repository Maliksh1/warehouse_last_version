import 'imported_product.dart';

class WarehouseSection {
  final String id;
  final String warehouseId;         // from existable_id
  final String name;
  final String supportedTypeId;     // نربطه بـ product_id (المنتج المختص به القسم)
  final double capacity;            // نحسبها من max_storage_media_area أو من (floors*classes*positions)
  final String capacityUnit;        // وحدة عرض للسعة - اخترنا "موقع" (positions)
  final double occupied;            // capacity - avilable_storage_media_area (أو actual_load_product)
  final List<ImportedProduct> products;

  WarehouseSection({
    required this.id,
    required this.warehouseId,
    required this.name,
    required this.supportedTypeId,
    required this.capacity,
    required this.capacityUnit,
    required this.occupied,
    this.products = const [],
  });

  factory WarehouseSection.fromJson(Map<String, dynamic> json) {
    num? n(dynamic v) => (v is num) ? v : num.tryParse('$v');

    final double floors   = (n(json['num_floors']) ?? 0).toDouble();
    final double classes  = (n(json['num_classes']) ?? 0).toDouble();
    final double posOnCls = (n(json['num_positions_on_class']) ?? 0).toDouble();

    // السعة القصوى بحسب الرد (إن وُجدت) وإلا نشتقها من (floors*classes*positions)
    final double maxArea = (n(json['max_storage_media_area'])?.toDouble())
        ?? (floors * classes * posOnCls);

    final double? availableArea =
        n(json['avilable_storage_media_area'])?.toDouble();

    // الإشغال: الفرق بين القصوى والمتاحة، أو استخدم actual_load_product كبديل
    final double occupiedCalc = (availableArea != null)
        ? (maxArea - availableArea)
        : (n(json['actual_load_product'])?.toDouble() ?? 0);

    return WarehouseSection(
      id: '${json['id']}',
      warehouseId: '${json['existable_id']}',
      name: json['name']?.toString() ?? '',
      supportedTypeId: '${json['product_id']}',              // ربطناه بالمنتج
      capacity: maxArea,
      capacityUnit: 'موقع',                                  // تسمية ودّية للعرض
      occupied: occupiedCalc.clamp(0, maxArea),
      products: const [],                                     // لا يوجد products في الرد
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'existable_id': warehouseId,
      'name': name,
      'product_id': supportedTypeId,
      'max_storage_media_area': capacity,
      'avilable_storage_media_area': (capacity - occupied),
      'capacity_unit': capacityUnit,
      'products': products.map((p) => p.toJson()).toList(),
    };
  }

  double get usageRate => capacity > 0 ? occupied / capacity : 0.0;

  WarehouseSection copyWith({
    String? id,
    String? warehouseId,
    String? name,
    String? supportedTypeId,
    double? capacity,
    String? capacityUnit,
    double? occupied,
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
      products: products ?? this.products,
    );
  }
}
