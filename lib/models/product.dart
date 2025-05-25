// lib/models/product.dart
class Product {
  final String id; // Unique ID
  final String name;
  final String sku; // Stock Keeping Unit
  final String? description; // Optional description
  final String categoryId; // Link to Category ID
  final String supplierId; // Link to Supplier ID
  // REMOVED: int currentStock; // Total stock will be calculated by summing StockItems for this product across warehouses
  final double purchasePrice; // Purchase price
  final double sellingPrice; // Selling price
  final String? imageUrl; // Optional image URL
  final int
      minStockLevel; // Minimum stock level for alerts (this is a rule for the product type, not tied to a location)

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.description,
    required this.categoryId,
    required this.supplierId,
    // currentStock is removed
    required this.purchasePrice,
    required this.sellingPrice,
    this.imageUrl,
    this.minStockLevel = 10,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      description: json['description'],
      categoryId: json['categoryId'],
      supplierId: json['supplierId'],
      // currentStock is not parsed here
      purchasePrice: json['purchasePrice'].toDouble(),
      sellingPrice: json['sellingPrice'].toDouble(),
      imageUrl: json['imageUrl'],
      minStockLevel: json['minStockLevel'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'description': description,
      'categoryId': categoryId,
      'supplierId': supplierId,
      // currentStock is not included here
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'imageUrl': imageUrl,
      'minStockLevel': minStockLevel,
    };
  }

  // REMOVED: bool get isLowStock => currentStock <= minStockLevel; // This check now needs total stock data
}
