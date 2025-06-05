class Product {
  final String id;
  final String name;
  final String? description;
  final String importCycle;
  final int quantity;
  final String typeId;
  final String unit;
  final double actualPiecePrice;
  final String supplierId;

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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      importCycle: json['importCycle'],
      quantity: json['quantity'],
      typeId: json['typeId'],
      unit: json['unit'],
      actualPiecePrice: (json['actualPiecePrice'] ?? 0).toDouble(),
      supplierId: json['supplierId'],
    );
  }

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
}
