import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/category.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/providers/navigation_provider.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/widgets/dialogs/add_product_to_warehouse_dialog.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  Color _getProductStatusColor(String status) {
    switch (status) {
      case 'متوفر':
        return Colors.green;
      case 'منخفض':
        return Colors.orangeAccent;
      case 'نافد':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations t,
    List<Product> products,
    List<Supplier> suppliers,
    List<Category> categories,
    dynamic navigationNotifier,
  ) {
    if (products.isEmpty) {
      return Center(child: Text(t.get('no_data_available')));
    }

    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final product = products[index];

        final supplier = suppliers.firstWhere(
          (s) => s.id == product.supplierId,
          orElse: () => Supplier(
              id: '',
              name: 'N/A',
              contactPerson: '',
              phoneNumber: '',
              address: '',
              paymentTerms: '',
              contact: ''),
        );

        final category = categories.firstWhere(
          (c) => c.id == product.categoryId,
          orElse: () => Category(id: '', name: 'N/A'),
        );

        const status = 'متوفر';

        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
          title: Text(product.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${t.get('sku')}: ${product.sku}"),
              Text("${t.get('category')}: ${category.name}"),
              Text("${t.get('supplier')}: ${supplier.name}"),
              Text("${t.get('total_quantity')}: حساب لاحقًا"),
            ],
          ),
          isThreeLine: true,
          trailing: Text(
            t.get(status),
            style: TextStyle(
              color: _getProductStatusColor(status),
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            navigationNotifier.go(
              NavigationState.productDetails(product.id),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final products = ref.watch(productProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final categoriesAsync = ref.watch(categoriesListProvider);
    final warehouses = ref.watch(warehouseProvider);
    final navNotifier = ref.read(navigationProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.get('products'),
                  style: Theme.of(context).textTheme.headlineMedium),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_box),
                    label: Text(t.get('add_product')),
                    onPressed: () async {
                      final selectedWarehouse = await showDialog<String>(
                        context: context,
                        builder: (_) {
                          String? selected;
                          return AlertDialog(
                            title: Text(t.get('select_warehouse')),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DropdownButtonFormField<String>(
                                      items: warehouses.map((w) {
                                        return DropdownMenuItem(
                                          value: w.id,
                                          child: Text(w.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          selected = val;
                                        });
                                      },
                                      hint: Text(t.get('choose_warehouse')),
                                    ),
                                  ],
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(t.get('cancel')),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (selected != null) {
                                    Navigator.pop(context, selected);
                                  }
                                },
                                child: Text(t.get('continue')),
                              ),
                            ],
                          );
                        },
                      );

                      if (selectedWarehouse != null) {
                        showAddProductToWarehouseDialog(
                            context, ref, selectedWarehouse);
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      print("Export Products Pressed");
                    },
                    icon: const Icon(Icons.download),
                    label: Text(t.get('export_products')),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: t.get('search_placeholder'),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            ),
            onChanged: (value) {
              print("Search: $value");
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: suppliersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
                data: (suppliers) => categoriesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text("Error: $err")),
                  data: (categories) => _buildContent(
                    context,
                    t,
                    products,
                    suppliers,
                    categories,
                    navNotifier,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
