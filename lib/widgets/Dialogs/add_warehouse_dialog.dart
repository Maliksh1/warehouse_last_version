import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_provider.dart';

void showAddWarehouseDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final capacityController = TextEditingController();
  final unitController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(t.get('add_new_warehouse')),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: t.get('warehouse_name')),
                validator: (val) =>
                    val == null || val.isEmpty ? t.get('required_field') : null,
              ),
              TextFormField(
                controller: addressController,
                decoration:
                    InputDecoration(labelText: t.get('warehouse_location')),
              ),
              TextFormField(
                controller: capacityController,
                decoration:
                    InputDecoration(labelText: t.get('warehouse_capacity')),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: unitController,
                decoration: InputDecoration(labelText: 'وحدة السعة'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('cancel'))),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              final warehouse = Warehouse(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text,
                address: addressController.text,
                capacity: double.tryParse(capacityController.text) ?? 0,
                capacityUnit: unitController.text,
                occupied: 0,
                managerId: null,
                location: '',
                used: 1,
                manager: '',
                productIds: null,
                usedCapacity: null,
              );

              ref.read(warehouseProvider.notifier).add(warehouse);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(t.get('warehouse_added_successfully')),
                backgroundColor: Colors.green,
              ));
            }
          },
          child: Text(t.get('save')),
        ),
      ],
    ),
  );
}
