import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/widgets/dialogs/add_product_to_warehouse_dialog.dart';
import 'package:warehouse/screens/product_details_screen.dart'; // ✅ تأكد من استيراد الشاشة

class WarehouseDetailsScreen extends ConsumerWidget {
  final String warehouseId;

  const WarehouseDetailsScreen({super.key, required this.warehouseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final warehouse =
        ref.watch(warehouseProvider).firstWhere((w) => w.id == warehouseId);
    final products = ref
        .watch(productProvider)
        .where((p) =>
            p.sku.startsWith(warehouseId)) // ربط المنتجات بالمستودع من خلال SKU
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('warehouse_details_title')),
        leading: const BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(warehouse.name,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 10),
            Text("${t.get('location')}: ${warehouse.address}"),
            Text(
                "${t.get('capacity')}: ${warehouse.capacity} ${warehouse.capacityUnit}"),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.get('stock_items'),
                    style: Theme.of(context).textTheme.titleLarge),
                ElevatedButton.icon(
                  onPressed: () => showAddProductToWarehouseDialog(
                      context, ref, warehouseId),
                  icon: const Icon(Icons.add),
                  label: Text(t.get('add_product')),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: products.isEmpty
                  ? Center(child: Text(t.get('no_data_available')))
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final p = products[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.inventory_2),
                            title: Text(p.name),
                            subtitle: Text("SKU: ${p.sku}"),
                            trailing:
                                Text("\$${p.sellingPrice.toStringAsFixed(2)}"),
                            // ✅ عند النقر على المنتج ننتقل إلى شاشة التفاصيل
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(productId: p.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
