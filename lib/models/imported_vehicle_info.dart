// lib/models/imported_vehicle_info.dart
import 'dart:io';
// import 'package:image_picker/image_picker.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/warehouse.dart';

// هذا النموذج يحمل بيانات المركبة التي يتم إدخالها من قبل المستخدم
// قبل إرسالها إلى الـ API.
class ImportedVehicleInfo {
  String name;
  String expiration;
  String productedIn;
  double readiness;
  String? location;
  double? latitude;
  double? longitude;
  String sizeOfVehicle;
  int capacity;
  Product? product;
  String placeType;
  int placeId;

  String? imagePath;
  String? placeName; // ✅ جديد
  String? productName; // ✅ جديد

  ImportedVehicleInfo({
    required this.name,
    required this.expiration,
    required this.productedIn,
    required this.readiness,
    this.location,
    this.latitude,
    this.longitude,
    required this.sizeOfVehicle,
    required this.capacity,
    this.product,
    required this.placeType,
    required this.placeId,
    this.imagePath,
    this.placeName,
    this.productName,
  });

  // دالة لتحويل بيانات النموذج إلى JSON يتوافق مع الـ backend
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "expiration": expiration,
      "producted_in": productedIn,
      "readiness": readiness,
      "location": location,
      "latitude": latitude,
      "longitude": longitude,
      "size_of_vehicle": sizeOfVehicle,
      "capacity": capacity,
      "product_id": product!.id,
      "place_type": placeType,
      "place_id": placeId,
      // لا نضمّن الصورة هنا، بل تُعالج بشكل منفصل
    };
  }
}
