import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/stock_item.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/stock_item_provider.dart';

void showAddProductToWarehouseDialog(
    BuildContext context, WidgetRef ref, String warehouseId) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final skuController = TextEditingController();
  final categoryIdController = TextEditingController();
  final supplierIdController = TextEditingController();
  final purchasePriceController = TextEditingController();
  final sellingPriceController = TextEditingController();
  final quantityController = TextEditingController();
  final locationController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final uuid = Uuid();

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_box, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Text(t.get('add_product')),
        ],
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات المنتج
              Text(
                t.get('product_info'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: t.get('product_name'),
                  prefixIcon: const Icon(Icons.inventory),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: skuController,
                decoration: InputDecoration(
                  labelText: 'SKU',
                  prefixIcon: const Icon(Icons.qr_code),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: categoryIdController,
                decoration: InputDecoration(
                  labelText: t.get('category'),
                  prefixIcon: const Icon(Icons.category),
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
              const SizedBox(height: 10),
              TextFormField(
                controller: supplierIdController,
                decoration: InputDecoration(
                  labelText: t.get('supplier'),
                  prefixIcon: const Icon(Icons.business),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: purchasePriceController,
                      decoration: InputDecoration(
                        labelText: t.get('cost'),
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.get('required_field');
                        }
                        if (double.tryParse(value) == null) {
                          return t.get('invalid_number');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: sellingPriceController,
                      decoration: InputDecoration(
                        labelText: t.get('price'),
                        prefixIcon: const Icon(Icons.monetization_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return t.get('required_field');
                        }
                        if (double.tryParse(value) == null) {
                          return t.get('invalid_number');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // معلومات المخزون
              Text(
                t.get('stock_info'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: t.get('quantity'),
                  prefixIcon: const Icon(Icons.production_quantity_limits),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.get('required_field');
                  }
                  if (int.tryParse(value) == null) {
                    return t.get('invalid_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: t.get('location_in_warehouse'),
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: t.get('location_hint'),
                ),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: Text(t.get('save')),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // إنشاء معرف فريد للمنتج
              final productId = uuid.v4();

              // إنشاء منتج جديد
              final newProduct = Product(
                id: productId,
                name: nameController.text,
                sku: '$warehouseId-${skuController.text}',
                categoryId: categoryIdController.text,
                supplierId: supplierIdController.text,
                purchasePrice:
                    double.tryParse(purchasePriceController.text) ?? 0.0,
                sellingPrice:
                    double.tryParse(sellingPriceController.text) ?? 0.0,
                imageUrl: null,
                minStockLevel: 5,
              );

              // إنشاء عنصر مخزون جديد
              final newStockItem = StockItem(
                id: uuid.v4(),
                warehouseId: warehouseId,
                productId: productId,
                location: locationController.text,
                quantity: int.tryParse(quantityController.text) ?? 0,
                expiryDate: null,
              );

              // تحديث مزود المنتجات
              ref.read(productProvider.notifier).add(newProduct);

              // تحديث مزود المخزون
              ref.read(stockItemProvider.notifier).add(newStockItem);

              // إغلاق النافذة وعرض رسالة نجاح
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(t.get('product_added_successfully')),
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
          },
        ),
      ],
    ),
  );
}

// --- إضافة مفاتيح الترجمة إلى ملفات اللغة ---
/*
// في lib/lang/en.json:
"product_info": "Product Information",
"stock_info": "Stock Information",
"location_in_warehouse": "Location in Warehouse",
"location_hint": "e.g., Shelf A1, Bin B2",
"required_field": "This field is required",
"invalid_number": "Please enter a valid number",
"product_added_successfully": "Product added successfully",

// في lib/lang/ar.json:
"product_info": "معلومات المنتج",
"stock_info": "معلومات المخزون",
"location_in_warehouse": "الموقع في المستودع",
"location_hint": "مثال: رف A1، صندوق B2",
"required_field": "هذا الحقل مطلوب",
"invalid_number": "الرجاء إدخال رقم صحيح",
"product_added_successfully": "تمت إضافة المنتج بنجاح",
*/
