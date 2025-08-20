class ParentStorageMedia {
  final int id;
  final String? name;
  final Map<String, dynamic> raw;
  ParentStorageMedia({required this.id, this.name, required this.raw});
  factory ParentStorageMedia.fromJson(Map<String, dynamic> j) =>
      ParentStorageMedia(
        id: j['id'] is String ? int.tryParse(j['id']) ?? -1 : (j['id'] ?? -1),
        name: j['name']?.toString(),
        raw: j,
      );
}

class StorageElement {
  final int id;
  final String? code;
  final String? status;
  final Map<String, dynamic> raw;
  StorageElement({
    required this.id,
    this.code,
    this.status,
    required this.raw,
  });
  factory StorageElement.fromJson(Map<String, dynamic> j) => StorageElement(
        id: j['id'] is String ? int.tryParse(j['id']) ?? -1 : (j['id'] ?? -1),
        code: j['code']?.toString(),
        status: j['status']?.toString(),
        raw: j,
      );
}

class Continer {
  final int id;
  final String? code;
  final String? status;
  final Map<String, dynamic> raw;
  Continer({
    required this.id,
    this.code,
    this.status,
    required this.raw,
  });
  factory Continer.fromJson(Map<String, dynamic> j) => Continer(
        id: j['id'] is String ? int.tryParse(j['id']) ?? -1 : (j['id'] ?? -1),
        code: j['code']?.toString(),
        status: j['status']?.toString(),
        raw: j,
      );
}

class StorageElementsResult {
  final ParentStorageMedia? parent;
  final List<StorageElement> elements;
  StorageElementsResult({
    required this.parent,
    required this.elements,
  });
}
