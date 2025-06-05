import 'imported_product.dart';

/// يمثل قسماً داخل مستودع يدعم نوعاً معيناً من المنتجات
class WarehouseSection {
  final String id;
  final String warehouseId;
  final String name;
  final String supportedTypeId; // ← هذا هو الحقل الأساسي لمقارنة توافق المنتج
  final double capacity;
  final String capacityUnit;
  final double occupied;
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
    return WarehouseSection(
      id: json['id'],
      warehouseId: json['warehouseId'],
      name: json['name'],
      supportedTypeId: json['supportedTypeId'], // تم التعديل هنا
      capacity: (json['capacity'] ?? 0).toDouble(),
      capacityUnit: json['capacityUnit'],
      occupied: (json['occupied'] ?? 0).toDouble(),
      products: (json['products'] as List? ?? [])
          .map((e) => ImportedProduct.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'warehouseId': warehouseId,
      'name': name,
      'supportedTypeId': supportedTypeId,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'occupied': occupied,
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
