class Employee {
  final String id; // Added unique ID
  final String name;
  final String
      position; // Renamed from 'role' for clarity (e.g., 'Manager', 'Driver', 'Warehouse Worker')
  final String?
      userId; // Link to a system user ID if they have login access (optional)
  final String? phoneNumber; // Added phone number (optional)
  final String? email; // Added email (optional)
  final String? address; // Added address (optional)
  final String? departmentId; // Link to Department ID (optional)
  final String?
      specialtyId; // Link to Specialty ID (optional, e.g., forklift certified)
  final bool
      isAvailable; // Added availability status (e.g., for task assignment)

  Employee({
    required this.id,
    required this.name,
    required this.position,
    this.userId,
    this.phoneNumber,
    this.email,
    this.address,
    this.departmentId,
    this.specialtyId,
    this.isAvailable = true,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      userId: json['userId'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      address: json['address'],
      departmentId: json['departmentId'],
      specialtyId: json['specialtyId'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'departmentId': departmentId,
      'specialtyId': specialtyId,
      'isAvailable': isAvailable,
    };
  }
}
