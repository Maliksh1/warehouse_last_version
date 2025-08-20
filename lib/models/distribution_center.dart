class DistributionCenter {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final int warehouseId;
  final int numSections;
  final int? typeId;

  DistributionCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.warehouseId,
    required this.numSections,
    this.typeId,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int _toInt(dynamic v) => v is int ? v : int.tryParse('$v') ?? 0;

    return DistributionCenter(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      warehouseId: _toInt(json['warehouse_id']),
      numSections: _toInt(json['num_sections']),
      typeId: json['type_id'] == null ? null : _toInt(json['type_id']),
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
      };

  DistributionCenter copyWith({
    int? id,
    String? name,
    String? location,
    double? latitude,
    double? longitude,
    int? warehouseId,
    int? numSections,
    int? typeId,
  }) {
    return DistributionCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      warehouseId: warehouseId ?? this.warehouseId,
      numSections: numSections ?? this.numSections,
      typeId: typeId ?? this.typeId,
    );
  }
}
