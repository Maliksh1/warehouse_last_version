// lib/models/employee.dart
class Employee {
  final int id;
  final String name;
  final String? email;
  final String? phoneNumber;
  final String? specialization; // قد تأتي نصًا أو كائنًا
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
    this.country,
    this.salary,
    this.startTime,
    this.workHours,
  });

  factory Employee.fromJson(Map<String, dynamic> j) {
    String? spec;
    final sp = j['specialization'];
    if (sp is String) {
      spec = sp;
    } else if (sp is Map && sp['name'] != null) {
      spec = sp['name'].toString();
    }

    return Employee(
      id: (j['id'] ?? j['emp_id'] ?? 0) is int
          ? (j['id'] ?? j['emp_id'] ?? 0) as int
          : int.tryParse((j['id'] ?? j['emp_id'] ?? '0').toString()) ?? 0,
      name: (j['name'] ?? '').toString(),
      email: j['email']?.toString(),
      phoneNumber: (j['phone_number'] ?? j['phone'] ?? '').toString(),
      specialization: spec,
      country: j['country']?.toString(),
      salary: j['salary']?.toString(),
      startTime: j['start_time']?.toString(),
      workHours: j['work_hours']?.toString(),
    );
  }
}
