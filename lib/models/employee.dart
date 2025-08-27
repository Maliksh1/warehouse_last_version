// lib/models/employee.dart
class Employee {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? specialization; // The name of the specialization
  final int? specializationId; // **[ADDED]** The ID of the specialization
  final String? country;
  final String? salary;
  final String? startTime;
  final String? workHours;

  Employee({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
    this.specialization,
    this.specializationId, // **[ADDED]**
    this.country,
    this.salary,
    this.startTime,
    this.workHours,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    String? specName;
    int? specId;

    final sp = j['specialization'];
    if (sp is String) {
      specName = sp;
    } else if (sp is Map) {
      specName = sp['name']?.toString();
      // Safely parse the specialization ID
      final rawId = sp['id'];
      if (rawId is num) {
        specId = rawId.toInt();
      } else if (rawId != null) {
        specId = int.tryParse(rawId.toString());
      }
    }

    // Also check for a separate specialization_id key as a fallback
    if (specId == null && j['specialization_id'] != null) {
      final rawId = j['specialization_id'];
      if (rawId is num) {
        specId = rawId.toInt();
      } else {
        specId = int.tryParse(rawId.toString());
      }
    }

    return Employee(
      id: (j['id'] ?? j['emp_id'] ?? 0) is int
          ? (j['id'] ?? j['emp_id'] ?? 0) as int
          : int.tryParse((j['id'] ?? j['emp_id'] ?? '0').toString()) ?? 0,
      name: (j['name'] ?? '').toString(),
      email: j['email']?.toString(),
      phoneNumber: (j['phone_number'] ?? j['phone'] ?? '').toString(),
      specialization: specName,
      specializationId: specId, // **[ADDED]**
      country: j['country']?.toString(),
      salary: j['salary']?.toString(),
      startTime: j['start_time']?.toString(),
      workHours: j['work_hours']?.toString(),
    );
  }
}
