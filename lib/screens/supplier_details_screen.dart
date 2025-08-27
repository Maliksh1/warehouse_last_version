// lib/screens/supplier_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/suppliers_api.dart';

class SupplierDetailsScreen extends ConsumerWidget {
  final Supplier supplier;
  const SupplierDetailsScreen({super.key, required this.supplier});

  void _deleteSupplier(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete ${supplier.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await SuppliersApi.deleteSupplier((supplier.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Supplier deleted.'
                : SuppliersApi.lastErrorMessage ?? 'Failed to delete.'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          ref.refresh(suppliersListProvider);
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(supplier.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _deleteSupplier(context, ref),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2, // Details and Products
        child: Column(
          children: [
            const TabBar(
              labelColor: Colors.blue,
              tabs: [
                Tab(icon: Icon(Icons.info_outline), text: 'Details'),
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Products'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildDetailsTab(),
                  _buildProductsTab(ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Country'),
            subtitle: Text(supplier.country),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.badge),
            title: const Text('Identifier'),
            subtitle: Text(supplier.identifier),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.contact_mail),
            title: const Text('Communication'),
            subtitle: Text(supplier.communicationWay),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTab(WidgetRef ref) {
    final productsAsync = ref.watch(supplierProductsProvider((supplier.id)));
    return productsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (products) {
        if (products.isEmpty) {
          return const Center(child: Text('This supplier has no products.'));
        }
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(product.name),
                subtitle: Text(
                    'Available Quantity: ${product.quantity} ${product.unit}'),
              ),
            );
          },
        );
      },
    );
  }
}
