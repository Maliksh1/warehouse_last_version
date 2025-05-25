class Supplier {
  final String id; // Added unique ID
  final String name;
  final String contactPerson; // Renamed from 'contact' for clarity
  final String phoneNumber; // Added phone number
  final String? email; // Added email (optional)
  final String address; // Added address
  final String paymentTerms; // e.g., "Net 30", "Due on receipt"
  final List<String> productIds; // List of IDs of products supplied (optional)

  Supplier({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.phoneNumber,
    this.email,
    required this.address,
    required this.paymentTerms,
    this.productIds = const [],
    required String contact, // Initialize with empty list
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      name: json['name'],
      contactPerson: json['contactPerson'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      paymentTerms: json['paymentTerms'],
      productIds: List<String>.from(json['productIds'] ?? []),
      contact: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactPerson': contactPerson,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'paymentTerms': paymentTerms,
      'productIds': productIds,
    };
  }
}
