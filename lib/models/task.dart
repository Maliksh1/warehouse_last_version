class TransportTask {
  final String id;
  final String status;

  TransportTask({
    required this.id,
    required this.status,
  });

  factory TransportTask.fromJson(Map<String, dynamic> json) {
    return TransportTask(
      id: json['id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
    };
  }
}
