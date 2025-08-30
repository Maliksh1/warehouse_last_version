import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/garage_api.dart';

/// تعرض سلسلة من الحوارات لإضافة كراج جديد.
///
/// يمكنها الآن تخطي خطوات الاختيار إذا تم توفير مكان محدد مسبقًا.
Future<bool?> showAddGarageDialog(
  BuildContext context,
  WidgetRef ref, {
  String? preselectedPlaceType,
  int? preselectedPlaceId,
}) async {
  String? finalPlaceType = preselectedPlaceType;
  int? finalPlaceId = preselectedPlaceId;

  // إذا لم يكن المكان محددًا مسبقًا، قم بتشغيل خطوات الاختيار
  if (finalPlaceType == null || finalPlaceId == null) {
    // المرحلة الأولى: اختيار نوع المكان
    finalPlaceType = await _showSelectPlaceTypeDialog(context);
    if (finalPlaceType == null) return false; // تم الإلغاء

    // المرحلة الثانية: اختيار المكان المحدد
    finalPlaceId =
        await _showSelectPlaceInstanceDialog(context, ref, finalPlaceType);
    if (finalPlaceId == null) return false; // تم الإلغاء
  }

  // المرحلة الثالثة: إدخال التفاصيل وإنشاء الكراج (تعمل لكلا الحالتين)
  final bool? success = await _showCreateGarageDetailsDialog(
      context, ref, finalPlaceType, finalPlaceId);

  // تحديث القائمة الصحيحة بعد الإضافة
  if (success == true) {
    if (preselectedPlaceId != null && preselectedPlaceType != null) {
      // تحديث القائمة المفلترة
      ref.invalidate(garageItemsByPlaceProvider(GarageParameter(
          placeType: preselectedPlaceType, placeId: preselectedPlaceId)));
    } else {
      // تحديث القائمة العامة
      ref.invalidate(garageItemsListProvider);
    }
  }

  return success;
}

// الحوار الخاص بالمرحلة الأولى: اختيار نوع المكان
Future<String?> _showSelectPlaceTypeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Garage'),
      content: const Text('Where do you want to add the new garage?'),
      actions: [
        TextButton(
          child: const Text('Warehouse'),
          onPressed: () =>
              Navigator.of(ctx).pop('Warehouse'), // ✅ تم التصحيح إلى اسم الكلاس
        ),
        TextButton(
          child: const Text('Distribution Center'),
          onPressed: () => Navigator.of(ctx)
              .pop('DistributionCenter'), // ✅ تم التصحيح إلى اسم الكلاس
        ),
      ],
    ),
  );
}

// الحوار الخاص بالمرحلة الثانية: اختيار المستودع أو مركز التوزيع
Future<int?> _showSelectPlaceInstanceDialog(
    BuildContext context, WidgetRef ref, String placeType) {
  final provider = placeType == 'Warehouse'
      ? warehousesProvider
      : distributionCentersListProvider;

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Select a ${placeType.replaceAll('_', ' ')}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Consumer(
          builder: (context, ref, child) {
            final asyncValue = ref.watch(provider);
            return asyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No places found.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (lCtx, i) {
                    final item = items[i];
                    // ✅ --- تصحيح منطق استخلاص ID والاسم ---
                    final int id = (item is Warehouse)
                        ? item.id
                        : (item as DistributionCenter).id;
                    final String name = (item is Warehouse)
                        ? item.name
                        : (item as DistributionCenter).name;

                    return ListTile(
                      title: Text(name),
                      onTap: () => Navigator.of(ctx).pop(id),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

// الحوار الخاص بالمرحلة الثالثة: إدخال تفاصيل الكراج
Future<bool?> _showCreateGarageDetailsDialog(
    BuildContext context, WidgetRef ref, String placeType, int placeId) {
  String? selectedSize;
  final capacityController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ✅ ---  هذا هو التصحيح ---
  // قائمة الأحجام المسموح بها من قبل الخادم
  final List<String> vehicleSizes = ['medium', 'big'];

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Garage Details'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
              validator: (value) {
                if (value == null) {
                  return 'Please select a vehicle size.';
                }
                return null;
              },
            ),
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
          child: const Text('Add'),
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final success = await GarageApi.createGarage(
                placeType: placeType,
                placeId: placeId,
                sizeOfVehicle: selectedSize!,
                maxCapacity: int.parse(capacityController.text),
              );
              if (ctx.mounted) Navigator.of(ctx).pop(success);
            }
          },
        ),
      ],
    ),
  );
}

// دالة مساعدة لجعل الحرف الأول كبيراً (لتحسين العرض)
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
