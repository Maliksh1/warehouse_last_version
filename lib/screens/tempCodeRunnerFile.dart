import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart'; // افتراضي، قد تحتاج لإنشاء هذا الملف

// تحويل الكلاس إلى ConsumerWidget لاستخدام Riverpod
class WarehousesScreen extends ConsumerWidget {
  WarehousesScreen({super.key});

  // بيانات مؤقتة - سيتم استبدالها بالبيانات من الخدمة
  final List<Map<String, dynamic>> warehouses = [
    {
      "id": "1",
      "name": "المستودع الرئيسي",
      "location": "دمشق - المزة",
      "capacity": 100,
      "used": 65,
      "manager": "أحمد محمد"
    },
    {
      "id": "2",
      "name": "مستودع الجنوب",
      "location": "درعا - المحطة",
      "capacity": 50,
      "used": 40,
      "manager": "سامر علي"
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الصفحة وزر الإضافة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.get('warehouses'),
                  style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(t.get('add_new_warehouse_button')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // عرض نافذة إضافة مستودع جديد
                  _showAddWarehouseDialog(context, t);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // حقل البحث
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: t.get('search_placeholder'),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              onChanged: (value) {
                // منطق البحث
                print("Search query: $value");
              },
            ),
          ),

          const SizedBox(height: 16),

          // عرض المستودعات
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الجدول
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      t.get('warehouses_list'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  // جدول المستودعات
                  DataTable(
                    columnSpacing: 20,
                    horizontalMargin: 10,
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    columns: [
                      DataColumn(
                          label: Text(t.get('name'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t.get('location'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t.get('capacity'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t.get('occupancy'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text(t.get('actions'),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                    ],
                    rows: warehouses.map((warehouse) {
                      double usage = warehouse["capacity"] > 0
                          ? warehouse["used"] / warehouse["capacity"]
                          : 0.0;

                      return DataRow(
                        cells: [
                          DataCell(Text(warehouse["name"])),
                          DataCell(Text(warehouse["location"] ?? "-")),
                          DataCell(Text("${warehouse["capacity"]}")),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: usage,
                                    backgroundColor: Colors.grey.shade200,
                                    color: usage > 0.8
                                        ? Colors.red
                                        : usage > 0.6
                                            ? Colors.orange
                                            : Theme.of(context).primaryColor,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text("${(usage * 100).toInt()}%"),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: t.get('edit'),
                                  onPressed: () {
                                    // تعديل المستودع
                                    _showEditWarehouseDialog(
                                        context, t, warehouse);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: t.get('delete'),
                                  onPressed: () {
                                    // حذف المستودع
                                    _showDeleteConfirmationDialog(
                                        context, t, warehouse);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility,
                                      color: Colors.green),
                                  tooltip: t.get('view_details'),
                                  onPressed: () {
                                    // عرض تفاصيل المستودع
                                    // TODO: تنفيذ التنقل إلى صفحة التفاصيل
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة إضافة مستودع جديد
  void _showAddWarehouseDialog(BuildContext context, AppLocalizations t) {
    // متغيرات لتخزين قيم الحقول
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final capacityController = TextEditingController();
    final managerController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warehouse, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text(t.get('add_new_warehouse')),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 500, // عرض ثابت للنافذة
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حقل اسم المستودع
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_name'),
                      hintText: t.get('enter_warehouse_name'),
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل موقع المستودع
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_location'),
                      hintText: t.get('enter_warehouse_location'),
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل السعة
                  TextFormField(
                    controller: capacityController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_capacity'),
                      hintText: t.get('enter_warehouse_capacity'),
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return t.get('invalid_capacity');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل مدير المستودع
                  TextFormField(
                    controller: managerController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_manager'),
                      hintText: t.get('enter_warehouse_manager'),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('cancel')),
          ),

          // زر الحفظ
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t.get('save')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // التحقق من صحة البيانات
              if (formKey.currentState!.validate()) {
                // إضافة المستودع الجديد
                final newWarehouse = {
                  "id": DateTime.now().millisecondsSinceEpoch.toString(),
                  "name": nameController.text,
                  "location": locationController.text,
                  "capacity": int.parse(capacityController.text),
                  "used": 0,
                  "manager": managerController.text,
                };

                // TODO: استدعاء خدمة إضافة المستودع
                print("Adding new warehouse: $newWarehouse");

                // إغلاق النافذة وعرض رسالة نجاح
                Navigator.pop(context);
                _showSuccessSnackBar(
                    context, t.get('warehouse_added_successfully'));
              }
            },
          ),
        ],
      ),
    );
  }

  // نافذة تعديل المستودع
  void _showEditWarehouseDialog(BuildContext context, AppLocalizations t,
      Map<String, dynamic> warehouse) {
    // متغيرات لتخزين قيم الحقول
    final nameController = TextEditingController(text: warehouse["name"]);
    final locationController =
        TextEditingController(text: warehouse["location"] ?? "");
    final capacityController =
        TextEditingController(text: warehouse["capacity"].toString());
    final managerController =
        TextEditingController(text: warehouse["manager"] ?? "");
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            const SizedBox(width: 10),
            Text(t.get('edit_warehouse')),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 500, // عرض ثابت للنافذة
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حقل اسم المستودع
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_name'),
                      prefixIcon: const Icon(Icons.store),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل موقع المستودع
                  TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_location'),
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل السعة
                  TextFormField(
                    controller: capacityController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_capacity'),
                      prefixIcon: const Icon(Icons.inventory_2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return t.get('required_field');
                      }
                      if (int.tryParse(value) == null ||
                          int.parse(value) <= 0) {
                        return t.get('invalid_capacity');
                      }
                      // التحقق من أن السعة الجديدة لا تقل عن الاستخدام الحالي
                      if (int.parse(value) < warehouse["used"]) {
                        return t.get('capacity_less_than_used');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // حقل مدير المستودع
                  TextFormField(
                    controller: managerController,
                    decoration: InputDecoration(
                      labelText: t.get('warehouse_manager'),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('cancel')),
          ),

          // زر الحفظ
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t.get('save')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // التحقق من صحة البيانات
              if (formKey.currentState!.validate()) {
                // تحديث المستودع
                final updatedWarehouse = {
                  ...warehouse,
                  "name": nameController.text,
                  "location": locationController.text,
                  "capacity": int.parse(capacityController.text),
                  "manager": managerController.text,
                };

                // TODO: استدعاء خدمة تحديث المستودع
                print("Updating warehouse: $updatedWarehouse");

                // إغلاق النافذة وعرض رسالة نجاح
                Navigator.pop(context);
                _showSuccessSnackBar(
                    context, t.get('warehouse_updated_successfully'));
              }
            },
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد الحذف
  void _showDeleteConfirmationDialog(BuildContext context, AppLocalizations t,
      Map<String, dynamic> warehouse) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Text(t.get('confirm_delete')),
          ],
        ),
        content: Text(
          t
              .get('delete_warehouse_confirmation')
              .replaceAll('{name}', warehouse["name"]),
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.get('cancel')),
          ),

          // زر الحذف
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(t.get('delete')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // TODO: استدعاء خدمة حذف المستودع
              print("Deleting warehouse: ${warehouse["id"]}");

              // إغلاق النافذة وعرض رسالة نجاح
              Navigator.pop(context);
              _showSuccessSnackBar(
                  context, t.get('warehouse_deleted_successfully'));
            },
          ),
        ],
      ),
    );
  }

  // عرض رسالة نجاح
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// --- إضافة مفاتيح الترجمة إلى ملفات اللغة ---
/*
// في lib/lang/en.json:
"add_new_warehouse": "Add New Warehouse",
"edit_warehouse": "Edit Warehouse",
"confirm_delete": "Confirm Delete",
"delete_warehouse_confirmation": "Are you sure you want to delete warehouse '{name}'?",
"warehouse_name": "Warehouse Name",
"warehouse_location": "Warehouse Location",
"warehouse_capacity": "Warehouse Capacity",
"warehouse_manager": "Warehouse Manager",
"enter_warehouse_name": "Enter warehouse name",
"enter_warehouse_location": "Enter warehouse location",
"enter_warehouse_capacity": "Enter warehouse capacity",
"enter_warehouse_manager": "Enter warehouse manager",
"required_field": "This field is required",
"invalid_capacity": "Capacity must be a positive number",
"capacity_less_than_used": "Capacity cannot be less than current usage",
"save": "Save",
"cancel": "Cancel",
"delete": "Delete",
"edit": "Edit",
"view_details": "View Details",
"warehouse_added_successfully": "Warehouse added successfully",
"warehouse_updated_successfully": "Warehouse updated successfully",
"warehouse_deleted_successfully": "Warehouse deleted successfully",
"warehouses_list": "Warehouses List",
"location": "Location",
"capacity": "Capacity",

// في lib/lang/ar.json:
"add_new_warehouse": "إضافة مستودع جديد",
"edit_warehouse": "تعديل المستودع",
"confirm_delete": "تأكيد الحذف",
"delete_warehouse_confirmation": "هل أنت متأكد من حذف المستودع '{name}'؟",
"warehouse_name": "اسم المستودع",
"warehouse_location": "موقع المستودع",
"warehouse_capacity": "سعة المستودع",
"warehouse_manager": "مدير المستودع",
"enter_warehouse_name": "أدخل اسم المستودع",
"enter_warehouse_location": "أدخل موقع المستودع",
"enter_warehouse_capacity": "أدخل سعة المستودع",
"enter_warehouse_manager": "أدخل اسم مدير المستودع",
"required_field": "هذا الحقل مطلوب",
"invalid_capacity": "يجب أن تكون السعة رقماً موجباً",
"capacity_less_than_used": "لا يمكن أن تكون السعة أقل من الاستخدام الحالي",
"save": "حفظ",
"cancel": "إلغاء",
"delete": "حذف",
"edit": "تعديل",
"view_details": "عرض التفاصيل",
"warehouse_added_successfully": "تمت إضافة المستودع بنجاح",
"warehouse_updated_successfully": "تم تحديث المستودع بنجاح",
"warehouse_deleted_successfully": "تم حذف المستودع بنجاح",
"warehouses_list": "قائمة المستودعات",
"location": "الموقع",
"capacity": "السعة",
*/
