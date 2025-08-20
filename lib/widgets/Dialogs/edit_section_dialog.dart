// widgets/Dialogs/edit_section_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';
import 'package:warehouse/services/section_api.dart';

class EditSectionDialog extends ConsumerStatefulWidget {
  final WarehouseSection section;

  const EditSectionDialog({super.key, required this.section});

  @override
  ConsumerState<EditSectionDialog> createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends ConsumerState<EditSectionDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  // الحقول الرقمية اختيارية — لا نعتمد على خصائص غير موجودة بالموديل
  final TextEditingController _floorsCtrl = TextEditingController();
  final TextEditingController _classesCtrl = TextEditingController();
  final TextEditingController _positionsCtrl = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.section.name);

    // لو موديلك فيه قيم أولية بهالأسماء، ممكن تعبّيها هنا لاحقًا:
    // _floorsCtrl.text = widget.section.numFloors?.toString() ?? '';
    // _classesCtrl.text = widget.section.numClasses?.toString() ?? '';
    // _positionsCtrl.text = widget.section.numPositionsOnClass?.toString() ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorsCtrl.dispose();
    _classesCtrl.dispose();
    _positionsCtrl.dispose();
    super.dispose();
  }

  String? _intOpt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return int.tryParse(v.trim()) == null ? 'عدد صحيح غير صالح' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final id = int.tryParse(widget.section.id);
    final wid = int.tryParse(widget.section.warehouseId);
    if (id == null || wid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('معرّفات غير صالحة'),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => _isSaving = false);
      return;
    }

    final String? name =
        _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim();
    final int? nf = _floorsCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_floorsCtrl.text.trim());
    final int? nc = _classesCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_classesCtrl.text.trim());
    final int? np = _positionsCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_positionsCtrl.text.trim());

    // ✅ استخدم كائن SectionApi ومرّر sectionId بدل id
    final api = SectionApi();
    final bool ok = await SectionApi.editSection(
      sectionId: id,
      name: name,
      numFloors: nf,
      numClasses: nc,
      numPositionsOnClass: np,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      Navigator.pop(context, true); // <— تأكد أنها context وليس co…ntext
      ref.invalidate(warehouseSectionsProvider(wid));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم تحديث القسم بنجاح'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'فشل التحديث (ربما تم تجاوز 30 دقيقة أو توجد وسائط تخزين مرتبطة)'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _confirmDelete() async {
    final id = int.tryParse(widget.section.id);
    final wid = int.tryParse(widget.section.warehouseId);
    if (id == null || wid == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف القسم "${widget.section.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final api = SectionApi();
    final bool ok = await api.deleteSection(id);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
      ref.invalidate(warehouseSectionsProvider(wid));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم حذف القسم'),
        backgroundColor: Colors.green,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('فشل الحذف (غالبًا توجد وسائط تخزين على هذا القسم)'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل القسم'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم القسم'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _floorsCtrl,
                decoration:
                    const InputDecoration(labelText: 'num_floors (اختياري)'),
                keyboardType: TextInputType.number,
                validator: _intOpt,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _classesCtrl,
                decoration:
                    const InputDecoration(labelText: 'num_classes (اختياري)'),
                keyboardType: TextInputType.number,
                validator: _intOpt,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _positionsCtrl,
                decoration: const InputDecoration(
                    labelText: 'num_positions_on_class (اختياري)'),
                keyboardType: TextInputType.number,
                validator: _intOpt,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: _isSaving ? null : _confirmDelete,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('حذف القسم'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تحديث'),
        ),
      ],
    );
  }
}
