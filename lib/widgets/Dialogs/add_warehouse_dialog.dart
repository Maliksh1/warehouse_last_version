import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/providers/product_types_provider.dart'; // ⬅️ نستخدمه للأنواع

Future<bool?> showAddWarehouseDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;

  final nameCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final numSectionsCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? _req(String? v) => (v == null || v.trim().isEmpty)
      ? (t.get('required_field') ?? 'مطلوب')
      : null;
  String? _numReq(String? v) {
    if (v == null || v.trim().isEmpty)
      return (t.get('required_field') ?? 'مطلوب');
    return num.tryParse(v.trim()) == null
        ? (t.get('invalid_number') ?? 'رقم غير صالح')
        : null;
  }

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty)
      return (t.get('required_field') ?? 'مطلوب');
    return int.tryParse(v.trim()) == null
        ? (t.get('invalid_number') ?? 'رقم غير صالح')
        : null;
  }

  int? selectedTypeId; // ⬅️ سنملؤه من الـ Dropdown
  bool isLoading = false;

  Future<void> _save(StateSetter setState) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t.get('please_select_type') ?? 'اختر نوع المستودع')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    final payload = <String, dynamic>{
      "name": nameCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "latitude": double.parse(latCtrl.text.trim()),
      "longitude": double.parse(lngCtrl.text.trim()),
      "type_id": selectedTypeId, // ⬅️ من القائمة
      "num_sections": int.parse(numSectionsCtrl.text.trim()),
    };

    try {
      final ok = await WarehouseApi.createWarehouse(payload);
      if (!context.mounted) return;

      if (ok) {
        await ref.read(warehouseProvider.notifier).reload();
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('warehouse_added_successfully') ??
                'تمت إضافة المستودع بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.get('save_failed') ?? 'فشل الحفظ'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(t.get('add_new_warehouse') ?? 'إضافة مستودع'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                        labelText: t.get('warehouse_name') ?? 'اسم المستودع'),
                    validator: _req,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: locationCtrl,
                    decoration: InputDecoration(
                        labelText: t.get('warehouse_location') ?? 'العنوان'),
                    validator: _req,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: latCtrl,
                          decoration:
                              const InputDecoration(labelText: 'latitude'),
                          keyboardType: TextInputType.number,
                          validator: _numReq,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: lngCtrl,
                          decoration:
                              const InputDecoration(labelText: 'longitude'),
                          keyboardType: TextInputType.number,
                          validator: _numReq,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ⬇️ Dropdown للنوع (من مزوّد الأنواع)
                  Consumer(builder: (context, ref, _) {
                    final typesAsync = ref.watch(productTypesProvider);
                    return typesAsync.when(
                      data: (types) {
                        final items = types.whereType<Map>().map((e) {
                          final id = (e['id'] as num).toInt();
                          final name = (e['name'] ?? '').toString();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text(name),
                          );
                        }).toList();

                        return DropdownButtonFormField<int>(
                          value: selectedTypeId,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'نوع المستودع (type_id)',
                            border: OutlineInputBorder(),
                          ),
                          items: items,
                          onChanged: (v) => setState(() => selectedTypeId = v),
                          validator: (v) => v == null
                              ? (t.get('required_field') ?? 'مطلوب')
                              : null,
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                      error: (e, _) => Text('خطأ بتحميل الأنواع: $e'),
                    );
                  }),

                  const SizedBox(height: 8),
                  TextFormField(
                    controller: numSectionsCtrl,
                    decoration:
                        const InputDecoration(labelText: 'num_sections'),
                    keyboardType: TextInputType.number,
                    validator: _intReq,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context, false),
              child: Text(t.get('cancel') ?? 'إلغاء'),
            ),
            ElevatedButton.icon(
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    )
                  : const Icon(Icons.save),
              label: Text(isLoading
                  ? (t.get('saving') ?? 'جارٍ الحفظ...')
                  : (t.get('save') ?? 'حفظ')),
              onPressed: isLoading ? null : () => _save(setState),
            ),
          ],
        );
      },
    ),
  );
}
