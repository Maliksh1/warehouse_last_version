class Supplier {
  final String name;
  final String contact;

  Supplier({
    required this.name,
    required this.contact,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      name: json['name'],
      contact: json['contact'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'contact': contact,
    };
  }
}
