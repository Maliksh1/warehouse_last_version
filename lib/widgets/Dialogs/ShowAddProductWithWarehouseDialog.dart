import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/warehouse_provider.dart';

void showAddProductWithWarehouseDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final warehouses = ref.watch(warehouseProvider);

  final selectedWarehouse = ValueNotifier<String?>(null);
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final categoryIdController = TextEditingController();
  final supplierIdController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.get('add_product')),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown for warehouse
              ValueListenableBuilder<String?>(
                valueListenable: selectedWarehouse,
                builder: (_, value, __) {
                  return DropdownButtonFormField<String>(
                    value: value,
                    decoration: InputDecoration(
                      labelText: t.get('select_warehouse'),
                    ),
                    items: warehouses.map((w) {
                      return DropdownMenuItem(
                        value: w.id.toString(),
                        child: Text(w.name),
                      );
                    }).toList(),
                    onChanged: (val) => selectedWarehouse.value = val,
                    validator: (val) =>
                        val == null ? t.get('required_field') : null,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: t.get('product_name')),
                validator: (val) =>
                    val?.isEmpty ?? true ? t.get('required_field') : null,
              ),
              TextFormField(
                controller: skuController,
                decoration: InputDecoration(labelText: 'SKU'),
              ),
              TextFormField(
                controller: categoryIdController,
                decoration: InputDecoration(labelText: t.get('category')),
                validator: (val) =>
                    val?.isEmpty ?? true ? t.get('required_field') : null,
              ),
              TextFormField(
                controller: supplierIdController,
                decoration: InputDecoration(labelText: t.get('supplier')),
                validator: (val) =>
                    val?.isEmpty ?? true ? t.get('required_field') : null,
              ),
              TextFormField(
                controller: purchasePriceController,
                decoration: InputDecoration(labelText: t.get('cost')),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val?.isEmpty ?? true) return t.get('required_field');
                  final price = double.tryParse(val!);
                  if (price == null || price <= 0)
                    return t.get('invalid_price');
                  return null;
                },
              ),
              TextFormField(
                controller: sellingPriceController,
                decoration: InputDecoration(labelText: t.get('price')),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val?.isEmpty ?? true) return t.get('required_field');
                  final price = double.tryParse(val!);
                  if (price == null || price <= 0)
                    return t.get('invalid_price');
                  return null;
                },
              ),
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
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final newProduct = Product(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                importCycle: 'monthly', // Default import cycle
                quantity: 0, // Start with 0 quantity
                typeId: int.parse(categoryIdController.text),
                unit: 'piece', // Default unit
                actualPiecePrice:
                    double.tryParse(purchasePriceController.text) ?? 0.0,
                supplierId: supplierIdController.text,
              );

              ref.read(productProvider.notifier).add(newProduct);
              Navigator.pop(context);
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
