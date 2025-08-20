import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/providers/product_types_provider.dart'; // ⬅️ الأنواع

Future<bool?> showEditWarehouseDialog(
    BuildContext context, WidgetRef ref, Warehouse w) {
  final t = AppLocalizations.of(context)!;

  final nameCtrl = TextEditingController(text: w.name);
  final locationCtrl = TextEditingController(text: w.location);
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final numSectionsCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? _numOpt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return num.tryParse(v.trim()) == null ? t.get('invalid_number') : null;
  }

  String? _intOpt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? t.get('invalid_number') : null;
  }

  int? selectedTypeId = w.typeId; // ⬅️ قيمة مبدئية (قد تكون null)
  bool saving = false;

  Future<void> _save() async {
    final idInt = int.tryParse(w.id);
    if (idInt == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Invalid id: ${w.id}')));
      return;
    }

    // لا نرسل type_id إن لم يتغيّر (لتفادي 403 بعد 30 دقيقة من الإنشاء)
    final int? typeIdToSend =
        (selectedTypeId != null && selectedTypeId != w.typeId)
            ? selectedTypeId
            : null;

    saving = true;
    (context as Element).markNeedsBuild();

    final ok = await WarehouseApi.editWarehouse(
      warehouseId: idInt,
      name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
      location:
          locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
      latitude: latCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(latCtrl.text.trim()),
      longitude: lngCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(lngCtrl.text.trim()),
      typeId: typeIdToSend, // ⬅️ فقط إن تغيّر
      numSections: numSectionsCtrl.text.trim().isEmpty
          ? null
          : int.tryParse(numSectionsCtrl.text.trim()),
    );

    if (ok) {
      await ref.read(warehouseProvider.notifier).reload();
      if (!context.mounted) return;
      Navigator.pop(context, true);
    } else {
      saving = false;
      (context as Element).markNeedsBuild();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t.get('save_failed') ?? 'فشل الحفظ'),
            backgroundColor: Colors.red),
      );
    }
  }

  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.get('edit_warehouse') ?? 'تعديل مستودع'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: InputDecoration(labelText: t.get('warehouse_name')),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: locationCtrl,
                decoration:
                    InputDecoration(labelText: t.get('warehouse_location')),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: latCtrl,
                      decoration: const InputDecoration(
                          labelText: 'latitude (optional)'),
                      keyboardType: TextInputType.number,
                      validator: _numOpt,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: lngCtrl,
                      decoration: const InputDecoration(
                          labelText: 'longitude (optional)'),
                      keyboardType: TextInputType.number,
                      validator: _numOpt,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ⬇️ Dropdown نوع المستودع (اختياري — لا نرسله إن لم يتغيّر)
              Consumer(builder: (context, ref, _) {
                final typesAsync = ref.watch(productTypesProvider);
                return typesAsync.when(
                  data: (types) {
                    final items = types.whereType<Map>().map((e) {
                      final id = (e['id'] as num).toInt();
                      final name = (e['name'] ?? '').toString();
                      return DropdownMenuItem<int>(
                          value: id, child: Text(name));
                    }).toList();

                    return DropdownButtonFormField<int>(
                      value: selectedTypeId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'نوع المستودع (اختياري)',
                        border: OutlineInputBorder(),
                      ),
                      items: items,
                      onChanged: (v) {
                        selectedTypeId = v;
                      },
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
                    const InputDecoration(labelText: 'num_sections (optional)'),
                keyboardType: TextInputType.number,
                validator: _intOpt,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: Text(t.get('cancel') ?? 'إلغاء'),
        ),
        ElevatedButton.icon(
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                )
              : const Icon(Icons.save),
          label: Text(saving
              ? (t.get('saving') ?? 'جارٍ الحفظ...')
              : (t.get('save') ?? 'حفظ')),
          onPressed: saving ? null : _save,
        ),
      ],
    ),
  );
}
