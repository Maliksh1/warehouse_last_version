class Product {
  final String name;
  final String code;
  final String supplier;
  final String category;
  final int quantity;
  final double cost;
  final double price;
  final String status;

  Product({
    required this.name,
    required this.code,
    required this.supplier,
    required this.category,
    required this.quantity,
    required this.cost,
    required this.price,
    required this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      code: json['code'],
      supplier: json['supplier'],
      category: json['category'],
      quantity: json['quantity'],
      cost: json['cost'],
      price: json['price'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'supplier': supplier,
      'category': category,
      'quantity': quantity,
      'cost': cost,
      'price': price,
      'status': status,
    };
  }
}
