// lib/models/vehicle.dart

// **[NEW]** Defining the missing enum
enum VehicleStatus {
  available,
  inUse,
  maintenance,
  unknown,
}

class Vehicle {
  final int id;
  final String name;
  final String? expiration;
  final String? productedIn;
  final double readiness;
  final String? location; // ✅ Updated
  final double? latitude; // ✅ Updated
  final double? longitude; // ✅ Updated
  final String sizeOfVehicle;
  final int capacity;
  final int productId;
  final String? imageUrl;
  final VehicleStatus status; // **[NEW]** Added status property

  Vehicle({
    required this.id,
    required this.name,
    this.expiration,
    this.productedIn,
    required this.readiness,
    this.location, // ✅ Updated
    this.latitude, // ✅ Updated
    this.longitude, // ✅ Updated
    required this.sizeOfVehicle,
    required this.capacity,
    required this.productId,
    this.imageUrl,
    this.status = VehicleStatus.unknown, // **[NEW]** Default value
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Helper to parse status string to enum
    VehicleStatus parseStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'available':
          return VehicleStatus.available;
        case 'in_use':
        case 'in use':
          return VehicleStatus.inUse;
        case 'maintenance':
          return VehicleStatus.maintenance;
        default:
          return VehicleStatus.unknown;
      }
    }

    return Vehicle(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      expiration: json['expiration'] as String?,
      productedIn: json['producted_in'] as String?,
      readiness: (json['readiness'] as num).toDouble(),
      location: json['location'] as String?, // ✅ Added
      latitude: (json['latitude'] as num?)?.toDouble(), // ✅ Added
      longitude: (json['longitude'] as num?)?.toDouble(), // ✅ Added
      sizeOfVehicle: json['size_of_vehicle'] as String,
      capacity: (json['capacity'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      imageUrl: json['image'] as String?,
      status: parseStatus(json['status'] as String?),
    );
  }
}
