// lib/models/distribution_center.dart
class DistributionCenter {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final int warehouseId;
  final String? warehouseName;
  final int numSections;
  final int? typeId;
  final String? typeName;
  final List<dynamic>? products;
  final List<dynamic>? employees;

  DistributionCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.warehouseId,
    this.warehouseName,
    required this.numSections,
    this.typeId,
    this.typeName,
    this.products,
    this.employees,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    // دوال مساعدة للتحويل الآمن
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return DistributionCenter(
      id: toInt(json['id']),
      name: json['name'] ?? 'Unnamed Center',
      location: json['location'] ?? 'No location',
      warehouseId: toInt(json['warehouse_id']),
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      warehouseName: json['warehouse_name'],
      numSections: toInt(json['num_sections']),
      products: json['products'] as List<dynamic>?,
      employees: json['employees'] as List<dynamic>?,
      typeId: json['type_id'] == null ? null : toInt(json['type_id']),
      typeName: json['type_name'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'warehouse_id': warehouseId,
        'num_sections': numSections,
        if (typeId != null) 'type_id': typeId,
        if (typeName != null) 'type_name': typeName,
      };

  DistributionCenter copyWith({
    int? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    int? warehouseId,
    String? warehouseName,
    int? numSections,
    int? typeId,
    String? typeName,
  }) {
    return DistributionCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      numSections: numSections ?? this.numSections,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      // products and employees are not copied as they are complex lists
    );
  }
}
