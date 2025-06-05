import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:warehouse/providers/locale_provider.dart';
import 'package:warehouse/widgets/Dialogs/ShowAddProdustWithWarehouseDialog.dart';
import 'package:warehouse/widgets/Dialogs/show_add_general_product_dialog.dart';
import 'package:warehouse/widgets/dialogs/add_product_to_warehouse_dialog.dart';
// Import the widgets used for the dashboard overview
import '../widgets/kpi_card.dart';
import '../widgets/quick_action_button.dart';
import '../lang/app_localizations.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var t = AppLocalizations.of(context)!;

    // Access the selected page index notifier to change the state
    final selectedPageIndexNotifier =
        ref.read(selectedPageIndexProvider.notifier);

    // TODO: Fetch actual KPI data using ref.watch from relevant providers
    // For now, using hardcoded values as placeholders
    final kpiInventoryValue = "105";
    final kpiTasksValue = "7";
    final kpiVehiclesValue = "12";
    final kpiInvoicesValue = "3";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.get('dashboard'),
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: t.get('kpi_inventory'),
                value: kpiInventoryValue,
                icon: Icons.inventory,
              ),
              KpiCard(
                title: t.get('kpi_tasks'),
                value: kpiTasksValue,
                icon: Icons.assignment_late,
              ),
              KpiCard(
                title: t.get('kpi_vehicles'),
                value: kpiVehiclesValue,
                icon: Icons.local_shipping,
              ),
              KpiCard(
                title: t.get('kpi_invoices'),
                value: kpiInvoicesValue,
                icon: Icons.receipt,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(t.get('quick_actions_title'),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // QuickActionButton(
              //   label: t.get('new_task'),
              //   icon: Icons.assignment_add,
              //   onPressed: () {
              //     // --- Action for "New Task" ---
              //     // Change the selected page index to -1 to show the Create Task screen
              //     selectedPageIndexNotifier.state = -1;
              //     print("Navigate to Create New Task Screen (index -1)");
              //   },
              // ),
              QuickActionButton(
                label: t.get('new_product'),
                icon: Icons.add_box,
                onPressed: () {
                  // افتح شاشة اضافة منتج
                  showAddGeneralProductDialog(context, ref);
                },
              ),
              QuickActionButton(
                label: t.get('new_invoice'),
                icon: Icons.receipt_long,
                onPressed: () {
                  // TODO: Navigate to Create New Invoice (maybe use another special index like -3, or a dialog)
                  print("New Invoice Button Pressed");
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          Text(t.get('warehouse_chart'),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text("📊 ${t.get('warehouse_chart')}",
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(t.get('task_chart'),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text("📈 ${t.get('task_chart')}",
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text("Urgent Actions (Placeholder)",
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall), // TODO: Localize title
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const SizedBox(
              height: 150,
              child: Center(child: Text("Urgent Action List Placeholder")),
            ),
          )
        ],
      ),
    );
  }
}
