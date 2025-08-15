class ProductContainer {
  final String nameContainer;
  final int capacity;
  final String name;
  ProductContainer(
      {required this.nameContainer,
      required this.capacity,
      required this.name});

  factory ProductContainer.fromJson(Map<String, dynamic> json) {
    return ProductContainer(
      nameContainer: json['name_container'],
      capacity: json['capacity'],
      name: json['name'],
    );
  }
}

class ProductStorageMedia {
  final String nameStorageMedia;
  final int numFloors;
  final int numClasses;
  final int numPositionsOnClass;
  final String name;
  ProductStorageMedia({
    required this.nameStorageMedia,
    required this.numFloors,
    required this.numClasses,
    required this.numPositionsOnClass,
    required this.name,
  });

  factory ProductStorageMedia.fromJson(Map<String, dynamic> json) {
    return ProductStorageMedia(
      name: json['name'],
      nameStorageMedia: json['name_storage_media'],
      numFloors: json['num_floors'],
      numClasses: json['num_classes'],
      numPositionsOnClass: json['num_positions_on_class'],
    );
  }
}
