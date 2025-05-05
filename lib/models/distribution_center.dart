class DistributionCenter {
  final String name;
  final String location;

  DistributionCenter({
    required this.name,
    required this.location,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      name: json['name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
    };
  }
}
