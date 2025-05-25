import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/stock_item.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/category.dart';
import 'package:warehouse/providers/data_providers.dart';

class ProductDetailsScreen extends riverpod.ConsumerWidget {
  final String productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    String? warehouseId,
    String? stockItemId,
  });

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final productAsync = ref.watch(productByIdProvider(productId));
    final stockAsync = ref.watch(stockItemsProvider);
    final warehousesAsync = ref.watch(warehousesProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);

    final riverpod.AsyncValue<
        (
          Product,
          List<StockItem>,
          List<Warehouse>,
          List<Supplier>,
          List<Category>
        )> combined = _combine5(
      productAsync,
      stockAsync,
      warehousesAsync,
      suppliersAsync,
      categoriesAsync,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('product_details_title') ?? 'تفاصيل المنتج'),
        leading: const BackButton(),
      ),
      body: combined.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (tuple) {
          final product = tuple.$1;
          final stocks =
              tuple.$2.where((s) => s.productId == product.id).toList();
          final warehouses = tuple.$3;
          final supplier = tuple.$4.firstWhere(
              (s) => s.id == product.supplierId,
              orElse: () => Supplier(
                  id: '',
                  name: 'غير معروف',
                  contactPerson: '',
                  phoneNumber: '',
                  address: '',
                  paymentTerms: '',
                  contact: ''));
          final category = tuple.$5.firstWhere(
              (c) => c.id == product.categoryId,
              orElse: () => Category(id: '', name: 'غير معروف'));

          final totalQty = stocks.fold<int>(0, (sum, s) => sum + s.quantity);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle(context, t.get('general_info')),
                _infoCard([
                  _infoRow(t.get('name'), product.name),
                  _infoRow('SKU', product.sku),
                  _infoRow(t.get('category'), category.name),
                  _infoRow(t.get('supplier'), supplier.name),
                  _infoRow(t.get('cost'), "${product.purchasePrice} \$"),
                  _infoRow(t.get('price'), "${product.sellingPrice} \$"),
                  _infoRow(t.get('min_stock_level') ?? 'الحد الأدنى',
                      product.minStockLevel.toString()),
                  _infoRow(t.get('total_quantity') ?? 'الكمية الكلية',
                      totalQty.toString()),
                ]),
                const SizedBox(height: 24),
                _sectionTitle(context, t.get('stock_locations')),
                if (stocks.isEmpty)
                  Text(t.get('no_stock_locations_found') ??
                      'لا توجد مواقع تخزين'),
                ...stocks.map((stock) {
                  final warehouseName = warehouses
                      .firstWhere((w) => w.id == stock.warehouseId,
                          orElse: () => Warehouse(
                              id: '',
                              name: 'غير معروف',
                              address: '',
                              capacity: 0,
                              capacityUnit: '',
                              usedCapacity: 0,
                              occupied: 100,
                              location: '',
                              used: 1,
                              manager: '',
                              productIds: null))
                      .name;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(warehouseName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${t.get('location')}: ${stock.location}"),
                          Text("${t.get('quantity')}: ${stock.quantity}"),
                          if (stock.expiryDate != null)
                            Text(
                                "${t.get('expiry_date')}: ${stock.expiryDate!.toLocal().toString().split(' ')[0]}"),
                        ],
                      ),
                      trailing:
                          _statusChip(stock.quantity, product.minStockLevel, t),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _statusChip(int quantity, int min, AppLocalizations t) {
    final status = quantity <= 0
        ? t.get('out_of_stock')
        : quantity <= min
            ? t.get('low')
            : t.get('available');

    final color = quantity <= 0
        ? Colors.red
        : quantity <= min
            ? Colors.orange
            : Colors.green;

    return Chip(
        label: Text(status),
        backgroundColor: color.withOpacity(0.2),
        labelStyle: TextStyle(color: color));
  }

  riverpod.AsyncValue<
      (
        Product,
        List<StockItem>,
        List<Warehouse>,
        List<Supplier>,
        List<Category>
      )> _combine5(
    riverpod.AsyncValue<Product> a,
    riverpod.AsyncValue<List<StockItem>> b,
    riverpod.AsyncValue<List<Warehouse>> c,
    riverpod.AsyncValue<List<Supplier>> d,
    riverpod.AsyncValue<List<Category>> e,
  ) {
    if (a.isLoading ||
        b.isLoading ||
        c.isLoading ||
        d.isLoading ||
        e.isLoading) {
      return const riverpod.AsyncValue.loading();
    }
    if (a.hasError)
      return riverpod.AsyncValue.error(
          a.error!, a.stackTrace ?? StackTrace.current);
    if (b.hasError)
      return riverpod.AsyncValue.error(
          b.error!, b.stackTrace ?? StackTrace.current);
    if (c.hasError)
      return riverpod.AsyncValue.error(
          c.error!, c.stackTrace ?? StackTrace.current);
    if (d.hasError)
      return riverpod.AsyncValue.error(
          d.error!, d.stackTrace ?? StackTrace.current);
    if (e.hasError)
      return riverpod.AsyncValue.error(
          e.error!, e.stackTrace ?? StackTrace.current);

    return riverpod.AsyncValue.data(
        (a.value!, b.value!, c.value!, d.value!, e.value!));
  }
}
