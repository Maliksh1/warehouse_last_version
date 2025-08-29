// lib/screens/pending_import_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/models/pending_product_import.dart';
import 'package:warehouse/models/unified_pending_operation.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/import_api.dart';

class PendingImportsScreen extends ConsumerWidget {
  const PendingImportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOperationsAsync = ref.watch(allPendingOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Import Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            // ✅ --- تحديث طريقة التحديث ---
            onPressed: () => ref
                .read(allPendingOperationsProvider.notifier)
                .fetchOperations(),
          ),
        ],
      ),
      body: allOperationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('An error occurred: $err'),
          ),
        ),
        data: (operations) {
          if (operations.isEmpty) {
            return const Center(
              child: Text(
                'No pending import operations found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref
                .read(allPendingOperationsProvider.notifier)
                .fetchOperations(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: operations.length,
              itemBuilder: (context, index) {
                final operation = operations[index];
                if (operation is StorageMediaOperation) {
                  return _StorageMediaImportCard(operation: operation);
                } else if (operation is ProductOperation) {
                  return _ProductImportCard(operation: operation);
                } else if (operation is VehicleOperation) {
                  // ✅ عرض كارد المركبات الجديد
                  return _VehicleImportCard(operation: operation);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }
}

// --- CARD FOR STORAGE MEDIA IMPORTS ---
class _StorageMediaImportCard extends ConsumerStatefulWidget {
  final StorageMediaOperation operation;
  const _StorageMediaImportCard({required this.operation});

  @override
  ConsumerState<_StorageMediaImportCard> createState() =>
      _StorageMediaImportCardState();
}

class _StorageMediaImportCardState
    extends ConsumerState<_StorageMediaImportCard> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.acceptImportOperation(
      importKey: widget.operation.operation.importOperationKey,
      storageKey: widget.operation.operation.storageMediaKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Accepted!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      // ✅ ---  هنا التعديل ---
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleReject() async {
    setState(() => _isLoading = true);

    final success = await ImportApi.rejectImportOperation(
      importKey: widget.operation.operation.importOperationKey,
      key: widget.operation.operation.storageMediaKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Rejected!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
      ));
      // ✅ ---  وهنا أيضًا ---
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.operation.operation;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.widgets_outlined)),
              title: Text('Storage Media Import',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Supplier: ${op.supplier.name}'),
            ),
            const Divider(),
            ExpansionTile(
              title: Text('${op.storageItems.length} items to be stored'),
              children: op.storageItems.map((item) {
                return ListTile(
                  title: Text('Section: ${item.section.name}'),
                  subtitle: Text(
                      'Place: ${item.section.existable?['name'] ?? 'N/A'}'),
                  trailing: Text('Qty: ${item.quantity}'),
                );
              }).toList(),
            ),
            const Divider(),
            if (_isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator()))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _handleReject,
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET جديد لعرض عمليات استيراد المنتجات ---
class _ProductImportCard extends ConsumerStatefulWidget {
  final ProductOperation operation;
  const _ProductImportCard({required this.operation});

  @override
  ConsumerState<_ProductImportCard> createState() => _ProductImportCardState();
}

class _ProductImportCardState extends ConsumerState<_ProductImportCard> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.acceptProductImport(
      importKey: widget.operation.operation.importOperationKey,
      productsKey: widget.operation.operation.productsKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Accepted!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      // ✅ ---  هنا التعديل ---
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleReject() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.rejectProductImport(
      importKey: widget.operation.operation.importOperationKey,
      productsKey: widget.operation.operation.productsKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Rejected!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
      ));
      // ✅ ---  وهنا أيضًا ---
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.operation.operation;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
              title: Text('Product Import',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Supplier: ${op.supplier.name}'),
            ),
            const Divider(),
            ExpansionTile(
              title: Text('${op.products.length} products to be imported'),
              children: op.products.map((item) {
                return ListTile(
                  title: Text('Product: ${item.product.name}'),
                  subtitle: Text('Total Load: ${item.importedLoad}'),
                  trailing: Text('Price: ${item.pricePerUnit}'),
                );
              }).toList(),
            ),
            const Divider(),
            if (_isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator()))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _handleReject,
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _VehicleImportCard extends ConsumerStatefulWidget {
  final VehicleOperation operation;
  const _VehicleImportCard({required this.operation});

  @override
  ConsumerState<_VehicleImportCard> createState() => _VehicleImportCardState();
}

class _VehicleImportCardState extends ConsumerState<_VehicleImportCard> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.acceptVehicleImport(
      importKey: widget.operation.operation.importOperationKey,
      vehiclesKey: widget.operation.operation.vehiclesKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Accepted!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _handleReject() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.rejectImportOperation(
      importKey: widget.operation.operation.importOperationKey,
      key: widget.operation.operation.vehiclesKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Rejected!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
      ));
      if (success) {
        ref
            .read(allPendingOperationsProvider.notifier)
            .removeOperation(widget.operation);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.operation.operation;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                  child: Icon(Icons.local_shipping_outlined)),
              title: const Text('Vehicle Import',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Supplier: ${op.supplier.name}'),
            ),
            const Divider(),
            ExpansionTile(
              title: Text('${op.vehicles.length} vehicles to be imported'),
              children: op.vehicles.map((vehicle) {
                return ListTile(
                  title: Text(vehicle.name),
                  subtitle: Text(
                      'Capacity: ${vehicle.capacity} | Size: ${vehicle.sizeOfVehicle}'),
                  trailing: Text('Readiness: ${vehicle.readiness}'),
                );
              }).toList(),
            ),
            const Divider(),
            if (_isLoading)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator()))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _handleReject,
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.red))),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
