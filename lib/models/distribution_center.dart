class DistributionCenter {
  final String id; // Added unique ID
  final String name;
  final String address; // Renamed from 'location' to standard 'address'
  final String? capacity; // Optional: e.g., "5000 units", "2000 sqm"
  final String? managerId; // Link to Employee ID (optional)
  final List<String> vehicleIds; // Vehicles assigned to this center (optional)

  DistributionCenter({
    required this.id,
    required this.name,
    required this.address,
    this.capacity,
    this.managerId,
    this.vehicleIds = const [],
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      capacity: json['capacity'],
      managerId: json['managerId'],
      vehicleIds: List<String>.from(json['vehicleIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'capacity': capacity,
      'managerId': managerId,
      'vehicleIds': vehicleIds,
    };
  }
}
