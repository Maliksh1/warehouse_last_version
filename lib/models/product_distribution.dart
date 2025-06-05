class ProductDistribution {
  final String warehouseId;
  final String sectionId;
  final double quantity;

  ProductDistribution({
    required this.warehouseId,
    required this.sectionId,
    required this.quantity,
  });

  factory ProductDistribution.fromJson(Map<String, dynamic> json) {
    return ProductDistribution(
      warehouseId: json['warehouseId'],
      sectionId: json['sectionId'],
      quantity: (json['quantity'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'warehouseId': warehouseId,
      'sectionId': sectionId,
      'quantity': quantity,
    };
  }
}
