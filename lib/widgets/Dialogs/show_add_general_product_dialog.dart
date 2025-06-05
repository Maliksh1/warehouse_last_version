// lib/widgets/dialogs/show_add_general_product_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/lang/app_localizations.dart';

void showAddGeneralProductDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final importCycleController = TextEditingController();
  final quantityController = TextEditingController();
  final typeIdController = TextEditingController();
  final unitController = TextEditingController();
  final priceController = TextEditingController();
  final supplierIdController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final uuid = const Uuid();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.get('add_product')),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(nameController, t.get('product_name')),
              _input(descriptionController, t.get('description')),
              _input(importCycleController, t.get('import_cycle')),
              _input(quantityController, t.get('quantity'),
                  type: TextInputType.number),
              _input(typeIdController, t.get('type')),
              _input(unitController, t.get('unit')),
              _input(priceController, t.get('price'),
                  type: TextInputType.number),
              _input(supplierIdController, t.get('supplier_id')),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.get('cancel')),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              final newProduct = Product(
                id: uuid.v4(),
                name: nameController.text,
                description: descriptionController.text,
                importCycle: importCycleController.text,
                quantity: int.tryParse(quantityController.text) ?? 0,
                typeId: typeIdController.text,
                unit: unitController.text,
                actualPiecePrice: double.tryParse(priceController.text) ?? 0.0,
                supplierId: supplierIdController.text,
              );

              ref.read(productProvider.notifier).add(newProduct);

              await Future.delayed(const Duration(milliseconds: 300));

              if (context.mounted) {
                Navigator.of(context).pop();
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.get('product_added_successfully')),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text(t.get('save')),
        ),
      ],
    ),
  );
}

Widget _input(TextEditingController controller, String label,
    {TextInputType type = TextInputType.text}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (val) => val == null || val.isEmpty ? 'الحقل مطلوب' : null,
    ),
  );
}
