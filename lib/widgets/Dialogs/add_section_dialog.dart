import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';
import 'package:warehouse/services/section_api.dart';

void showAddSectionDialog(
    BuildContext context, WidgetRef ref, Warehouse warehouse) {
  showDialog(
    context: context,
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
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await SectionApi.createSection(
        warehouseId: int.parse(widget.warehouse.id),
        name: _nameController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        if (success) {
          ref.invalidate(
              warehouseSectionsProvider(int.parse(widget.warehouse.id)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة قسم'),
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
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
