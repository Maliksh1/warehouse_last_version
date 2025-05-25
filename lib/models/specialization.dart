class Specialization {
  final String id; // Added unique ID
  final String name; // Renamed from 'title' to standard 'name'
  final String? description; // Optional description

  Specialization({
    required this.id,
    required this.name,
    this.description,
    required String title,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      title: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
