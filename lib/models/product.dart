// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final String? description;
  final String? imgPath;
  final int? quantity;
  final String? unit;
  final double? actualPiecePrice;
  final String? importCycle;
  final double? lowestTemperature;
  final double? highestTemperature;
  final double? lowestHumidity;
  final double? highestHumidity;
  final double? lowestLight;
  final double? highestLight;
  final double? lowestPressure;
  final double? highestPressure;
  final double? lowestVentilation;
  final double? highestVentilation;
  final int? typeId;
  final String? supplierId; // سنقوم باستخراجه من الكائن المتداخل

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imgPath,
    this.quantity,
    this.unit,
    this.actualPiecePrice,
    this.importCycle,
    this.lowestTemperature,
    this.highestTemperature,
    this.lowestHumidity,
    this.highestHumidity,
    this.lowestLight,
    this.highestLight,
    this.lowestPressure,
    this.highestPressure,
    this.lowestVentilation,
    this.highestVentilation,
    required this.typeId,
    this.supplierId,
  });

  // ✅ ---  هنا التصحيح النهائي ---
  // دالة أكثر قوة ومرونة لتحليل البيانات
  factory Product.fromJson(Map<String, dynamic> json) {
    // دوال مساعدة للتحويل الآمن
    int toInt(dynamic v) => v is int ? v : int.tryParse(v.toString()) ?? 0;
    double toDouble(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
    String? toStr(dynamic v) => v?.toString();

    // استخراج supplier_id من الكائن المتداخل
    final details = json['details'] as Map<String, dynamic>?;
    final supplierId = details?['supplier_id']?.toString();

    return Product(
      id: toStr(json['id']) ?? '',
      name: toStr(json['name']) ?? 'Unnamed Product',
      description: toStr(json['description']),
      imgPath: toStr(json['img_path']),
      quantity: toInt(json['quantity']),
      unit: toStr(json['unit']) ?? '',
      actualPiecePrice: toDouble(json['actual_piece_price']),
      importCycle: toStr(json['import_cycle']),
      lowestTemperature: toDouble(json['lowest_temperature']),
      highestTemperature: toDouble(json['highest_temperature']),
      lowestHumidity: toDouble(json['lowest_humidity']),
      highestHumidity: toDouble(json['highest_humidity']),
      lowestLight: toDouble(json['lowest_light']),
      highestLight: toDouble(json['highest_light']),
      lowestPressure: toDouble(json['lowest_pressure']),
      highestPressure: toDouble(json['highest_pressure']),
      lowestVentilation: toDouble(json['lowest_ventilation']),
      highestVentilation: toDouble(json['highest_ventilation']),
      typeId: toInt(json['type_id']),
      supplierId: supplierId,
    );
  }

  /// JSON للإرسال للـ API (snake_case)
  Map<String, dynamic> toApiJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'import_cycle': importCycle,
      'quantity': quantity,
      'type_id': typeId,
      'unit': unit,
      'actual_piece_price': actualPiecePrice,
      'supplier_id': supplierId,
    }..removeWhere((k, v) => v == null);
  }
}
