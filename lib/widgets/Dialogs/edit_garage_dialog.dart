import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/garage_item.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/garage_api.dart';

/// يعرض حوارًا لتعديل تفاصيل كراج موجود.
Future<bool?> showEditGarageDialog(
    BuildContext context, WidgetRef ref, GarageItem garage) async {
  String? selectedSize = garage.sizeOfVehicle;
  final capacityController =
      TextEditingController(text: garage.maxCapacity.toString());
  final formKey = GlobalKey<FormState>();

  // قائمة الأحجام المسموح بها من قبل الخادم
  final List<String> vehicleSizes = ['medium', 'big'];

  final success = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Edit Garage (ID: ${garage.id})'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // القائمة المنسدلة لاختيار الحجم
            DropdownButtonFormField<String>(
              value: selectedSize,
              hint: const Text('Select Vehicle Size'),
              items: vehicleSizes.map((String size) {
                return DropdownMenuItem<String>(
                  value: size,
                  child: Text(size.capitalize()),
                );
              }).toList(),
              onChanged: (newValue) {
                selectedSize = newValue;
              },
              validator: (value) =>
                  value == null ? 'Please select a vehicle size.' : null,
            ),
            // حقل إدخال السعة القصوى
            TextFormField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Max Capacity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty ||
                    int.tryParse(value) == null) {
                  return 'Please enter a valid number.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        ElevatedButton(
          child: const Text('Save Changes'),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              // بناء الـ payload فقط بالقيم التي تغيرت (أو كل القيم للتسهيل)
              final payload = {
                'garage_id': garage.id,
                'size_of_vehicle': selectedSize!,
                'max_capacity': int.parse(capacityController.text),
              };

              final result = await GarageApi.editGarage(payload);
              if (ctx.mounted) Navigator.of(ctx).pop(result);
            }
          },
        ),
      ],
    ),
  );

  // تحديث القائمة الصحيحة بعد التعديل
  if (success == true) {
    ref.invalidate(garageItemsByPlaceProvider(
        GarageParameter(placeType: garage.placeType, placeId: garage.placeId)));
    ref.invalidate(garageItemsListProvider); // تحديث القائمة العامة أيضًا
  }

  return success;
}

// دالة مساعدة لجعل الحرف الأول كبيراً
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
