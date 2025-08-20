import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/product_provider.dart';

import 'package:warehouse/providers/warehouse_section_provider.dart';

// حوارات إضافة/تعديل قسم (الموجودة عندك)
import 'package:warehouse/widgets/Dialogs/add_section_dialog.dart';
import 'package:warehouse/widgets/Dialogs/edit_section_dialog.dart';

class WarehouseDetailScreen extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailScreen({
    Key? key,
    required this.warehouse,
    String? warehouseId, // للإبقاء على التوافق القديم (غير مستخدم)
  }) : super(key: key);

  @override
  ConsumerState<WarehouseDetailScreen> createState() =>
      _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends ConsumerState<WarehouseDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  int get _widInt => int.tryParse(widget.warehouse.id) ?? -1;

  @override
  void initState() {
    super.initState();
    // ✅ فقط 3 تبويبات الآن (تفاصيل - الأقسام - لوحة التحكم)
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    // أنعش الأقسام الخاصة بهذا المستودع
    ref.invalidate(warehouseSectionsProvider(_widInt));
    // إن احتجت لاحقًا إنعاش بيانات المستودع نفسه، أضف مزوّدًا له و invalidate
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouse.name),
        actions: [
          IconButton(
            tooltip: t.get('refresh') ?? 'تحديث',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'تفاصيل'),
            Tab(text: 'الأقسام'),
            Tab(text: 'لوحة التحكم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OverviewTab(warehouse: widget.warehouse),
          _SectionsTab(
            warehouse: widget.warehouse,
            widInt: _widInt,
            onChanged: _refreshAll,
          ),
          _ControlPanelTab(warehouse: widget.warehouse),
        ],
      ),
    );
  }
}

/// تبويب 1: تفاصيل المستودع كاملة كما يعيدها الـ API (قدر الإمكان من خصائص الموديل)
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.warehouse});

  final Warehouse warehouse;

  Color _usageColor(double v) {
    if (v < 0.7) return Colors.green;
    if (v < 0.9) return Colors.orange;
    return Colors.red;
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, height: 1.3)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usage =
        ((warehouse.usageRate ?? 0) as num).toDouble().clamp(0.0, 1.0);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // العنوان + نسبة استخدام
              Row(
                children: [
                  Expanded(
                    child: Text(
                      warehouse.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    backgroundColor: _usageColor(usage),
                    label: Text('${(usage * 100).toStringAsFixed(1)}%'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: usage,
                backgroundColor: Colors.grey.shade300,
                minHeight: 8,
              ),
              const SizedBox(height: 24),

              // معلومات تفصيلية (كل ما هو متوفر في الموديل)
              _row('المعرّف', warehouse.id),
              _row('الاسم', warehouse.name),
              _row('الموقع', warehouse.location ?? ''),
              _row('Latitude', (warehouse.latitude?.toString() ?? '')),
              _row('Longitude', (warehouse.longitude?.toString() ?? '')),
              _row('نوع المستودع', warehouse.typeName ?? ''),
              _row('type_id', (warehouse.typeId?.toString() ?? '')),
              _row('عدد الأقسام', (warehouse.numSections?.toString() ?? '')),
              _row(
                'السعة',
                warehouse.capacity != null
                    ? '${warehouse.capacity} ${warehouse.capacityUnit ?? ''}'
                    : '',
              ),
              _row('تاريخ الإنشاء', _fmtDate(warehouse.createdAt)),
              _row('آخر تحديث', _fmtDate(warehouse.updatedAt)),
            ],
          ),
        ),
      ),
    );
  }
}

/// تبويب 2: الأقسام — قوائم حقيقية مربوطة بمزوّد الأقسام + حوارات إضافة/تعديل/حذف
class _SectionsTab extends ConsumerWidget {
  const _SectionsTab({
    required this.warehouse,
    required this.widInt,
    required this.onChanged,
  });

  final Warehouse warehouse;
  final int widInt;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(warehouseSectionsProvider(widInt));

