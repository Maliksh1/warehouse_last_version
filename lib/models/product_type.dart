// lib/models/product_type.dart

class ProductType {
  final int id;
  final String name;
  final String? description;

  ProductType({
    required this.id,
    required this.name,
    this.description,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}
