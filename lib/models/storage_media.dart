// lib/models/storage_media.dart
class StorageMedia {
  final int id;
  final String name;
  // أضف أي حقول أخرى تأتي من الـ API إذا لزم الأمر
  // final String type;
  // final int productId;

  StorageMedia({
    required this.id,
    required this.name,
  });

  factory StorageMedia.fromJson(Map<String, dynamic> json) {
    return StorageMedia(
      id: json['id'],
      name: json['name'] ?? 'Unnamed Media',
    );
  }
}
