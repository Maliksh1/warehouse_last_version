// lib/widgets/Dialogs/add_supplier_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/suppliers_api.dart';

Future<bool?> showAddSupplierDialog(BuildContext context, WidgetRef ref) {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final identifierCtrl = TextEditingController();
  final communicationCtrl = TextEditingController();

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Add New Supplier'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: countryCtrl,
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: identifierCtrl,
                decoration: const InputDecoration(
                    labelText: 'Identifier (e.g., Tax ID)'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: communicationCtrl,
                decoration: const InputDecoration(
                    labelText: 'Communication (e.g., Email/Phone)'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final success = await SuppliersApi.createSupplier({
                "name": nameCtrl.text,
                "country": countryCtrl.text,
                "identifier": identifierCtrl.text,
                "comunication_way": communicationCtrl.text,
              });
              if (success) {
                ref.refresh(suppliersListProvider); // Refresh the list
              }
              if (ctx.mounted) Navigator.of(ctx).pop(success);
            }
          },
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
