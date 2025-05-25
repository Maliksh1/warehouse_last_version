enum TransportTaskStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  delayed
} // Added Enum

class TransportTask {
  final String id; // Unique ID for the task
  final String?
      taskIdNumber; // Optional: user-friendly task number like "T-001"
  final String fromLocationId; // ID of Warehouse or Distribution Center
  final String
      toLocationId; // ID of Warehouse, Distribution Center, or Customer Address
  final String vehicleId; // Link to Vehicle ID
  final String driverId; // Link to Employee ID (driver)
  final DateTime scheduledStartTime;
  final DateTime? actualStartTime; // Optional: when it actually started
  final DateTime? scheduledEndTime; // Optional: when it was expected to end
  final DateTime? actualEndTime; // Optional: when it actually finished
  final List<TransportTaskItem> items; // List of products/items to transport
  final TransportTaskStatus status; // Use Enum for status
  final String? notes; // Optional notes

  TransportTask({
    required this.id,
    this.taskIdNumber,
    required this.fromLocationId,
    required this.toLocationId,
    required this.vehicleId,
    required this.driverId,
    required this.scheduledStartTime,
    this.actualStartTime,
    this.scheduledEndTime,
    this.actualEndTime,
    required this.items, // Initialize with empty list if creating new
    this.status = TransportTaskStatus.scheduled, // Default status
    this.notes,
    required String itemsDescription,
    required String toLocation,
    required String fromLocation,
  });

  factory TransportTask.fromJson(Map<String, dynamic> json) {
    return TransportTask(
      id: json['id'],
      taskIdNumber: json['taskIdNumber'],
      fromLocationId: json['fromLocationId'],
      toLocationId: json['toLocationId'],
      vehicleId: json['vehicleId'],
      driverId: json['driverId'],
      scheduledStartTime: DateTime.parse(json['scheduledStartTime']),
      actualStartTime: json['actualStartTime'] != null
          ? DateTime.parse(json['actualStartTime'])
          : null,
      scheduledEndTime: json['scheduledEndTime'] != null
          ? DateTime.parse(json['scheduledEndTime'])
          : null,
      actualEndTime: json['actualEndTime'] != null
          ? DateTime.parse(json['actualEndTime'])
          : null,
      items: (json['items'] as List)
          .map((i) => TransportTaskItem.fromJson(i))
          .toList(), // Parse list of items
      status: TransportTaskStatus.values.firstWhere((e) =>
          e.toString() ==
          'TransportTaskStatus.${json['status']}'), // Parse Enum
      notes: json['notes'], itemsDescription: '', toLocation: '',
      fromLocation: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskIdNumber': taskIdNumber,
      'fromLocationId': fromLocationId,
      'toLocationId': toLocationId,
      'vehicleId': vehicleId,
      'driverId': driverId,
      'scheduledStartTime':
          scheduledStartTime.toIso8601String(), // Convert DateTime
      'actualStartTime': actualStartTime?.toIso8601String(),
      'scheduledEndTime': scheduledEndTime?.toIso8601String(),
      'actualEndTime': actualEndTime?.toIso8601String(),
      'items':
          items.map((item) => item.toJson()).toList(), // Convert list of items
      'status': status.toString().split('.').last, // Convert Enum to String
      'notes': notes,
    };
  }
}

// Helper model for items within a Transport Task
class TransportTaskItem {
  final String productId; // Link to Product ID
  final int quantity;

  TransportTaskItem({
    required this.productId,
    required this.quantity,
  });

  factory TransportTaskItem.fromJson(Map<String, dynamic> json) {
    return TransportTaskItem(
      productId: json['productId'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}
