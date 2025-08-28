// lib/models/warehouse.dart
// ✅ استيراد لتحليل التواريخ

class Warehouse {
  final int id;
  final String name;
  final String? location;
  final double? latitude;
  final double? longitude;
  final int? typeId;
  final int? numSections;
  final double? capacity;
  final String? capacityUnit;
  final double? usageRate;
  final String? typeName;
  final String? status;
  final int? usedCapacity;

  // ✅ --- تمت إعادتهم ---
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Warehouse({
    required this.id,
    required this.name,
    this.location,
    this.latitude,
    this.longitude,
    this.typeId,
    this.numSections,
    this.capacity,
    this.capacityUnit,
    this.usageRate,
    this.typeName,
    this.status,
    this.usedCapacity,
    this.createdAt, // ✅
    this.updatedAt, // ✅
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    // ✅ دالة مساعدة لتحليل التاريخ بأمان
    DateTime? parseDateTime(dynamic value) {
      if (value == null || value is! String) return null;
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }

    final idValue = parseInt(json['id'] ?? json['warehouse_id']);
    if (idValue == null) {
      throw const FormatException("Warehouse ID is null or invalid");
    }

    return Warehouse(
      id: idValue,
      name:
          json['name']?.toString() ?? json['warehouse_name']?.toString() ?? '',
      location: json['location']?.toString() ?? json['address']?.toString(),
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      typeId: parseInt(json['type_id']),
      numSections: parseInt(json['num_sections']),
      capacity: parseDouble(json['capacity'] ?? json['max_capacity']),
      capacityUnit:
          json['capacity_unit']?.toString() ?? json['unit']?.toString(),
      usageRate: parseDouble(
          json['usage_rate'] ?? json['usageRate'] ?? json['occupancy']),
      typeName: json['type_name']?.toString(),
      status: json['status']?.toString(),
      usedCapacity: parseInt(json['occupied'] ?? json['used_capacity']),
      createdAt: parseDateTime(json['created_at']), // ✅
      updatedAt: parseDateTime(json['updated_at']), // ✅
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (location != null) 'location': location,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (typeId != null) 'type_id': typeId,
        if (numSections != null) 'num_sections': numSections,
        if (capacity != null) 'capacity': capacity,
        if (capacityUnit != null) 'capacity_unit': capacityUnit,
        if (usageRate != null) 'usage_rate': usageRate,
        if (typeName != null) 'type_name': typeName,
        if (status != null) 'status': status,
        if (usedCapacity != null) 'used_capacity': usedCapacity,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(), // ✅
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(), // ✅
      };
}
