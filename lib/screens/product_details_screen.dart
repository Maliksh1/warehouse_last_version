import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/category.dart';
import 'package:warehouse/providers/data_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  final Product? selectedProduct; // كائن المنتج الاختياري

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.selectedProduct,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    // إذا كان الكائن موجودًا، استخدمه؛ وإلا استعلم من مزود البيانات
    final productAsync = selectedProduct != null
        ? AsyncValue<Product>.data(selectedProduct!)
        : ref.watch(productByIdProvider(productId));

    final suppliersAsync = ref.watch(suppliersListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    return productAsync.when(
      data: (product) {
        final supplierName = suppliersAsync.when(
          data: (list) => list
              .firstWhere(
                (s) => s.id.toString() == product.supplierId?.toString(),
                orElse: () => Supplier(
                  id: 0,
                  name: 'غير معروف',
                  country: '',
                  identifier: '',
                  communicationWay: '',
                ),
              )
              .name,
          loading: () => '...',
          error: (_, __) => 'خطأ',
        );

        final typeName = categoriesAsync.when(
          data: (list) => list
              .firstWhere(
                (c) => c.id.toString() == product.typeId?.toString(),
                orElse: () => Category(id: '', name: 'غير معروف'),
              )
              .name,
          loading: () => '...',
          error: (_, __) => 'خطأ',
        );

        return Scaffold(
          appBar: AppBar(title: Text(t.get('product_details_title'))),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(t.get('name'), product.name),
                    _infoRow(t.get('description'), product.description ?? '—'),
                    _infoRow(t.get('type_id'), typeName),
                    _infoRow(t.get('quantity'), product.quantity.toString()),
                    _infoRow(t.get('unit'), product.unit.toString()),
                    _infoRow(
                      t.get('price'),
                      "${product.actualPiecePrice?.toStringAsFixed(2) ?? '0.00'} \$",
                    ),
                    _infoRow(t.get('import_cycle'), product.importCycle ?? '—'),
                    _infoRow(t.get('supplier'), supplierName),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: Text(t.get('product_details_title'))),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(t.get('product_details_title'))),
        body: Center(child: Text(t.get('product_not_found'))),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
