import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/providers/locale_provider.dart';

import 'package:warehouse/widgets/Dialogs/ShowAddProductWithWarehouseDialog.dart';
import 'package:warehouse/widgets/Dialogs/_showAddSpecializationDialog.dart';
import 'package:warehouse/widgets/Dialogs/show_add_general_product_dialog.dart';
import 'package:warehouse/widgets/Dialogs/add_product_to_warehouse_dialog.dart';

// ✅ استيراد الديالوجات الجديدة (عدّل المسار إذا لزم)
import 'package:warehouse/widgets/Dialogs/add_product_type_dialog.dart';

import '../widgets/kpi_card.dart';
import '../widgets/quick_action_button.dart';
import '../lang/app_localizations.dart';

class DashboardHome extends ConsumerWidget {
  const DashboardHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    // لو كنت تستخدمه للتنقل الداخلي
    final selectedPageIndexNotifier =
        ref.read(selectedPageIndexProvider.notifier);

    // TODO: اربط هذه القيم بـ Providers لاحقًا
    const kpiInventoryValue = "105";
    const kpiTasksValue = "7";
    const kpiVehiclesValue = "12";
    const kpiInvoicesValue = "3";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.get('dashboard'),
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),

          // KPIs
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

          // Quick actions
          Text(t.get('quick_actions_title'),
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // ✅ الزر الجديد: إضافة نوع
              QuickActionButton(
                label: t.get('add_new_type') /* أضف مفتاحاً في اللغات إن أردت */
                    ??
                    'Add New Type',
                icon: Icons.category_outlined,
                onPressed: () {
                  try {
                    showAddProductTypeDialog(context, ref);
                  } catch (e) {
                    debugPrint('Add New Type dialog error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تعذّر فتح نافذة إضافة النوع: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              // ✅ الزر الجديد: إضافة اختصاص
              QuickActionButton(
                label:
                    t.get('add_new_specialization') ?? 'Add New Specialization',
                icon: Icons.badge_outlined,
                onPressed: () {
                  try {
                    showAddSpecializationDialog(context, ref);
                  } catch (e) {
                    debugPrint('Add Specialization dialog error: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تعذّر فتح نافذة إضافة الاختصاص: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),

              // أزرارك السابقة
              QuickActionButton(
                label: t.get('new_product'),
                icon: Icons.add_box,
                onPressed: () {
                  showAddGeneralProductDialog(context, ref);
                },
              ),
              QuickActionButton(
                label: t.get('new_invoice'),
                icon: Icons.receipt_long,
                onPressed: () {
                  debugPrint('New Invoice Button Pressed');
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
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const SizedBox(
              height: 150,
              child: Center(child: Text("Urgent Action List Placeholder")),
            ),
          ),
        ],
      ),
    );
  }
}
