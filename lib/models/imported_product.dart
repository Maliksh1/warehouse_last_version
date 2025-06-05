import 'package:warehouse/models/product.dart';

/// يمثل منتجًا تم استيراده إلى قسم معين في مستودع
class ImportedProduct {
  final String id;
  final String productId;
  final DateTime expirationDate;
  final DateTime productionDate;
  final double pricePerUnit;
  final double quantity;
  final String warehouseId;
  final String sectionId;

  ImportedProduct({
    required this.id,
    required this.productId,
    required this.expirationDate,
    required this.productionDate,
    required this.pricePerUnit,
    required this.quantity,
    required this.warehouseId,
    required this.sectionId,
  });

  factory ImportedProduct.fromJson(Map<String, dynamic> json) {
    return ImportedProduct(
      id: json['id'],
      productId: json['productId'],
      expirationDate: DateTime.parse(json['expirationDate']),
      productionDate: DateTime.parse(json['productionDate']),
      pricePerUnit: (json['pricePerUnit'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      warehouseId: json['warehouseId'],
      sectionId: json['sectionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'expirationDate': expirationDate.toIso8601String(),
      'productionDate': productionDate.toIso8601String(),
      'pricePerUnit': pricePerUnit,
      'quantity': quantity,
      'warehouseId': warehouseId,
      'sectionId': sectionId,
    };
  }

  ImportedProduct copyWith({
    String? id,
    String? productId,
    DateTime? expirationDate,
    DateTime? productionDate,
    double? pricePerUnit,
    double? quantity,
    String? warehouseId,
    String? sectionId,
  }) {
    return ImportedProduct(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      expirationDate: expirationDate ?? this.expirationDate,
      productionDate: productionDate ?? this.productionDate,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      quantity: quantity ?? this.quantity,
      warehouseId: warehouseId ?? this.warehouseId,
      sectionId: sectionId ?? this.sectionId,
    );
  }
}