    return Column(
      children: [
        // شريط علوي لإضافة قسم
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('الأقسام', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة قسم'),
                  onPressed: () async {
                    // لو اللستة فاضية حمّلها من الباك أولاً
                    if (ref.read(productProvider).isEmpty) {
                      await ref
                          .read(productProvider.notifier)
                          .loadFromBackend();
                    }
                    if (!context.mounted) return;
                    showAddSectionDialog(context, ref, warehouse);
                  }),
            ],
          ),
        ),

        Expanded(
          child: sectionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('خطأ في تحميل الأقسام:\n$e'),
              ),
            ),
            data: (sections) {
              if (sections.isEmpty) {
                return const Center(child: Text('لا توجد أقسام بعد'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final s = sections[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const Icon(Icons.view_week_outlined),
                      title: Text(
                        s.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (s.capacity != null)
                            Text(
                                'السعة: ${s.capacity} ${s.capacityUnit ?? ''}'),
                          if ((s.supportedTypeId ?? '').toString().isNotEmpty)
                            Text('النوع المدعوم: ${s.supportedTypeId}'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            tooltip: 'تعديل',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (_) => EditSectionDialog(section: s),
                              );
                              onChanged();
                            },
                          ),
                          IconButton(
                            tooltip: 'حذف',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content:
                                      Text('هل تريد حذف القسم "${s.name}"؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('إلغاء')),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text('حذف'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                // عندك SectionApi.deleteSection في حوار التعديل — استخدمه هنا أيضًا إن أردت
                                // TODO: اربط بحذف القسم الفعلي ثم:
                                onChanged();
                              }
                            },
                          ),
                        ],
                      ),
                      // مستقبلًا: فتح إدارة القسم التفصيلية (طوابق/صفوف/مواقع/وسائط تخزين)
                      onTap: () {
                        // TODO: افتح شاشة إدارة القسم عند تجهيزها
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// تبويب 3: لوحة التحكم — بطاقات عمليات المدير (1→20)
class _ControlPanelTab extends StatelessWidget {
  const _ControlPanelTab({required this.warehouse});

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final tiles = <_ActionTile>[
      _ActionTile(
        no: 1,
        title: 'إحصائيات المنتجات',
        subtitle: 'نِسب الاستهلاك ولوحات بيانية',
        icon: Icons.pie_chart_outline,
        onTap: () {
          // TODO: ربط بـ GET show_products_of_place (6) أو endpoint إحصائي
        },
      ),
      _ActionTile(
        no: 2,
        title: 'طلب منتجات من الشركة',
        subtitle: 'اقتراح فائض أو استيراد جديد',
        icon: Icons.add_shopping_cart,
        onTap: () {
          // TODO: POST api/ask_products_from_up  (12)
        },
      ),
      _ActionTile(
        no: 3,
        title: 'رؤية الموظفين',
        subtitle: 'عرض طاقم المستودع',
        icon: Icons.groups_2_outlined,
        onTap: () {
          // TODO: GET show_my_work_place (8) أو endpoint الموظفين
        },
      ),
      _ActionTile(
        no: 4,
        title: 'تعديل حالة الموظفين',
        subtitle: 'تبديل مواقع/مهام (دون تغيير الاختصاص)',
        icon: Icons.manage_accounts_outlined,
        onTap: () {
          // TODO: PATCH/POST لواجهات إدارة الموظفين
        },
      ),
      _ActionTile(
        no: 5,
        title: 'طلب موظفين من الشركة',
        subtitle: 'تحديد الاختصاص والكمية',
        icon: Icons.badge_outlined,
        onTap: () {
          // TODO: واجهة طلب موظفين
        },
      ),
      _ActionTile(
        no: 6,
        title: 'أقسام المستودع',
        subtitle: 'إدارة الأقسام',
        icon: Icons.view_week_outlined,
        onTap: () {
          DefaultTabController.of(context)
              ?.animateTo(1); // انتقل لتبويب الأقسام
        },
      ),
      _ActionTile(
        no: 7,
        title: 'حالة القسم',
        subtitle: 'تنشيط/تعطيل',
        icon: Icons.toggle_on_outlined,
        onTap: () {
          // TODO: تفعيل/تعطيل قسم
        },
      ),
      _ActionTile(
        no: 8,
        title: 'تفاصيل القسم',
        subtitle: 'المواقع والمساحات المتاحة',
        icon: Icons.grid_view_outlined,
        onTap: () {},
      ),
      _ActionTile(
        no: 9,
        title: 'طلب وسائط تخزين',
        subtitle: 'تحديد الوسيطة وكميتها',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          // TODO: طلب وسائط تخزين
        },
      ),
      _ActionTile(
        no: 10,
        title: 'محتويات وسيطة التخزين',
        subtitle: 'الحاويات وحالتها',
        icon: Icons.view_in_ar_outlined,
        onTap: () {
          // TODO
        },
      ),
      _ActionTile(
        no: 11,
        title: 'تفاصيل الحاوية',
        subtitle: 'مرفوض/مقبول/الحمولة الحالية',
        icon: Icons.all_inbox_outlined,
        onTap: () {
          // TODO
        },
      ),
      _ActionTile(
        no: 12,
        title: 'إعدادات الحاوية',
        subtitle: 'رفض/نقل/إزالة',
        icon: Icons.settings_outlined,
        onTap: () {
          // TODO
        },
      ),
      _ActionTile(
        no: 13,
        title: 'سجلات النقل',
        subtitle: 'قادمة وصادرة ضمن مدة',
        icon: Icons.local_shipping_outlined,
        onTap: () {
          // TODO: GET api/show_incoming_transfers/Warehouse/{id} (7)
        },
      ),
      _ActionTile(
        no: 15 - 1,
        title: 'جرد ضمن مدة',
        subtitle: 'وارد/صادر/مرفوض/تكاليف',
        icon: Icons.summarize_outlined,
        onTap: () {
          // TODO
        },
      ),
      _ActionTile(
        no: 16 - 1,
        title: 'جرد المراكز التابعة',
        subtitle: 'تفاصيل النقل والتكاليف',
        icon: Icons.account_tree_outlined,
        onTap: () {
          // TODO
        },
      ),
      _ActionTile(
        no: 17 - 1,
        title: 'مراكز التوزيع المرتبطة',
        subtitle: 'رؤية وإدارة المراكز',
        icon: Icons.hub_outlined,
        onTap: () {
          // TODO: GET api/show_distrebution_centers_of_warehouse/{id} (2/3/4/5)
        },
      ),
      _ActionTile(
        no: 18 - 1,
        title: 'إرسال منتجات لمركز توزيع',
        subtitle: 'قيود السعات والشاحنات تلقائيًا',
        icon: Icons.send_outlined,
        onTap: () {
          // TODO: POST api/send_products_from_To (1)
        },
      ),
      _ActionTile(
        no: 19 - 1,
        title: 'منتجات المستودع',
        subtitle: 'عرض الكميات وطلبات داخلية',
        icon: Icons.inventory_outlined,
        onTap: () {
          // TODO: GET /show_products_of_place (6)
        },
      ),
      _ActionTile(
        no: 20 - 1,
        title: 'الإدارة التلقائية',
        subtitle: 'تشغيل/إيقاف الأتمتة',
        icon: Icons.rocket_launch_outlined,
        onTap: () {
          // TODO: POST api/activate_inv (13)
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // مظهر احترافي على الشاشات العريضة
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (_, i) => _ControlCard(tile: tiles[i]),
      ),
    );
  }
}

class _ActionTile {
  final int no;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  _ActionTile({
    required this.no,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({required this.tile});
  final _ActionTile tile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: tile.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                child: Text(tile.no.toString()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(tile.icon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tile.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tile.subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.black54),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.chevron_right, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
