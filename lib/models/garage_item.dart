// lib/models/garage_item.dart

class GarageItem {
  final int id;
  final String sizeOfVehicle;
  final int maxCapacity;
  final int currentVehicles; // Assuming the backend provides this
  final String existableType;
  final int existableId;

  GarageItem({
    required this.id,
    required this.sizeOfVehicle,
    required this.maxCapacity,
    required this.currentVehicles,
    required this.existableType,
    required this.existableId,
  });

  factory GarageItem.fromJson(Map<String, dynamic> json) {
    // Extracts the simple name e.g., "Warehouse" from "App\Models\Warehouse"
    String type = (json['existable_type'] as String? ?? '').split('\\').last;

    return GarageItem(
      id: (json['id'] as num).toInt(),
      sizeOfVehicle: json['size_of_vehicle'] as String,
      maxCapacity: (json['max_capacity'] as num).toInt(),
      // Assuming a 'vehicles_count' is sent from the backend. Defaulting to 0 if not.
      currentVehicles: (json['vehicles_count'] as num? ?? 0).toInt(),
      existableType: type,
      existableId: (json['existable_id'] as num).toInt(),
    );
  }

  get location => null;

  get placeType => null;

  get placeId => null;
}
