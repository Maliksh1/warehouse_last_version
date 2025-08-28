// lib/widgets/Dialogs/add_supply_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/storage_media.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/suppliers_api.dart';

Future<bool?> showAddSupplyDialog(
    BuildContext context, WidgetRef ref, int supplierId) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => _AddSupplyDialogContent(supplierId: supplierId),
  );
}

class _AddSupplyDialogContent extends ConsumerStatefulWidget {
  final int supplierId;
  const _AddSupplyDialogContent({required this.supplierId});

  @override
  ConsumerState<_AddSupplyDialogContent> createState() =>
      _AddSupplyDialogContentState();
}

class _AddSupplyDialogContentState
    extends ConsumerState<_AddSupplyDialogContent> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryTimeCtrl = TextEditingController();
  String _supplyType = 'Product'; // 'Product' or 'Storage_media'
  dynamic _selectedSupply;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Supply'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Choose Supply Type
              DropdownButtonFormField<String>(
                value: _supplyType,
                items: const [
                  DropdownMenuItem(value: 'Product', child: Text('Product')),
                  DropdownMenuItem(
                      value: 'Storage_media', child: Text('Storage Media')),
                ],
                onChanged: (value) {
                  setState(() {
                    _supplyType = value!;
                    _selectedSupply = null; // Reset selection
                  });
                },
                decoration: const InputDecoration(labelText: 'Type of Supply'),
              ),
              const SizedBox(height: 16),
              // 2. Choose Specific Item
              _buildItemSelector(),
              const SizedBox(height: 16),
              // 3. Input Delivery Time
              TextFormField(
                controller: _deliveryTimeCtrl,
                decoration: const InputDecoration(
                    labelText: 'Max Delivery Time (Days)'),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty || int.tryParse(val) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildItemSelector() {
    if (_supplyType == 'Product') {
      final productsAsync = ref.watch(productsListProvider);
      return productsAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => const Text('Could not load products'),
        data: (products) => DropdownButtonFormField<Product>(
          hint: const Text('Select a Product'),
          value: _selectedSupply,
          items: products
              .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedSupply = val),
          validator: (val) => val == null ? 'Required' : null,
        ),
      );
    } else {
      // Storage_media
      final mediaAsync = ref.watch(storageMediaListProvider);
      return mediaAsync.when(
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => const Text('Could not load media'),
        data: (media) => DropdownButtonFormField<StorageMedia>(
          hint: const Text('Select a Storage Media'),
          value: _selectedSupply,
          items: media
              .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
              .toList(),
          onChanged: (val) => setState(() => _selectedSupply = val),
          validator: (val) => val == null ? 'Required' : null,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "supplier_id": widget.supplierId,
        "suppliesable_type": _supplyType,
        "suppliesable_id": _selectedSupply.id,
        "max_delivery_time_by_days": int.parse(_deliveryTimeCtrl.text),
      };

      final success = await SuppliersApi.addSupplyToSupplier(payload);
      if (mounted) {
        Navigator.of(context).pop(success);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'Supply added!'
              : SuppliersApi.lastErrorMessage ?? 'Failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
      }
    }
  }
}
