enum VehicleStatus { available, inTransit, underMaintenance } // Added Enum

class Vehicle {
  final String id; // Added unique ID
  final String licensePlate; // Added license plate
  final String model; // Added model (e.g., "Truck", "Van", "Forklift")
  final double
      capacity; // Added capacity (e.g., weight in kg or volume in cubic meters)
  final String
      capacityUnit; // Added unit for capacity (e.g., "kg", "m³", "pallets")
  final String?
      assignedDistributionCenterId; // Link to Distribution Center (optional)
  final VehicleStatus status; // Use Enum for status
  final String? currentLocation; // Optional: current location string or ID

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.model,
    required this.capacity,
    required this.capacityUnit,
    this.assignedDistributionCenterId,
    this.status = VehicleStatus.available, // Default status
    this.currentLocation,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      licensePlate: json['licensePlate'],
      model: json['model'],
      capacity: json['capacity'].toDouble(),
      capacityUnit: json['capacityUnit'],
      assignedDistributionCenterId: json['assignedDistributionCenterId'],
      status: VehicleStatus.values.firstWhere((e) =>
          e.toString() == 'VehicleStatus.${json['status']}'), // Parse Enum
      currentLocation: json['currentLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'licensePlate': licensePlate,
      'model': model,
      'capacity': capacity,
      'capacityUnit': capacityUnit,
      'assignedDistributionCenterId': assignedDistributionCenterId,
      'status': status.toString().split('.').last, // Convert Enum to String
      'currentLocation': currentLocation,
    };
  }
}
