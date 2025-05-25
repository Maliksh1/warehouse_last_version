class StockItem {
  final String id;
  final String productId;
  final String warehouseId;
  final String location;
  final int quantity;
  final DateTime? expiryDate;

  StockItem({
    required this.id,
    required this.productId,
    required this.warehouseId,
    required this.location,
    required this.quantity,
    this.expiryDate,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'],
      productId: json['productId'],
      warehouseId: json['warehouseId'],
      location: json['location'],
      quantity: json['quantity'],
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'warehouseId': warehouseId,
      'location': location,
      'quantity': quantity,
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }
}
