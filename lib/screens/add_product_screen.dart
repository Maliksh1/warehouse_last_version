import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/lang/app_localizations.dart';

class AddProductScreen extends ConsumerWidget {
  final String warehouseId;
  const AddProductScreen({super.key, required this.warehouseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final skuController = TextEditingController(text: '$warehouseId-');
    final quantityController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final sellPriceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.get('add_product'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                  controller: nameController,
                  decoration:
                      InputDecoration(labelText: t.get('product_name'))),
              TextFormField(
                  controller: skuController,
                  decoration: InputDecoration(labelText: t.get('sku'))),
              TextFormField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: t.get('quantity')),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: descController,
                  decoration: InputDecoration(labelText: t.get('description'))),
              TextFormField(
                  controller: priceController,
                  decoration:
                      InputDecoration(labelText: t.get('purchase_price')),
                  keyboardType: TextInputType.number),
              TextFormField(
                  controller: sellPriceController,
                  decoration:
                      InputDecoration(labelText: t.get('selling_price')),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final product = Product(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: nameController.text,
                      description: descController.text,
                      supplierId: 'default',
                      importCycle: '',
                      quantity: 40,
                      typeId: '',
                      unit: '',
                      actualPiecePrice: 20,
                    );
                    ref.read(productProvider.notifier).add(product);

                    Navigator.pop(context);
                  }
                },
                child: Text(t.get('save')),
              )
            ],
          ),
        ),
      ),
    );
  }
}
