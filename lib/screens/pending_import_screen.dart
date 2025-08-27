// lib/screens/pending_imports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/pending_import_operation.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/import_api.dart';

class PendingImportsScreen extends ConsumerWidget {
  const PendingImportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingImportsAsync = ref.watch(pendingImportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Import Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(pendingImportsProvider),
          ),
        ],
      ),
      body: pendingImportsAsync.when(
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
            onRefresh: () async => ref.refresh(pendingImportsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: operations.length,
              itemBuilder: (context, index) {
                return _PendingImportCard(operation: operations[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// ويدجت احترافي لعرض تفاصيل عملية الاستيراد المعلقة
class _PendingImportCard extends ConsumerStatefulWidget {
  final PendingImportOperation operation;
  const _PendingImportCard({required this.operation});

  @override
  ConsumerState<_PendingImportCard> createState() => _PendingImportCardState();
}

class _PendingImportCardState extends ConsumerState<_PendingImportCard> {
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.acceptImportOperation(
      importKey: widget.operation.importOperationKey,
      storageKey: widget.operation.storageMediaKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Accepted!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        ref.refresh(pendingImportsProvider);
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleReject() async {
    setState(() => _isLoading = true);
    final success = await ImportApi.rejectImportOperation(
      importKey: widget.operation.importOperationKey,
      storageKey: widget.operation.storageMediaKey,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Rejected!'
            : ImportApi.lastErrorMessage ?? 'Failed.'),
        backgroundColor: success ? Colors.blueGrey : Colors.red,
      ));
      if (success) {
        ref.refresh(pendingImportsProvider);
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final op = widget.operation;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المورد والموقع
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: const Icon(Icons.person_outline),
              ),
              title: Text(op.supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Location: ${op.location}'),
            ),
            const Divider(),
            // تفاصيل الشحنة (قابلة للتوسيع)
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
            // أزرار التحكم
            if (_isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ))
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleReject,
                    child: const Text('Reject',
                        style: TextStyle(color: Colors.red)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
