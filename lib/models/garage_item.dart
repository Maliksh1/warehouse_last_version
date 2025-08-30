// lib/models/garage_item.dart

class GarageItem {
  final int id;
  final String sizeOfVehicle;
  final int maxCapacity;
  final int currentVehicles;
  final String existableType;
  final int existableId;
  final String? location; // ✅ تم إضافة حقل الموقع

  GarageItem({
    required this.id,
    required this.sizeOfVehicle,
    required this.maxCapacity,
    required this.currentVehicles,
    required this.existableType,
    required this.existableId,
    this.location, // ✅ تم تحديث الكونستركتور
  });

  factory GarageItem.fromJson(Map<String, dynamic> json) {
    // يستخرج اسم النوع من النص الكامل مثل "App\Models\Warehouse"
    String type = (json['existable_type'] as String? ?? '').split('\\').last;

    return GarageItem(
      id: (json['id'] as num).toInt(),
      sizeOfVehicle: json['size_of_vehicle'] as String? ?? 'N/A',
      maxCapacity: (json['max_capacity'] as num? ?? 0).toInt(),
      // ✅ أصبح يتعامل مع غياب المفتاح بأمان
      currentVehicles: (json['vehicles_count'] as num? ?? 0).toInt(),
      existableType: type,
      existableId: (json['existable_id'] as num).toInt(),
      // ✅ أصبح يقرأ الموقع إذا كان موجودًا
      location: json['location'] as String?,
    );
  }

  // ✅ تم تصحيح الـ Getters لتوفير البيانات الصحيحة لواجهة المستخدم
  String get placeType => existableType;
  int get placeId => existableId;
}
