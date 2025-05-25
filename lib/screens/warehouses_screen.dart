import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/screens/warehouse_details_screen.dart';
import 'package:warehouse/widgets/dialogs/add_warehouse_dialog.dart';

class WarehousesScreen extends ConsumerWidget {
  const WarehousesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final warehouses = ref.watch(warehouseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('warehouses')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddWarehouseDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(t.get('add_new_warehouse_button')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: warehouses.isEmpty
            ? Center(child: Text(t.get('no_data_available')))
            : ListView.separated(
                itemCount: warehouses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final w = warehouses[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              WarehouseDetailsScreen(warehouseId: w.id),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warehouse,
                                    size: 28, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    w.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, size: 16),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text("${t.get('location')}: ${w.address}"),
                            Text(
                                "${t.get('capacity')}: ${w.capacity} ${w.capacityUnit}"),
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: w.usageRate,
                              backgroundColor: Colors.grey.shade300,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              color: w.usageRate > 0.8
                                  ? Colors.red
                                  : w.usageRate > 0.6
                                      ? Colors.orange
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                                "${(w.usageRate * 100).toInt()}% ${t.get('occupancy')}"),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
