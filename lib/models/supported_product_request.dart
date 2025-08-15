// lib/models/supported_product_request.dart

class SupportedProductRequest {
  // معلومات المنتج
  final String name;
  final String description;
  final String importCycle;
  final int quantity;
  final String typeId;
  final String unit;
  final double actualPiecePrice;

  final double lowestTemperature;
  final double highestTemperature;
  final double lowestHumidity;
  final double highestHumidity;
  final double lowestLight;
  final double highestLight;
  final double lowestPressure;
  final double highestPressure;
  final double lowestVentilation;
  final double highestVentilation;

  // الحاوية
  final String nameContainer;
  final int capacity;

  // وسيلة التخزين
  final String nameStorageMedia;
  final int numFloors;
  final int numClasses;
  final int numPositionsOnClass;

  // 🆕 وقت الإنشاء (اختياري)
  final DateTime? createdAt;

  SupportedProductRequest({
    required this.name,
    required this.description,
    required this.importCycle,
    required this.quantity,
    required this.typeId,
    required this.unit,
    required this.actualPiecePrice,
    required this.lowestTemperature,
    required this.highestTemperature,
    required this.lowestHumidity,
    required this.highestHumidity,
    required this.lowestLight,
    required this.highestLight,
    required this.lowestPressure,
    required this.highestPressure,
    required this.lowestVentilation,
    required this.highestVentilation,
    required this.nameContainer,
    required this.capacity,
    required this.nameStorageMedia,
    required this.numFloors,
    required this.numClasses,
    required this.numPositionsOnClass,
    this.createdAt,
  });

  Map<String, String> toJson() {
    final now = DateTime.now();
    final isOlderThan30Min =
        createdAt != null && now.difference(createdAt!).inMinutes > 30;

    final data = <String, String>{
      'description': description,
      'import_cycle': importCycle,
      'quantity': quantity.toString(),
      'unit': unit,
      'actual_piece_price': actualPiecePrice.toString(),
      'lowest_temperature': lowestTemperature.toString(),
      'highest_temperature': highestTemperature.toString(),
      'lowest_humidity': lowestHumidity.toString(),
      'highest_humidity': highestHumidity.toString(),
      'lowest_light': lowestLight.toString(),
      'highest_light': highestLight.toString(),
      'lowest_pressure': lowestPressure.toString(),
      'highest_pressure': highestPressure.toString(),
      'lowest_ventilation': lowestVentilation.toString(),
      'highest_ventilation': highestVentilation.toString(),
      'name_container': nameContainer,
      'capacity': capacity.toString(),
      'name_storage_media': nameStorageMedia,
      'num_floors': numFloors.toString(),
      'num_classes': numClasses.toString(),
      'num_positions_on_class': numPositionsOnClass.toString(),
    };

    // فقط إذا عمر المنتج أقل من 30 دقيقة
    if (!isOlderThan30Min) {
      data['name'] = name;
      data['type_id'] = typeId;
    }

    return data;
  }
}
