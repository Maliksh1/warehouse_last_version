class GarageItem {
  final String vehicleId;
  final String status;

  GarageItem({required this.vehicleId, required this.status});

  factory GarageItem.fromJson(Map<String, dynamic> json) {
    return GarageItem(
      vehicleId: json['vehicleId'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'status': status,
    };
  }
}
