class Specialization {
  final String title;

  Specialization({required this.title});

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(title: json['title']);
  }

  Map<String, dynamic> toJson() {
    return {'title': title};
  }
}
