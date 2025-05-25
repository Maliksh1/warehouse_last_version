import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
// افترض أن providers و models موجودة في هذه المسارات أو قم بتعديلها
// import 'package:warehouse/providers/data_providers.dart'; // ستحتاج إلى addWarehouseProvider هنا
// import 'package:warehouse/models/warehouse.dart'; // إذا كنت ستنشئ كائن Warehouse هنا

// --- Definition for AddWarehouseFormContent ---
// تم تغيير الاسم من _AddWarehouseFormContent إلى AddWarehouseFormContent (إزالة الشرطة السفلية)
// لأنه الآن في ملف خاص به ويمكن الوصول إليه من الخارج.
class AddWarehouseFormContent extends ConsumerStatefulWidget {
  const AddWarehouseFormContent({super.key});

  @override
  ConsumerState<AddWarehouseFormContent> createState() =>
      _AddWarehouseFormContentState();
}

class _AddWarehouseFormContentState
    extends ConsumerState<AddWarehouseFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _capacityController = TextEditingController();
  String _selectedCapacityUnit = 'm³'; // Default unit

  final List<String> _capacityUnits = ['m³', 'kg', 'units', 'pallets'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final t = AppLocalizations.of(context)!; // احصل على t هنا

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final name = _nameController.text;
      final address = _addressController.text;
      final capacity = double.tryParse(_capacityController.text);

      if (capacity == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(t.get('invalid_capacity_value') ??
                    'Invalid capacity value')),
          );
        }
        return;
      }

      try {
        // TODO: استبدل هذا بمنطق إضافة المستودع الفعلي باستخدام Provider
        // مثال:
        // await ref.read(addWarehouseProvider.notifier).addWarehouse(
        //   name: name,
        //   address: address,
        //   capacity: capacity,
        //   capacityUnit: _selectedCapacityUnit,
        // );
        print(
            'Submitting warehouse: $name, $address, $capacity $_selectedCapacityUnit');

        if (mounted) {
          Navigator.of(context).pop(); // أغلق مربع الحوار
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(t.get('warehouse_added_successfully') ??
                    'Warehouse added successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    '${t.get('error_adding_warehouse') ?? 'Error adding warehouse'}: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(
        context)!; // احصل على t هنا أيضًا إذا لزم الأمر للـ UI

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: t.get('warehouse_name_label') ?? 'Warehouse Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.get('please_enter_warehouse_name') ??
                      'Please enter a warehouse name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                  labelText: t.get('warehouse_address_label') ?? 'Address'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.get('please_enter_address') ??
                      'Please enter an address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _capacityController,
              decoration: InputDecoration(
                  labelText: t.get('warehouse_capacity_label') ?? 'Capacity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t.get('please_enter_capacity') ??
                      'Please enter capacity';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return t.get('please_enter_valid_capacity') ??
                      'Please enter a valid positive capacity';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedCapacityUnit,
              decoration: InputDecoration(
                  labelText: t.get('capacity_unit_label') ?? 'Capacity Unit'),
              items: _capacityUnits.map((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  // تأكد من أن القيمة ليست null قبل التعيين
                  setState(() {
                    _selectedCapacityUnit = newValue;
                  });
                }
              },
              validator: (value) => value == null
                  ? (t.get('please_select_unit') ?? 'Please select a unit')
                  : null,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(t.get('cancel_button') ?? 'Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(t.get('add_button') ?? 'Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
