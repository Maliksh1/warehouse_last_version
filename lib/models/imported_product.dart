import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/warehouse.dart';

/// يمثل منتجًا تم استيراده إلى قسم معين في مستودع
class ImportedProduct {
  final String id;
  final String productId;
  final DateTime expirationDate;
  final DateTime productionDate;
  final double pricePerUnit;
  final double quantity;
  final String warehouseId;
  String specialDescription;
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
    this.specialDescription = '',
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
      'special_description': specialDescription,
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

class ProductDistributionInfo {
  final Warehouse warehouse;
  double load;
  bool sendVehicles;

  ProductDistributionInfo({
    required this.warehouse,
    this.load = 0.0,
    this.sendVehicles = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': warehouse.id,
      'load': load,
      'send_vehicles': sendVehicles,
    };
  }
}
