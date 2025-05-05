import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/kpi_card.dart';
import '../widgets/quick_action_button.dart';
import '../lang/app_localizations.dart';

class DashboardHome extends StatefulWidget {
  final VoidCallback onLanguageToggle;
  const DashboardHome({Key? key, required this.onLanguageToggle})
      : super(key: key);

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;

    return Scaffold(
      body: Row(
        children: [
          SidebarMenu(),
          Expanded(
            child: Column(
              children: [
                // ✅ Top bar
                Container(
                  height: 60,
                  color: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t.get('dashboard'),
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      Row(
                        children: [
                          Icon(Icons.search, color: Colors.white),
                          SizedBox(width: 16),
                          Icon(Icons.notifications_none, color: Colors.white),
                          SizedBox(width: 16),
                          IconButton(
                            icon: Icon(Icons.language, color: Colors.white),
                            tooltip: 'تغيير اللغة',
                            onPressed: widget.onLanguageToggle,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ✅ باقي المحتوى
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ KPIs
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            KpiCard(
                                title: t.get('kpi_inventory'),
                                value: "105",
                                icon: Icons.inventory),
                            KpiCard(
                                title: t.get('kpi_tasks'),
                                value: "7",
                                icon: Icons.assignment_late),
                            KpiCard(
                                title: t.get('kpi_vehicles'),
                                value: "12",
                                icon: Icons.local_shipping),
                            KpiCard(
                                title: t.get('kpi_invoices'),
                                value: "3",
                                icon: Icons.receipt),
                          ],
                        ),

                        SizedBox(height: 24),

                        // ✅ أزرار الإجراءات السريعة
                        Wrap(
                          spacing: 16,
                          children: [
                            QuickActionButton(
                                label: t.get('new_task'), icon: Icons.add_road),
                            QuickActionButton(
                                label: t.get('new_product'),
                                icon: Icons.add_box),
                            QuickActionButton(
                                label: t.get('new_invoice'),
                                icon: Icons.note_add),
                          ],
                        ),

                        SizedBox(height: 30),

                        // ✅ رسوم بيانية وهمية
                        Container(
                          height: 200,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Center(
                            child: Text("📊 ${t.get('warehouse_chart')}",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          height: 200,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          color: Colors.white,
                          child: Center(
                            child: Text("📈 ${t.get('task_chart')}",
                                style: TextStyle(fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
