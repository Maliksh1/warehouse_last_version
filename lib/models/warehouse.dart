class Warehouse {
  final String id; // Unique identifier
  final String name; // Warehouse name
  final String address; // Full address
  final double capacity; // Total capacity
  final String capacityUnit; // Unit (e.g., "m³", "Units", "Pallets")
  final double occupied; // How much is used
  final String? managerId; // Optional link to employee ID

  Warehouse({
    required this.id,
    required this.name,
    required this.address,
    required this.capacity,
    required this.capacityUnit,
    required this.occupied,
    this.managerId,
    required String location,
    required int used,
    required String manager,
    required productIds,
    required usedCapacity,
  });

  /// Factory to create from JSON
  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      capacity: (json['capacity'] as num).toDouble(),
      capacityUnit: json['capacityUnit'] as String,
      occupied: (json['occupied'] as num).toDouble(),
      managerId: json['managerId'],
      location: '',
      used: 1,
      manager: '',
      productIds: null,
      usedCapacity: null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'occupied': occupied,
      'managerId': managerId,
    };
  }

  /// Usage percentage (from 0.0 to 1.0)
  double get usageRate => capacity > 0 ? occupied / capacity : 0.0;

  /// Copy with
  Warehouse copyWith({
    String? id,
    String? name,
    String? address,
    double? capacity,
    String? capacityUnit,
    double? occupied,
    String? managerId,
    required String location,
    required String manager,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      capacity: capacity ?? this.capacity,
      capacityUnit: capacityUnit ?? this.capacityUnit,
      occupied: occupied ?? this.occupied,
      managerId: managerId ?? this.managerId,
      location: '',
      used: 1,
      manager: '',
      productIds: null,
      usedCapacity: null,
    );
  }
}
