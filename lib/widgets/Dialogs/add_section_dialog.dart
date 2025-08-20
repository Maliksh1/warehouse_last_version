import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/services/section_api.dart';

Future<bool?> showAddSectionDialog(
    BuildContext context, WidgetRef ref, Warehouse warehouse) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddSectionDialog(warehouse: warehouse),
  );
}

class AddSectionDialog extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const AddSectionDialog({super.key, required this.warehouse});

  @override
  ConsumerState<AddSectionDialog> createState() => _AddSectionDialogState();
}

class _AddSectionDialogState extends ConsumerState<AddSectionDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController();
  final _classesCtrl = TextEditingController();
  final _positionsCtrl = TextEditingController();

  int? _selectedProductId;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorsCtrl.dispose();
    _classesCtrl.dispose();
    _positionsCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'رقم غير صالح' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('رجاءً اختر المنتج الخاص بالقسم'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final wid = int.tryParse(widget.warehouse.id);
    if (wid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('معرّف مستودع غير صالح'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final payload = <String, dynamic>{
      "existable_type": "Warehouse", // كما يتوقع الباك
      "existable_id": wid,
      "product_id": _selectedProductId,
      "num_floors": int.parse(_floorsCtrl.text.trim()),
      "num_classes": int.parse(_classesCtrl.text.trim()),
      "num_positions_on_class": int.parse(_positionsCtrl.text.trim()),
      "name": _nameCtrl.text.trim(),
    };

    setState(() => _submitting = true);
    try {
      final ok = await SectionApi.createSection(payload);

      if (!mounted) return;

      Navigator.pop(context); // أغلق الديالوج أولًا

      if (ok) {
        // أعد تحميل أقسام هذا المستودع فقط
        ref.invalidate(warehouseSectionsProvider(wid));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تمت إضافة القسم بنجاح'),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('فشل إضافة القسم'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل الإرسال: $e'),
        backgroundColor: Colors.red,
      ));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // جميع المنتجات، ونفلترها على نوع المستودع إن توفّر typeId
    final products = ref.watch(productProvider);
    int? widTypeId = int.tryParse('${widget.warehouse.typeId ?? ''}'.trim());

    final filtered = (widTypeId == null)
        ? products
        : products.where((p) {
            final pType = int.tryParse('${p.typeId}'.trim());
            return pType != null && pType == widTypeId;
          }).toList();

    return AlertDialog(
      title: const Text('إضافة قسم'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // اختيار المنتج الخاص بالقسم
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'المنتج المخزَّن في هذا القسم (product_id)',
                  border: OutlineInputBorder(),
                ),
                items: filtered.map((p) {
                  final pid = int.tryParse('${p.id}') ?? -1;
                  return DropdownMenuItem<int>(
                    value: pid,
                    child: Text('${p.name} (id: $pid)'),
                  );
                }).toList(),
                onChanged: _submitting
                    ? null
                    : (v) => setState(() => _selectedProductId = v),
                validator: (v) => v == null ? 'مطلوب' : null,
              ),
              const SizedBox(height: 10),

              // اسم القسم
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  border: OutlineInputBorder(),
                ),
                validator: _req,
                enabled: !_submitting,
              ),
              const SizedBox(height: 10),

              // num_floors / num_classes
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _floorsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'عدد الطوابق (num_floors)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _intReq,
                      enabled: !_submitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _classesCtrl,
                      decoration: const InputDecoration(
                        labelText: 'عدد الصفوف (num_classes)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _intReq,
                      enabled: !_submitting,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // num_positions_on_class
              TextFormField(
                controller: _positionsCtrl,
                decoration: const InputDecoration(
                  labelText: 'عدد المواقع في الصف (num_positions_on_class)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _intReq,
                enabled: !_submitting,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_submitting ? 'جارٍ الحفظ...' : 'إضافة'),
        ),
      ],
    );
  }
}
