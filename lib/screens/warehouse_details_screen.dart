// lib/screens/warehouse_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/parent_storage_media.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';
import 'package:warehouse/services/section_api.dart';

// Distribution Centers
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/providers/distribution_center_provider.dart';
import 'package:warehouse/services/distribution_center_api.dart';

// حوارات إضافة/تعديل قسم
import 'package:warehouse/widgets/Dialogs/add_section_dialog.dart';
import 'package:warehouse/widgets/Dialogs/edit_section_dialog.dart';

class WarehouseDetailScreen extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailScreen({
    Key? key,
    required this.warehouse,
    String? warehouseId,
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
    // ✅ 4 تبويبات
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    ref.invalidate(warehouseSectionsProvider(_widInt));
    ref.invalidate(distributionCentersProvider(_widInt)); // تبويب المراكز
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
          tabs: const [
            Tab(text: 'تفاصيل'),
            Tab(text: 'مراكز التوزيع'),
            Tab(text: 'الأقسام'),
            Tab(text: 'لوحة التحكم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _OverviewTab(warehouse: widget.warehouse),
          _DistributionCentersTab(
            widInt: _widInt,
            onChanged: _refreshAll,
          ),
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

/// تبويب 1: تفاصيل المستودع
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

/// تبويب 2: مراكز التوزيع
/// TODO: انقل هذا التبويب و الحوارات ذات الصلة لملف منفصل لتخفيف هذا الملف.
class _DistributionCentersTab extends ConsumerWidget {
  const _DistributionCentersTab({
    required this.widInt,
    required this.onChanged,
  });

  final int widInt;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(distributionCentersProvider(widInt));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('مراكز التوزيع',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة مركز'),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) =>
                        _AddDistributionCenterDialog(warehouseId: widInt),
                  );
                  if (ok == true) {
                    ref.invalidate(distributionCentersProvider(widInt));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('تمت إضافة المركز'),
                      backgroundColor: Colors.green,
                    ));
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: centersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('خطأ في تحميل المراكز:\n$e'),
              ),
            ),
            data: (centers) {
              if (centers.isEmpty) {
                return const Center(
                    child: Text('لا توجد مراكز توزيع مرتبطة بهذا المستودع'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: centers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final c = centers[i];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.hub_outlined),
                      title: Text(c.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'الموقع: ${c.location} • أقسام: ${c.numSections}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                _DistributionCenterDetailsPage(center: c),
                          ),
                        );
                      },
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            tooltip: 'تعديل',
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    _EditDistributionCenterDialog(center: c),
                              );
                              if (ok == true) {
                                ref.invalidate(
                                    distributionCentersProvider(widInt));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('تم تعديل المركز'),
                                  backgroundColor: Colors.green,
                                ));
                              }
                            },
                          ),
                          IconButton(
                            tooltip: 'حذف',
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: Text('حذف "${c.name}"؟'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('حذف'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                final ok =
                                    await DistributionCenterApi.delete(c.id);
                                if (ok) {
                                  ref.invalidate(
                                      distributionCentersProvider(widInt));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('تم حذف المركز'),
                                    backgroundColor: Colors.green,
                                  ));
                                } else {
                                  final msg = DistributionCenterApi
                                          .lastErrorMessage ??
                                      'تعذّر حذف المركز (تحقق من الارتباطات)';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(msg),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
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

/// Dialog: إضافة مركز توزيع
/// TODO: انقل هذا الحوار لملف مستقل (dialogs/)
class _AddDistributionCenterDialog extends StatefulWidget {
  const _AddDistributionCenterDialog({required this.warehouseId});
  final int warehouseId;

  @override
  State<_AddDistributionCenterDialog> createState() =>
      _AddDistributionCenterDialogState();
}

class _AddDistributionCenterDialogState
    extends State<_AddDistributionCenterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _location = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _sections = TextEditingController(text: '0');

  bool _submitting = false;

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;
  String? _numReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return double.tryParse(v.trim()) == null ? 'قيمة رقمية غير صالحة' : null;
  }

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'عدد غير صالح' : null;
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _lat.dispose();
    _lng.dispose();
    _sections.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final ok = await DistributionCenterApi.create(
      name: _name.text.trim(),
      location: _location.text.trim(),
      latitude: double.parse(_lat.text.trim()),
      longitude: double.parse(_lng.text.trim()),
      warehouseId: widget.warehouseId,
      numSections: int.parse(_sections.text.trim()),
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      final msg = DistributionCenterApi.lastErrorMessage ?? 'فشل إضافة المركز';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة مركز توزيع'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                    labelText: 'الاسم', border: OutlineInputBorder()),
                validator: _req,
                enabled: !_submitting,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                    labelText: 'الموقع', border: OutlineInputBorder()),
                validator: _req,
                enabled: !_submitting,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      decoration: const InputDecoration(
                          labelText: 'Latitude', border: OutlineInputBorder()),
                      validator: _numReq,
                      enabled: !_submitting,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lng,
                      decoration: const InputDecoration(
                          labelText: 'Longitude', border: OutlineInputBorder()),
                      validator: _numReq,
                      enabled: !_submitting,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sections,
                decoration: const InputDecoration(
                    labelText: 'عدد الأقسام', border: OutlineInputBorder()),
                validator: _intReq,
                enabled: !_submitting,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context, false),
            child: const Text('إلغاء')),
        ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_submitting ? 'جارٍ الحفظ...' : 'إضافة'),
        ),
      ],
    );
  }
}

