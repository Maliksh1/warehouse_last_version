import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/warehouse_provider.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/widgets/Dialogs/add_warehouse_dialog.dart';
import 'package:warehouse/widgets/Dialogs/edit_warehouse_dialog.dart';
import 'package:warehouse/screens/warehouse_details_screen.dart';

class WarehousesScreen extends ConsumerStatefulWidget {
  const WarehousesScreen({super.key});

  @override
  ConsumerState<WarehousesScreen> createState() => _WarehousesScreenState();
}

class _WarehousesScreenState extends ConsumerState<WarehousesScreen> {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    // تحميل المستودعات عند الدخول
    Future.microtask(() => ref.read(warehouseProvider.notifier).reload());
  }

  Future<void> _reload() async {
    setState(() => _refreshing = true);
    await ref.read(warehouseProvider.notifier).reload();
    if (mounted) setState(() => _refreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final warehouses = ref.watch(warehouseProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.get('warehouses') ?? 'Warehouses'),
        actions: [
          IconButton(
            tooltip: t.get('refresh') ?? 'تحديث',
            onPressed: _refreshing ? null : _reload,
            icon: _refreshing
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await showAddWarehouseDialog(context, ref);
          if (added == true && mounted) {
            await _reload();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(t.get('warehouse_added_successfully') ??
                  'تمت إضافة المستودع بنجاح'),
              backgroundColor: Colors.green,
            ));
          }
        },
        icon: const Icon(Icons.add),
        label: Text(t.get('add_new_warehouse_button') ?? 'إضافة مستودع'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          onRefresh: _reload,
          child: warehouses.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Center(
                        child: Text(
                            t.get('no_data_available') ?? 'لا توجد بيانات')),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: warehouses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final w = warehouses[index];
                    return _WarehouseCard(
                      warehouse: w,
                      onTap: () {
                        // الانتقال لشاشة التفاصيل لاحقًا (موجودة لديك)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WarehouseDetailScreen(
                              warehouseId: w.id,
                              warehouse: w,
                            ),
                          ),
                        );
                      },
                      onEdit: () async {
                        final edited =
                            await showEditWarehouseDialog(context, ref, w);
                        if (edited == true) {
                          await _reload();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(t.get('saved_successfully') ??
                                'تم الحفظ بنجاح'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title:
                                Text(t.get('confirm_delete') ?? 'تأكيد الحذف'),
                            content: Text(t.get('are_you_sure_to_delete') ??
                                'هل أنت متأكد من الحذف؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(t.get('cancel') ?? 'إلغاء'),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                onPressed: () => Navigator.pop(context, true),
                                label: Text(t.get('delete') ?? 'حذف'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          final idInt = int.tryParse(w.id);
                          if (idInt == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Invalid id: ${w.id}'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }

                          final ok = await WarehouseApi.deleteWarehouse(idInt);
                          if (ok) {
                            await _reload();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(t.get('deleted_successfully') ??
                                  'تم الحذف بنجاح'),
                              backgroundColor: Colors.green,
                            ));
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                t.get('delete_failed_related_data') ??
                                    'تعذر الحذف لوجود علاقات/عمليات مرتبطة',
                              ),
                              backgroundColor: Colors.orange,
                            ));
                          }
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _WarehouseCard extends StatelessWidget {
  const _WarehouseCard({
    required this.warehouse,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Warehouse warehouse;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final capacityTxt = (warehouse.capacity != null &&
            (warehouse.capacityUnit ?? '').isNotEmpty)
        ? "${warehouse.capacity} ${warehouse.capacityUnit}"
        : null;

    final usage = warehouse.usageRate; // 0..1 أو null
    final usageVal = (usage ?? 0).clamp(0, 1).toDouble();

    Color barColor;
    if (usageVal > 0.8) {
      barColor = Colors.red;
    } else if (usageVal > 0.6) {
      barColor = Colors.orange;
    } else {
      barColor = Theme.of(context).colorScheme.primary;
    }

    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap, // 👈 قابل للنقر بالكامل
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (ctx, c) {
              final wide = c.maxWidth > 640; // تنسيق مختلف للشاشات الواسعة
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان + شارة النوع + قائمة الأوامر
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              warehouse.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            if ((warehouse.typeName ?? '').isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  warehouse.typeName!,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // أزرار الإجراءات
                      if (wide)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: t.get('edit') ?? 'تعديل',
                              child: IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: onEdit,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: t.get('delete') ?? 'حذف',
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: onDelete,
                              ),
                            ),
                          ],
                        )
                      else
                        PopupMenuButton<String>(
                          tooltip: t.get('more') ?? 'المزيد',
                          onSelected: (v) {
                            if (v == 'edit') onEdit();
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Text(t.get('edit') ?? 'تعديل'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text(t.get('delete') ?? 'حذف'),
                                ],
                              ),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // معلومات تفصيلية
                  Wrap(
                    spacing: 18,
                    runSpacing: 6,
                    children: [
                      if ((warehouse.location ?? '').isNotEmpty)
                        _kv(
                          icon: Icons.location_on_outlined,
                          label: t.get('location') ?? 'الموقع',
                          value: warehouse.location!,
                        ),
                      if (capacityTxt != null)
                        _kv(
                          icon: Icons.inventory_2_outlined,
                          label: t.get('capacity') ?? 'السعة',
                          value: capacityTxt,
                        ),
                      if (warehouse.latitude != null &&
                          warehouse.longitude != null)
                        _kv(
                          icon: Icons.map_outlined,
                          label: 'Lat/Lng',
                          value:
                              '${warehouse.latitude}, ${warehouse.longitude}',
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (warehouse.usageRate != null) ...[
                    Text(
                      "${(usageVal * 100).toInt()}% ${t.get('occupancy') ?? 'الإشغال'}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: usageVal,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade300,
                        color: barColor,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _kv(
      {required IconData icon, required String label, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(value, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
