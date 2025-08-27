import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/category.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/data_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final product = ref.watch(productProvider).firstWhere(
          (p) => p.id == productId,
        );

    final suppliers = ref.watch(suppliersListProvider);
    final categories = ref.watch(categoriesListProvider);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.get('product_details_title'))),
        body: Center(child: Text(t.get('product_not_found'))),
      );
    }

    final supplierName = suppliers.when(
      data: (list) => list
          .firstWhere((s) => s.id == product.supplierId,
              orElse: () => Supplier(
                   id: 0,
                   name: 'غير معروف',
                   country: '',
                   identifier: '',
                   communicationWay: '',
                 ))
          .name,
      loading: () => '...',
      error: (_, __) => 'خطأ',
    );

    final typeName = categories.when(
      data: (list) => list
          .firstWhere((c) => c.id == product.typeId,
              orElse: () => Category(id: '', name: 'غير معروف'))
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(t.get('name'), product.name),
                _infoRow(t.get('description'), product.description ?? '—'),
                _infoRow(t.get('type_id'), typeName),
                _infoRow(t.get('quantity'), product.quantity.toString()),
                _infoRow(t.get('unit'), product.unit),
                _infoRow(t.get('price'),
                    "${product.actualPiecePrice.toStringAsFixed(2)} \$"),
                _infoRow(t.get('import_cycle'), product.importCycle ?? '—'),
                _infoRow(t.get('supplier'), supplierName),
              ],
            ),
          ),
        ),
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
