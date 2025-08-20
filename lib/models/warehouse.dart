// models/warehouse.dart
class Warehouse {
  final String id;
  final String name;
  final String? location; // الباك يرجّع location
  final double? latitude;
  final double? longitude;
  final int? typeId;
  final int? numSections;

  final double? capacity; // إن وُجد
  final String? capacityUnit; // capacity_unit أو unit
  final double? usageRate; // 0..1 أو 0..100
  final String? typeName; // إن وُجد بالرد

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
    String? address,
    int? occupied,
    productIds,
    required String manager,
     int? usedCapacity,
  });

  factory Warehouse.fromJson(Map<String, dynamic> j) {
    String _s(String k) => j[k]?.toString() ?? '';
    String? _sOpt(String k) => j[k] == null ? null : j[k].toString();

    double? _d(String k) {
      final v = j[k];
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int _occu; // Will be calculated later
    int? _i(String k) {
      final v = j[k];
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    // usageRate قد تأتي كنسبة مئوية، نحولها إلى 0..1
    double? _usage() {
      final raw = _d('usage_rate') ?? _d('usageRate') ?? _d('occupancy');
      if (raw == null) return null;
      return raw > 1 ? raw / 100.0 : raw;
    }

    // Calculate occupied capacity after helper functions are defined
    _occu = _i('occupied') ?? 0;

    final id = _s('id').isNotEmpty ? _s('id') : _s('warehouse_id');
    final name = _s('name').isNotEmpty ? _s('name') : _s('warehouse_name');

    return Warehouse(
      id: id,
      name: name,
      location: _sOpt('location') ?? _sOpt('address'),
      latitude: _d('latitude'),
      longitude: _d('longitude'),
      typeId: _i('type_id'),
      numSections: _i('num_sections'),
      capacity: _d('capacity') ?? _d('max_capacity'),
      capacityUnit: _sOpt('capacity_unit') ?? _sOpt('unit'),
      usageRate: _usage(),
      typeName: _sOpt('type_name'),
      manager: '',
      usedCapacity: _occu,
    );
  }

  get createdAt => null;

  get updatedAt => null;

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
      };
}
