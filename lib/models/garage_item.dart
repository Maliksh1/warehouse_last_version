enum MaintenanceStatus {
  scheduled,
  inProgress,
  completed,
  cancelled
} // Added Enum

class GarageItem {
  final String id; // Added unique ID for the maintenance log item
  final String vehicleId; // Link to the Vehicle ID
  final DateTime startDate; // Date when maintenance started or was scheduled
  final DateTime? estimatedCompletionDate; // Estimated finish date (optional)
  final DateTime?
      actualCompletionDate; // Date maintenance was finished (optional)
  final String reportedIssue; // Description of the issue
  final String? workDone; // Description of work performed (optional)
  final String
      assignedEmployeeId; // Link to Employee ID performing maintenance (optional)
  final MaintenanceStatus status; // Use Enum for status

  GarageItem({
    required this.id,
    required this.vehicleId,
    required this.startDate,
    this.estimatedCompletionDate,
    this.actualCompletionDate,
    required this.reportedIssue,
    this.workDone,
    this.assignedEmployeeId = '',
    this.status = MaintenanceStatus.scheduled, // Default status
  });

  factory GarageItem.fromJson(Map<String, dynamic> json) {
    return GarageItem(
      id: json['id'],
      vehicleId: json['vehicleId'],
      startDate: DateTime.parse(json['startDate']),
      estimatedCompletionDate: json['estimatedCompletionDate'] != null
          ? DateTime.parse(json['estimatedCompletionDate'])
          : null,
      actualCompletionDate: json['actualCompletionDate'] != null
          ? DateTime.parse(json['actualCompletionDate'])
          : null,
      reportedIssue: json['reportedIssue'],
      workDone: json['workDone'],
      assignedEmployeeId: json['assignedEmployeeId'] ?? '',
      status: MaintenanceStatus.values.firstWhere((e) =>
          e.toString() == 'MaintenanceStatus.${json['status']}'), // Parse Enum
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'startDate': startDate.toIso8601String(), // Convert DateTime to String
      'estimatedCompletionDate': estimatedCompletionDate?.toIso8601String(),
      'actualCompletionDate': actualCompletionDate?.toIso8601String(),
      'reportedIssue': reportedIssue,
      'workDone': workDone,
      'assignedEmployeeId': assignedEmployeeId,
      'status': status.toString().split('.').last, // Convert Enum to String
    };
  }
}
