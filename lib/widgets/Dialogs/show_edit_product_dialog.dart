import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/product_types_provider.dart';
import 'package:warehouse/providers/api_service_provider.dart';

void showEditProductDialog(
  BuildContext context,
  WidgetRef ref, {
  required Product product,
}) {
  final t = AppLocalizations.of(context)!;

  // controllers مهيأة من المنتج الحالي
  final nameCtrl = TextEditingController(text: product.name);
  final descCtrl = TextEditingController(text: product.description ?? '');
  final importCycleCtrl = TextEditingController(
      text: product.importCycle.toString()); // قد يكون رقم/نص
  final qtyCtrl = TextEditingController(text: product.quantity.toString());
  final unitCtrl = TextEditingController(text: product.unit);
  final priceCtrl =
      TextEditingController(text: product.actualPiecePrice.toString());
  final lowTempCtrl = TextEditingController();
  final highTempCtrl = TextEditingController();
  final lowHumCtrl = TextEditingController();
  final highHumCtrl = TextEditingController();
  final lowLightCtrl = TextEditingController();
  final highLightCtrl = TextEditingController();
  final lowPressCtrl = TextEditingController();
  final highPressCtrl = TextEditingController();
  final lowVentCtrl = TextEditingController();
  final highVentCtrl = TextEditingController();

  // النوع الحالي
  int? selectedTypeId = int.tryParse(product.typeId.toString());

  final formKey = GlobalKey<FormState>();

  // نُغلق الكنترولرز بعد إغلاق الديالوج بالكامل
  void _disposeAll() {
    nameCtrl.dispose();
    descCtrl.dispose();
    importCycleCtrl.dispose();
    qtyCtrl.dispose();
    unitCtrl.dispose();
    priceCtrl.dispose();
    lowTempCtrl.dispose();
    highTempCtrl.dispose();
    lowHumCtrl.dispose();
    highHumCtrl.dispose();
    lowLightCtrl.dispose();
    highLightCtrl.dispose();
    lowPressCtrl.dispose();
    highPressCtrl.dispose();
    lowVentCtrl.dispose();
    highVentCtrl.dispose();
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(t.get('edit_product') ?? 'تعديل منتج'),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _text(nameCtrl, t.get('name') ?? 'الاسم'),
                const SizedBox(height: 8),
                _text(descCtrl, t.get('description') ?? 'الوصف', maxLines: 2),
                const SizedBox(height: 8),
                Consumer(builder: (context, ref, _) {
                  final typesAsync = ref.watch(productTypesProvider);
                  return typesAsync.when(
                    data: (types) {
                      final items = types.whereType<Map>().map((e) {
                        final id = (e['id'] as num).toInt();
                        final name = (e['name'] ?? '').toString();
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(name.isEmpty ? 'ID $id' : name),
                        );
                      }).toList();

                      return DropdownButtonFormField<int>(
                        value: selectedTypeId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'نوع المنتج (type_id)',
                          border: OutlineInputBorder(),
                        ),
                        items: items,
                        onChanged: (v) => selectedTypeId = v,
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Text('خطأ بتحميل الأنواع: $e'),
                  );
                }),
                const SizedBox(height: 8),
                _text(unitCtrl, 'unit'),
                const SizedBox(height: 8),
                _num(priceCtrl, 'actual_piece_price'),
                const SizedBox(height: 8),
                _num(qtyCtrl, 'quantity'),
                const SizedBox(height: 8),
                _text(importCycleCtrl, 'import_cycle'),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('شروط التخزين (اختياري)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _num(lowTempCtrl, 'lowest_temperature',
                          required: false)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _num(highTempCtrl, 'highest_temperature',
                          required: false)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child:
                          _num(lowHumCtrl, 'lowest_humidity', required: false)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _num(highHumCtrl, 'highest_humidity',
                          required: false)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child:
                          _num(lowLightCtrl, 'lowest_light', required: false)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _num(highLightCtrl, 'highest_light',
                          required: false)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _num(lowPressCtrl, 'lowest_pressure',
                          required: false)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _num(highPressCtrl, 'highest_pressure',
                          required: false)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _num(lowVentCtrl, 'lowest_ventilation',
                          required: false)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _num(highVentCtrl, 'highest_ventilation',
                          required: false)),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(t.get('cancel') ?? 'إلغاء'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;

            // ابنِ payload وفق الباك
            final payload = <String, dynamic>{
              'product_id': int.tryParse(product.id) ?? product.id, // إلزامي
              if (nameCtrl.text.trim().isNotEmpty) 'name': nameCtrl.text.trim(),
              if (selectedTypeId != null) 'type_id': selectedTypeId,

              if (descCtrl.text.trim().isNotEmpty)
                'description': descCtrl.text.trim(),

              if (qtyCtrl.text.trim().isNotEmpty)
                'quantity': int.parse(qtyCtrl.text.trim()),

              if (unitCtrl.text.trim().isNotEmpty) 'unit': unitCtrl.text.trim(),

              if (priceCtrl.text.trim().isNotEmpty)
                'actual_piece_price': num.parse(priceCtrl.text.trim()),

              if (importCycleCtrl.text.trim().isNotEmpty)
                'import_cycle': num.tryParse(importCycleCtrl.text.trim()) ??
                    importCycleCtrl.text.trim(),

              if (lowTempCtrl.text.trim().isNotEmpty)
                'lowest_temperature': num.parse(lowTempCtrl.text.trim()),
              if (highTempCtrl.text.trim().isNotEmpty)
                'highest_temperature': num.parse(highTempCtrl.text.trim()),
              if (lowHumCtrl.text.trim().isNotEmpty)
                'lowest_humidity': num.parse(lowHumCtrl.text.trim()),
              if (highHumCtrl.text.trim().isNotEmpty)
                'highest_humidity': num.parse(highHumCtrl.text.trim()),
              if (lowLightCtrl.text.trim().isNotEmpty)
                'lowest_light': num.parse(lowLightCtrl.text.trim()),
              if (highLightCtrl.text.trim().isNotEmpty)
                'highest_light': num.parse(highLightCtrl.text.trim()),
              if (lowPressCtrl.text.trim().isNotEmpty)
                'lowest_pressure': num.parse(lowPressCtrl.text.trim()),
              if (highPressCtrl.text.trim().isNotEmpty)
                'highest_pressure': num.parse(highPressCtrl.text.trim()),
              if (lowVentCtrl.text.trim().isNotEmpty)
                'lowest_ventilation': num.parse(lowVentCtrl.text.trim()),
              if (highVentCtrl.text.trim().isNotEmpty)
                'highest_ventilation': num.parse(highVentCtrl.text.trim()),
              // إن أردت رفع صورة لاحقًا: أرسل multipart بالحقل img_path
            };

            try {
              final api = ref.read(apiServiceProvider);
              final res = await api.editProduct(payload);

              if (!context.mounted) return;
              Navigator.pop(context);

              final msg =
                  (res['msg'] ?? 'Product updated successfully.').toString();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(msg), backgroundColor: Colors.green),
              );

              // أحدث القائمة
              ref.invalidate(productsListProvider);
              ref.read(productProvider.notifier).loadFromBackend();
            } catch (e) {
              if (!context.mounted) return;
              // يعرض رسالة 403 مثل: "You can't edit name, or type after 30 minutes."
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(e.toString()), backgroundColor: Colors.red),
              );
            }
          },
          child: Text(t.get('save') ?? 'حفظ'),
        ),
      ],
    ),
  ).whenComplete(_disposeAll);
}

// حقول مساعدة
Widget _text(TextEditingController c, String label,
    {int maxLines = 1, bool required = false}) {
  return TextFormField(
    controller: c,
    maxLines: maxLines,
    decoration:
        InputDecoration(labelText: label, border: const OutlineInputBorder()),
    validator: (v) {
      if (required && (v == null || v.trim().isEmpty)) return 'الحقل مطلوب';
      return null;
    },
  );
}

Widget _num(TextEditingController c, String label, {bool required = true}) {
  return TextFormField(
    controller: c,
    keyboardType: TextInputType.number,
    decoration:
        InputDecoration(labelText: label, border: const OutlineInputBorder()),
    validator: (v) {
      if (!required && (v == null || v.trim().isEmpty)) return null;
      if (v == null || v.trim().isEmpty) return 'الحقل مطلوب';
      final n = num.tryParse(v.trim());
      if (n == null) return 'يجب إدخال رقم صالح';
      return null;
    },
  );
}
