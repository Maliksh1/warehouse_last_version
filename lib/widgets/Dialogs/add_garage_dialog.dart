// lib/widgets/Dialogs/add_garage_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/garage_api.dart';

/// تعرض سلسلة من الحوارات لإضافة كراج جديد باستخدام Riverpod.
///
/// The main function now requires a BuildContext and a WidgetRef.
Future<bool> showAddGarageDialog(BuildContext context, WidgetRef ref) async {
  // المرحلة الأولى: اختيار نوع المكان
  final String? placeType = await _showSelectPlaceTypeDialog(context);
  if (placeType == null) return false; // تم الإلغاء

  // المرحلة الثانية: اختيار المكان المحدد
  final int? placeId =
      await _showSelectPlaceInstanceDialog(context, ref, placeType);
  if (placeId == null) return false; // تم الإلغاء

  // المرحلة الثالثة: إدخال التفاصيل وإنشاء الكراج
  final bool? success =
      await _showCreateGarageDetailsDialog(context, ref, placeType, placeId);
  return success ?? false;
}

// الحوار الخاص بالمرحلة الأولى: اختيار نوع المكان (لا يتغير)
Future<String?> _showSelectPlaceTypeDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add Garage'),
      content: const Text('Where do you want to add the new garage?'),
      actions: [
        TextButton(
          child: const Text('Warehouse'),
          onPressed: () => Navigator.of(ctx).pop('warehouse'),
        ),
        TextButton(
          child: const Text('Distribution Center'),
          onPressed: () => Navigator.of(ctx).pop('distribution_center'),
        ),
      ],
    ),
  );
}

// الحوار الخاص بالمرحلة الثانية: اختيار المستودع أو مركز التوزيع (مُعدَّل لـ Riverpod)
Future<int?> _showSelectPlaceInstanceDialog(
    BuildContext context, WidgetRef ref, String placeType) {
  // --- هنا التصحيح الرئيسي ---
  // تحديد النوع بشكل صريح ليتمكن المترجم من فهمه
  final dynamic provider =
      placeType == 'warehouse'
          ? warehousesProvider
          : distributionCentersListProvider;

  return showDialog<int>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Select a ${placeType.replaceAll('_', ' ')}'),
      content: SizedBox(
        width: double.maxFinite,
        // استخدام Consumer لقراءة حالة الـ provider
        child: Consumer(
          builder: (context, ref, child) {
            // الآن سيعمل هذا السطر بدون مشاكل
            final asyncValue = ref.watch(provider);
            // التعامل مع حالات التحميل والخطأ والبيانات
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
                    // --- تصحيح ثانوي: تحديد النوع int بشكل مباشر ---
                    final int id = (item is Warehouse)
                        ? int.parse(item.id)
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

// الحوار الخاص بالمرحلة الثالثة: إدخال تفاصيل الكراج (مُعدَّل لـ Riverpod)
Future<bool?> _showCreateGarageDetailsDialog(
    BuildContext context, WidgetRef ref, String placeType, int placeId) {
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('New Garage Details'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: locationController,
          decoration: const InputDecoration(labelText: 'Garage Location'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a location.';
            }
            return null;
          },
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
              final success = await GarageApi.createGarage({
                'location': locationController.text,
                'place_type': placeType,
                'place_id': placeId,
              });

              if (success) {
                // عند النجاح، نقوم بتحديث قائمة الكراجات
                ref.refresh(garageItemsListProvider);
              }

              if (ctx.mounted) Navigator.of(ctx).pop(success);
            }
          },
        ),
      ],
    ),
  );
}
