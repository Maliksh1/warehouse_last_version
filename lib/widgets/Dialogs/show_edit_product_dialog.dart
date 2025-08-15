import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/product_types_provider.dart';
import 'package:warehouse/providers/types_provider.dart';
import 'package:warehouse/services/product_api.dart';
import 'package:warehouse/models/supported_product_request.dart';
// import 'package:warehouse/providers/products_types_provider.dart';

void showEditProductDialog(
    BuildContext context, WidgetRef ref, Product product) {
  final t = AppLocalizations.of(context)!;
  final formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final importCycleController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final lowestTempController = TextEditingController();
  final highestTempController = TextEditingController();
  final lowestHumidityController = TextEditingController();
  final highestHumidityController = TextEditingController();
  final lowestLightController = TextEditingController();
  final highestLightController = TextEditingController();
  final lowestPressureController = TextEditingController();
  final highestPressureController = TextEditingController();
  final lowestVentController = TextEditingController();
  final highestVentController = TextEditingController();
  final nameContainerController = TextEditingController();
  final capacityController = TextEditingController();
  final nameStorageController = TextEditingController();
  final floorsController = TextEditingController();
  final classesController = TextEditingController();
  final positionsController = TextEditingController();

  // حالة الـ Dropdown
  int? selectedTypeId;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text("دعم منتج جديد"),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("معلومات المنتج",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _input(nameController, "اسم المنتج"),
                _input(descriptionController, "الوصف"),
                _input(importCycleController, "دورة الاستيراد"),
                _input(quantityController, "الكمية",
                    type: TextInputType.number),
                Consumer(builder: (context, ref, _) {
                  final typesAsync = ref.watch(productTypesProvider);
                  return typesAsync.when(
                    data: (types) {
                      return DropdownButtonFormField<int>(
                        value: selectedTypeId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "اختر نوع المنتج",
                          border: OutlineInputBorder(),
                        ),
                        items: types.map((type) {
                          return DropdownMenuItem<int>(
                            value: type['id'],
                            child: Text(type['name']),
                          );
                        }).toList(),
                        onChanged: (val) {
                          selectedTypeId = val;
                        },
                        validator: (val) =>
                            val == null ? 'الرجاء اختيار نوع' : null,
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('خطأ: $e'),
                  );
                }),
                _input(unitController, "الوحدة"),
                _input(priceController, "سعر القطعة",
                    type: TextInputType.number),
                _input(lowestTempController, "أقل درجة حرارة",
                    type: TextInputType.number),
                _input(highestTempController, "أعلى درجة حرارة",
                    type: TextInputType.number),
                _input(lowestHumidityController, "أقل رطوبة",
                    type: TextInputType.number),
                _input(highestHumidityController, "أعلى رطوبة",
                    type: TextInputType.number),
                _input(lowestLightController, "أقل إضاءة",
                    type: TextInputType.number),
                _input(highestLightController, "أعلى إضاءة",
                    type: TextInputType.number),
                _input(lowestPressureController, "أقل ضغط",
                    type: TextInputType.number),
                _input(highestPressureController, "أعلى ضغط",
                    type: TextInputType.number),
                _input(lowestVentController, "أقل تهوية",
                    type: TextInputType.number),
                _input(highestVentController, "أعلى تهوية",
                    type: TextInputType.number),
                const SizedBox(height: 12),
                const Text("معلومات الحاوية",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _input(nameContainerController, "اسم الحاوية"),
                _input(capacityController, "السعة", type: TextInputType.number),
                const SizedBox(height: 12),
                const Text("معلومات وسائط التخزين",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _input(nameStorageController, "اسم وسيلة التخزين"),
                _input(floorsController, "عدد الطوابق",
                    type: TextInputType.number),
                _input(classesController, "عدد الصفوف",
                    type: TextInputType.number),
                _input(positionsController, "عدد المواقع بالصف",
                    type: TextInputType.number),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("إلغاء"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final request = SupportedProductRequest(
                name: nameController.text,
                description: descriptionController.text,
                importCycle: importCycleController.text,
                quantity: int.parse(quantityController.text),
                typeId: selectedTypeId.toString(),
                unit: unitController.text,
                actualPiecePrice: double.parse(priceController.text),
                lowestTemperature: double.parse(lowestTempController.text),
                highestTemperature: double.parse(highestTempController.text),
                lowestHumidity: double.parse(lowestHumidityController.text),
                highestHumidity: double.parse(highestHumidityController.text),
                lowestLight: double.parse(lowestLightController.text),
                highestLight: double.parse(highestLightController.text),
                lowestPressure: double.parse(lowestPressureController.text),
                highestPressure: double.parse(highestPressureController.text),
                lowestVentilation: double.parse(lowestVentController.text),
                highestVentilation: double.parse(highestVentController.text),
                nameContainer: nameContainerController.text,
                capacity: int.parse(capacityController.text),
                nameStorageMedia: nameStorageController.text,
                numFloors: int.parse(floorsController.text),
                numClasses: int.parse(classesController.text),
                numPositionsOnClass: int.parse(positionsController.text),
              );

              try {
                print("📤 جاري إرسال الطلب إلى السيرفر...");
                print("🔧 البيانات المرسلة: ${request.toJson()}");

                final result = await ProductApi.supportNewProduct(request);

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        result ? 'تمت إضافة المنتج بنجاح' : 'فشل في الإضافة'),
                    backgroundColor: result ? Colors.green : Colors.red,
                  ));

                  // ✅ تحميل المنتجات مباشرة بدلاً من invalidate
                  ref.read(productProvider.notifier).loadFromBackend();
                }
              } catch (e) {
                print("❌ حدث استثناء أثناء حفظ المنتج:");
                print("🧾 $e");
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('خطأ: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            }
          },
          child: const Text("حفظ"),
        ),
      ],
    ),
  );
}

Widget _input(TextEditingController controller, String label,
    {TextInputType type = TextInputType.text, bool required = true}) {
  final isNumber = type == TextInputType.number;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) {
        if (required && (val == null || val.trim().isEmpty)) {
          return 'الحقل مطلوب';
        }
        if (isNumber && val != null && val.trim().isNotEmpty) {
          final parsed = num.tryParse(val.trim());
          if (parsed == null) return 'يجب إدخال رقم صالح';
        }
        return null;
      },
    ),
  );
}
