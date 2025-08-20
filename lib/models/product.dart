class Product {
  final String id;
  final String name;
  final String? description;
  final String importCycle; // نحوله من int/null إلى String
  final int quantity;
  final String typeId;
  final String unit;
  final double actualPiecePrice;
  final String supplierId; // قد لا يأتي من الـ API

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.importCycle,
    required this.quantity,
    required this.typeId,
    required this.unit,
    required this.actualPiecePrice,
    required this.supplierId,
  });

  // ---- Helpers آمنة للأنواع ----
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static String _asStr(dynamic v, [String fallback = '']) {
    if (v == null) return fallback;
    return v.toString();
  }

  /// يقرأ مفاتيح الـ API (snake_case) والداخلية (camelCase)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _asStr(json['id'] ?? json['product_id']),
      name: _asStr(json['name'] ?? json['product_name'] ?? 'Unnamed'),
      description: json['description']?.toString(),
      importCycle: _asStr(json['import_cycle'] ?? json['importCycle'] ?? ''),
      quantity: _asInt(json['quantity'] ?? json['qty']),
      typeId: _asStr(json['type_id'] ?? json['typeId'] ?? ''),
      unit: _asStr(json['unit'] ?? json['unit_name'] ?? json['uom'] ?? ''),
      actualPiecePrice: _asDouble(json['actual_piece_price'] ??
          json['actualPiecePrice'] ??
          json['price'] ??
          json['unit_price']),
      supplierId: _asStr(json['supplier_id'] ?? json['supplierId'] ?? ''),
    );
  }

  /// JSON داخلي (للتخزين المحلي مثلًا)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'importCycle': importCycle,
      'quantity': quantity,
      'typeId': typeId,
      'unit': unit,
      'actualPiecePrice': actualPiecePrice,
      'supplierId': supplierId,
    };
  }

  /// JSON للإرسال للـ API (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'import_cycle': importCycle,
      'quantity': quantity,
      'type_id': typeId,
      'unit': unit,
      'actual_piece_price': actualPiecePrice,
      'supplier_id': supplierId,
    }..removeWhere((k, v) => v == null);
  }
}
