// lib/models/pending_product_import.dart
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/warehouse.dart';

// يمثل معلومات توزيع منتج معين على مستودع
class ProductDistributionInfo {
  final Warehouse warehouse;
  double load; // الكمية المخصصة لهذا المستودع
  bool sendVehicles;

  ProductDistributionInfo({
    required this.warehouse,
    this.load = 0.0,
    this.sendVehicles = false,
  });

  Map<String, dynamic> toJson() => {
        'warehouse_id': warehouse.id,
        'load': load,
        'send_vehicles': sendVehicles,
      };

  factory ProductDistributionInfo.fromJson(Map<String, dynamic> json) {
    return ProductDistributionInfo(
      warehouse: Warehouse.fromJson({'id': json['warehouse_id']}),
      load: (json['load'] as num?)?.toDouble() ?? 0.0,
      sendVehicles: json['send_vehicles'] as bool? ?? false,
    );
  }
}

// يمثل المنتج الذي يتم استيراده مع تفاصيله
class ImportedProductInfo {
  final Product product;
  String expirationDate;
  String productionDate;
  double pricePerUnit;
  String specialDescription;
  double importedLoad; // الكمية الإجمالية المستوردة
  List<ProductDistributionInfo> distribution;

  ImportedProductInfo({
    required this.product,
    this.expirationDate = '',
    this.productionDate = '',
    this.pricePerUnit = 0.0,
    this.specialDescription = '',
    this.importedLoad = 0.0,
    required this.distribution,
  });

  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'expiration': expirationDate,
        'producted_in': productionDate,
        'price_unit': pricePerUnit,
        'special_description': specialDescription,
        'imported_load': importedLoad,
        'distribution': distribution.map((d) => d.toJson()).toList(),
      };

  factory ImportedProductInfo.fromJson(Map<String, dynamic> json) {
    var distributionList = (json['distribution'] as List<dynamic>?)
            ?.map((d) => ProductDistributionInfo.fromJson(d))
            .toList() ??
        [];

    return ImportedProductInfo(
      product: Product.fromJson({'id': json['product_id']}),
      expirationDate: json['expiration']?.toString() ?? '',
      productionDate: json['producted_in']?.toString() ?? '',
      pricePerUnit: (json['price_unit'] as num?)?.toDouble() ?? 0.0,
      specialDescription: json['special_description']?.toString() ?? '',
      importedLoad: (json['imported_load'] as num?)?.toDouble() ?? 0.0,
      distribution: distributionList,
    );
  }
}

// يمثل عملية استيراد المنتجات الكاملة المعلقة
class PendingProductImport {
  final String importOperationKey;
  final String productsKey;
  final Supplier supplier;
  final String location;
  final List<ImportedProductInfo> products;

  PendingProductImport({
    required this.importOperationKey,
    required this.productsKey,
    required this.supplier,
    required this.location,
    required this.products,
  });

  factory PendingProductImport.fromJson(Map<String, dynamic> json) {
    var productList = (json['products'] as List<dynamic>?)
            ?.map((p) => ImportedProductInfo.fromJson(p))
            .toList() ??
        [];

    return PendingProductImport(
      importOperationKey: json['import_operation_key'],
      productsKey: json['products_key'],
      supplier: Supplier.fromJson(json['supplier']),
      location: json['location'],
      products: productList,
    );
  }
}
