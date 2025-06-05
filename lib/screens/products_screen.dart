import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/navigation_provider.dart';
import 'package:warehouse/widgets/Dialogs/show_add_general_product_dialog.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final products = ref.watch(productProvider);
    final suppliers = ref.watch(suppliersListProvider);
    final navigation = ref.read(navigationProvider.notifier);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.get('products'),
                    style: Theme.of(context).textTheme.headlineMedium),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_box),
                  label: Text(t.get('add_product')),
                  onPressed: () {
                    showAddGeneralProductDialog(context, ref);
                  },
                ),
              ],
            ),
          ),

          // List of products
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final supplier = suppliers.when(
                      data: (list) => list
                          .firstWhere(
                            (s) => s.id == product.supplierId,
                            orElse: () => Supplier(
                              id: '',
                              name: 'غير معروف',
                              contactPerson: '',
                              phoneNumber: '',
                              address: '',
                              paymentTerms: '',
                              contact: '',
                            ),
                          )
                          .name,
                      loading: () => 'جاري التحميل...',
                      error: (_, __) => 'خطأ',
                    );

                    return ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.inventory_2_outlined)),
                      title: Text(product.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.description != null)
                            Text(
                                '${t.get('description')}: ${product.description}'),
                          Text('${t.get('supplier')}: $supplier'),
                          Text('${t.get('quantity')}: ⚠️ حساب لاحقًا'),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        navigation
                            .go(NavigationState.productDetails(product.id));
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
