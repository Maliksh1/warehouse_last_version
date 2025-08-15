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
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.section.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await SectionApi.editSection(
        id: int.parse(widget.section.id),
        name: _nameController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ref.invalidate(
              warehouseSectionsProvider(int.parse(widget.section.warehouseId)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل القسم'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'اسم القسم'),
          validator: (val) => val == null || val.isEmpty ? 'مطلوب' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('تحديث'),
        ),
      ],
    );
  }
}