/// Dialog: تعديل مركز توزيع
/// TODO: انقل هذا الحوار لملف مستقل (dialogs/)
class _EditDistributionCenterDialog extends StatefulWidget {
  const _EditDistributionCenterDialog({required this.center});
  final DistributionCenter center;

  @override
  State<_EditDistributionCenterDialog> createState() =>
      _EditDistributionCenterDialogState();
}

class _EditDistributionCenterDialogState
    extends State<_EditDistributionCenterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _sections;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.center.name);
    _location = TextEditingController(text: widget.center.location);
    _lat = TextEditingController(text: widget.center.latitude.toString());
    _lng = TextEditingController(text: widget.center.longitude.toString());
    _sections =
        TextEditingController(text: widget.center.numSections.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _lat.dispose();
    _lng.dispose();
    _sections.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;
  String? _numReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return double.tryParse(v.trim()) == null ? 'قيمة رقمية غير صالحة' : null;
  }

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'عدد غير صالح' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final ok = await DistributionCenterApi.edit(
      id: widget.center.id,
      name: _name.text.trim(),
      location: _location.text.trim(),
      latitude: double.tryParse(_lat.text.trim()),
      longitude: double.tryParse(_lng.text.trim()),
      numSections: int.tryParse(_sections.text.trim()),
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      final msg = DistributionCenterApi.lastErrorMessage ?? 'فشل تعديل المركز';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل مركز توزيع'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'الاسم', border: OutlineInputBorder()),
                  validator: _req),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                      labelText: 'الموقع', border: OutlineInputBorder()),
                  validator: _req),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _lat,
                          decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder()),
                          validator: _numReq,
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextFormField(
                          controller: _lng,
                          decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder()),
                          validator: _numReq,
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _sections,
                  decoration: const InputDecoration(
                      labelText: 'عدد الأقسام', border: OutlineInputBorder()),
                  validator: _intReq,
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context, false),
            child: const Text('إلغاء')),
        ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_submitting ? 'جارٍ الحفظ...' : 'تحديث'),
        ),
      ],
    );
  }
}

/// صفحة تفاصيل بسيطة للمركز
/// TODO: انقل هذه الصفحة لملف مستقل (screens/)
class _DistributionCenterDetailsPage extends StatelessWidget {
  const _DistributionCenterDetailsPage({required this.center});
  final DistributionCenter center;

