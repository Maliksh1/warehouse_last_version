class Warehouse {
  final String name;
  final int capacity;
  final int used;

  Warehouse({
    required this.name,
    required this.capacity,
    required this.used,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      name: json['name'],
      capacity: json['capacity'],
      used: json['used'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'capacity': capacity,
      'used': used,
    };
  }

  double get usageRate => used / capacity;
}
