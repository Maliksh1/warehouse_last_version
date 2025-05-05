class Customer {
  final String name;
  final String contact;

  Customer({
    required this.name,
    required this.contact,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
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