  String _fmt(double v) => v.toStringAsFixed(6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(center.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.place_outlined),
              title: Text(center.location),
              subtitle:
                  Text('(${_fmt(center.latitude)}, ${_fmt(center.longitude)})'),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.view_week_outlined),
              title: const Text('عدد الأقسام'),
              subtitle: Text('${center.numSections}'),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.warehouse_outlined),
              title: const Text('المستودع المرتبط'),
              subtitle: Text('#${center.warehouseId}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// تبويب 3: الأقسام — النقر يفتح شاشة تفاصيل القسم (وسائط التخزين -> كونتينرات)
class _SectionsTab extends ConsumerStatefulWidget {
  const _SectionsTab({
    required this.warehouse,
    required this.widInt,
    required this.onChanged,
  });

  final Warehouse warehouse;
  final int widInt;
  final VoidCallback onChanged;

  @override
  ConsumerState<_SectionsTab> createState() => _SectionsTabState();
}

class _SectionsTabState extends ConsumerState<_SectionsTab> {
  bool _showDeleted = true;

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(warehouseSectionsProvider(widget.widInt));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Text('الأقسام', style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              FilterChip(
                label: const Text('عرض المحذوف'),
                selected: _showDeleted,
                onSelected: (v) => setState(() => _showDeleted = v),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة قسم'),
                onPressed: () async {
                  if (ref.read(productProvider).isEmpty) {
                    await ref.read(productProvider.notifier).loadFromBackend();
                  }
                  if (!context.mounted) return;
                  showAddSectionDialog(context, ref, widget.warehouse);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => widget.onChanged(),
            child: sectionsAsync.when(
              loading: () => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 220),
                  Center(child: CircularProgressIndicator())
                ],
              ),
              error: (e, _) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 180),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('خطأ في تحميل الأقسام:\n$e'),
                    ),
                  ),
                ],
              ),
              data: (sections) {
                final list = _showDeleted
                    ? sections
                    : sections.where((s) => !s.isDeleted).toList();

                if (list.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 160),
                      Center(child: Text('لا توجد أقسام')),
                    ],
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final s = list[i];
                    final usage = s.usageRate.clamp(0.0, 1.0);
                    final isDeleted = s.isDeleted;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Icon(Icons.view_week_outlined,
                            color: isDeleted ? Colors.grey : null),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: isDeleted ? Colors.grey : null,
                                    ),
                              ),
                            ),
                            StatusChip(status: s.status),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            LinearProgressIndicator(
                              value: usage,
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade300,
                              color: usage >= 0.9
                                  ? Colors.red
                                  : (usage >= 0.7
                                      ? Colors.orange
                                      : Colors.green),
                            ),
                            const SizedBox(height: 6),
                            Text(
                                'الاستخدام: ${(usage * 100).toStringAsFixed(1)}%'),
                            Text(
                              'السعة: ${s.capacity.toStringAsFixed(0)} ${s.capacityUnit}',
                            ),
                            if (s.supportedTypeId.isNotEmpty)
                              Text('النوع المدعوم: ${s.supportedTypeId}'),
                          ],
                        ),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            IconButton(
                              tooltip: 'تعديل',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: isDeleted
                                  ? null
                                  : () async {
                                      await showDialog(
                                        context: context,
                                        builder: (_) =>
                                            EditSectionDialog(section: s),
                                      );
                                      widget.onChanged();
                                    },
                            ),
                            IconButton(
                              tooltip: isDeleted ? 'محذوف' : 'حذف',
                              icon: Icon(
                                Icons.delete_outline,
                                color: isDeleted ? Colors.grey : Colors.red,
                              ),
                              onPressed: isDeleted
                                  ? null
                                  : () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: Text(
                                              'هل تريد حذف القسم "${s.name}"؟'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('إلغاء'),
                                            ),
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
                                        final id = int.tryParse(s.id);
                                        if (id == null) return;
                                        final success =
                                            await SectionApi.deleteSection(id);
                                        if (!mounted) return;

                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: Text('تم حذف القسم'),
                                            backgroundColor: Colors.green,
                                          ));
                                          widget.onChanged();
                                        } else {
                                          final reason = SectionApi
                                                  .lastErrorMessage ??
                                              'تعذّر حذف القسم — تحقق من القيود';
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(reason),
                                            backgroundColor: Colors.red,
                                          ));
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                        // ✅ الدخول إلى شاشة تفاصيل القسم (وسائط التخزين -> كونتينرات)
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (_) =>
                                    SectionDetailsScreen(section: s),
                              ))
                              .then((_) => widget.onChanged());
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// شاشة تفاصيل القسم: وسائط التخزين في هذا القسم
/// TODO: يمكن نقلها لملف مستقل screens/section_details_screen.dart
class SectionDetailsScreen extends StatefulWidget {
  final WarehouseSection section;
  const SectionDetailsScreen({super.key, required this.section});

  @override
  State<SectionDetailsScreen> createState() => _SectionDetailsScreenState();
}

class _SectionDetailsScreenState extends State<SectionDetailsScreen> {
  Future<StorageElementsResult>? _future;

  @override
  void initState() {
    super.initState();
    final id = int.tryParse(widget.section.id);
    if (id != null) {
      _future = SectionApi.fetchStorageElementsOnSection(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('القسم: ${widget.section.name}'),
      ),
      body: _future == null
          ? const Center(child: Text('معرّف القسم غير صالح'))
          : FutureBuilder<StorageElementsResult>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('خطأ في تحميل وسائط التخزين:\n${snap.error}'),
                    ),
                  );
                }
                final res = snap.data!;
                if (res.elements.isEmpty) {
                  return const Center(
                    child: Text('لا توجد وسائط تخزين ضمن هذا القسم'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: res.elements.length + (res.parent != null ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    // صف تعريفي بالوسيط الأب (إن وجد)
                    if (res.parent != null && i == 0) {
                      final p = res.parent!;
                      return Card(
                        elevation: 1,
                        child: ListTile(
                          leading: const Icon(Icons.account_tree_outlined),
                          title: Text(
                            'الوسيط الأب: ${p.name?.isNotEmpty == true ? p.name! : '#${p.id}'}',
                          ),
                        ),
                      );
                    }

                    final idx = res.parent != null ? i - 1 : i;
                    final el = res.elements[idx];

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(el.code?.isNotEmpty == true
                            ? el.code!
                            : '#${el.id}'),
                        subtitle: (el.status == null || el.status!.isEmpty)
                            ? null
                            : Text('الحالة: ${el.status}'),
                        trailing: const Icon(Icons.chevron_right),
                        // ✅ الدخول إلى شاشة وسيطة التخزين لعرض الكونتينرات
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                StorageElementDetailsScreen(element: el),
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// شاشة تفاصيل "وسيط التخزين": تعرض الكونتينرات عليه
/// TODO: يمكن نقلها لملف مستقل screens/storage_element_details_screen.dart
class StorageElementDetailsScreen extends StatefulWidget {
  final StorageElement element;
  const StorageElementDetailsScreen({super.key, required this.element});

  @override
  State<StorageElementDetailsScreen> createState() =>
      _StorageElementDetailsScreenState();
}

class _StorageElementDetailsScreenState
    extends State<StorageElementDetailsScreen> {
  Future<List<Continer>>? _future;

  @override
  void initState() {
    super.initState();
    _future = SectionApi.fetchContainersOnStorageElement(widget.element.id);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.element.code?.isNotEmpty == true
        ? widget.element.code!
        : '#${widget.element.id}';
    return Scaffold(
      appBar: AppBar(
        title: Text('الوسيطة: $title'),
      ),
      body: FutureBuilder<List<Continer>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('خطأ في تحميل الحاويات:\n${snap.error}'),
              ),
            );
          }
          final list = snap.data ?? const [];
          if (list.isEmpty) {
            return const Center(child: Text('لا توجد حاويات على هذه الوسيطة'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = list[i];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: const Icon(Icons.all_inbox_outlined),
                  title:
                      Text(c.code?.isNotEmpty == true ? c.code! : '#${c.id}'),
                  subtitle: (c.status == null || c.status!.isEmpty)
                      ? null
                      : Text('الحالة: ${c.status}'),
                  onTap: () {
                    // لاحقًا: تفاصيل الحاوية
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// شارة حالة القسم
class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    late Color color;
    late String label;

    switch (s) {
      case 'active':
        color = Colors.green;
        label = 'نشط';
        break;
      case 'deleted':
        color = Colors.red;
        label = 'محذوف';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// تبويب 4: لوحة التحكم (كما هي)
class _ControlPanelTab extends StatelessWidget {
  const _ControlPanelTab({required this.warehouse});

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final tiles = <_ActionTile>[
      _ActionTile(
        no: 1,
        title: 'طلب منتجات من الشركة',
        subtitle: 'اقتراح فائض أو استيراد جديد',
        icon: Icons.add_shopping_cart,
        onTap: () {},
      ),
      _ActionTile(
        no: 2,
        title: 'رؤية الموظفين',
        subtitle: 'عرض طاقم المستودع',
        icon: Icons.groups_2_outlined,
        onTap: () {},
      ),
      _ActionTile(
        no: 3,
        title: 'منتجات المستودع',
        subtitle: 'عرض الكميات وطلبات داخلية',
        icon: Icons.inventory_outlined,
        onTap: () {},
      ),
      _ActionTile(
        no: 4,
        title: 'سجلات النقل',
        subtitle: 'قادمة وصادرة ضمن مدة',
        icon: Icons.local_shipping_outlined,
        onTap: () {},
      ),
      _ActionTile(
        no: 5,
        title: 'إرسال منتجات لمركز توزيع',
        subtitle: 'قيود السعات والشاحنات تلقائيًا',
        icon: Icons.send_outlined,
        onTap: () {},
      ),
      _ActionTile(
        no: 6,
        title: 'طلب وسائط تخزين',
        subtitle: 'تحديد الوسيطة وكميتها',
        icon: Icons.inventory_2_outlined,
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        itemCount: tiles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
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
              const Align(
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
