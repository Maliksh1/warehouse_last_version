// lib/screens/warehouse_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/transfer.dart';
import 'package:warehouse/screens/send_products_screen.dart';
import 'package:warehouse/screens/wizards/product_import_wizard.dart';
import 'package:warehouse/widgets/send_products_card.dart';
import 'package:warehouse/models/transfer_request.dart';

import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/parent_storage_media.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';
import 'package:warehouse/screens/employees_screen.dart';
import 'package:warehouse/screens/garage_screen.dart';
import 'package:warehouse/screens/place_product_screen.dart';
import 'package:warehouse/services/section_api.dart';

// Distribution Centers
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/providers/distribution_center_provider.dart';
import 'package:warehouse/services/distribution_center_api.dart';
import 'package:warehouse/screens/distribution_center_details_screen.dart';
import 'package:warehouse/services/warehouse_api.dart';
// حوارات إضافة/تعديل قسم
import 'package:warehouse/widgets/Dialogs/add_section_dialog.dart';
import 'package:warehouse/widgets/Dialogs/edit_section_dialog.dart';
import 'package:warehouse/widgets/transfer_logs_card.dart';

class WarehouseDetailScreen extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailScreen({
    Key? key,
    required this.warehouse,
    int? warehouseId,
  }) : super(key: key);

  @override
  ConsumerState<WarehouseDetailScreen> createState() =>
      _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends ConsumerState<WarehouseDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  int get _widInt => (widget.warehouse.id) ?? -1;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    ref.invalidate(warehouseSectionsProvider(_widInt));
    ref.invalidate(distributionCentersProvider(_widInt));
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
              _row('المعرّف', warehouse.id.toString()), // تم التعديل هنا
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

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_center', // **[FIXED]** Unique Hero Tag
        icon: const Icon(Icons.add),
        label: const Text('إضافة مركز'),
        onPressed: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => _AddDistributionCenterDialog(warehouseId: widInt),
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
      body: centersAsync.when(
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
                  subtitle:
                      Text('الموقع: ${c.location} • أقسام: ${c.numSections}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DistributionCenterDetailsScreen(center: c),
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
                            ref.invalidate(distributionCentersProvider(widInt));
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
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
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
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            final ok = await DistributionCenterApi.delete(c.id);
                            if (ok) {
                              ref.invalidate(
                                  distributionCentersProvider(widInt));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('تم حذف المركز'),
                                backgroundColor: Colors.green,
                              ));
                            } else {
                              final msg =
                                  DistributionCenterApi.lastErrorMessage ??
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
    );
  }
}

/// Dialog: إضافة مركز توزيع
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

/// تبويب 3: الأقسام
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
  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(warehouseSectionsProvider(widget.widInt));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_section', // **[FIXED]** Unique Hero Tag
        onPressed: () async {
          if (ref.read(productProvider).isEmpty) {
            await ref.read(productProvider.notifier).loadFromBackend();
          }
          if (!context.mounted) return;
          showAddSectionDialog(context, ref, widget.warehouse);
        },
        label: const Text('إضافة قسم'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => widget.onChanged(),
        child: sectionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('خطأ في تحميل الأقسام:\n$e')),
          data: (sections) {
            if (sections.isEmpty) {
              return const Center(child: Text('لا توجد أقسام'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (_, i) {
                final s = sections[i];
                return _SectionCard(
                  section: s,
                  onEdit: () async {
                    await showDialog(
                      context: context,
                      builder: (_) => EditSectionDialog(section: s),
                    );
                    widget.onChanged();
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('تأكيد الإلغاء'),
                        content: Text(
                            'هل تريد إلغاء القسم "${s.name}"؟ (سيتم أرشفته)'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('تراجع')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('نعم، إلغاء'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final id = int.tryParse(s.id);
                      if (id == null) return;
                      final success = await SectionApi.deleteSection(id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(success
                              ? 'تم إلغاء القسم بنجاح'
                              : (SectionApi.lastErrorMessage ?? 'فشل الإلغاء')),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ));
                        if (success) widget.onChanged();
                      }
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final WarehouseSection section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectionCard(
      {required this.section, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final usage = section.usageRate.clamp(0.0, 1.0);
    final isCancelled = section.status.toLowerCase() == 'deleted';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      color: isCancelled ? Colors.grey.shade200 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        decoration:
                            isCancelled ? TextDecoration.lineThrough : null,
                      ),
                ),
                if (!isCancelled)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'delete') onDelete();
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('تعديل')),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                            leading: Icon(Icons.cancel_outlined,
                                color: Colors.orange),
                            title: Text('إلغاء')),
                      ),
                    ],
                  )
                else
                  Chip(
                      label: Text('ملغي'),
                      backgroundColor: Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 8),
            Text('النوع المدعوم: ID #${section.supportedTypeId}',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usage,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 4),
            Text(
                'الإشغال: ${(usage * 100).toStringAsFixed(1)}% (${section.occupied.toInt()}/${section.capacity.toInt()})'),
          ],
        ),
      ),
    );
  }
}

/// تبويب 4: لوحة التحكم
class _ControlPanelTab extends StatelessWidget {
  const _ControlPanelTab({required this.warehouse});

  final Warehouse warehouse;

  @override
  Widget build(BuildContext context) {
    final wid = (warehouse.id) ?? -1;
    final tiles = <_ActionTile>[
      _ActionTile(
        no: 1,
        title: 'طلب منتجات من الشركة',
        subtitle: 'بدء عملية استيراد جديدة لهذا المستودع',
        icon: Icons.add_shopping_cart,
        onTap: () {
          // عند الضغط، انتقل إلى معالج الاستيراد ومرر معرّف المستودع
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => ProductImportWizard(
                preselectedWarehouseId: warehouse.id,
              ),
            ),
          );
        },
      ),
      _ActionTile(
        no: 2,
        title: 'الموظفون',
        subtitle: 'عرض طاقم المستودع',
        icon: Icons.groups_2_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EmployeesScreen(
                placeType: 'Warehouse',
                placeId: wid,
              ),
            ),
          );
        },
      ),
      _ActionTile(
        no: 3,
        title: 'منتجات المستودع',
        subtitle: 'عرض الكميات وطلبات داخلية',
        icon: Icons.inventory_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PlaceProductsScreen(
                placeType: 'warehouse', // تحديد النوع
                placeId: wid,
                placeName: warehouse.name,
              ),
            ),
          );
        },
      ),
      _ActionTile(
          no: 4,
          title: 'سجلات النقل',
          subtitle: 'قادمة وصادرة ضمن مدة',
          icon: Icons.local_shipping_outlined,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => TransferLogsCard(
                    type: TransferLogType.outgoing,
                    placeType: 'Warehouse',
                    placeId: wid)));

            SizedBox(height: 12);
          }),
      _ActionTile(
        no: 5,
        title: 'إرسال منتجات لمركز توزيع',
        subtitle: 'قيود السعات والشاحنات تلقائيًا',
        icon: Icons.send_outlined,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => SendProductsScreen(
              prefillSourceType: PlaceType.Warehouse,
              prefillSourceId: warehouse.id, // المعرّف الحالي للمستودع المفتوح
            ),
          ));
        },
      ),
      _ActionTile(
        no: 6,
        title: '  سجلات النقل الواردات',
        subtitle: '  سجل الواردات وتفاصيله',
        icon: Icons.inventory_2_outlined,
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => TransferLogsCard(
                  type: TransferLogType.incoming,
                  placeType: 'Warehouse',
                  placeId: wid)));
        },
      ),
      // **[NEW]** Garage Card
      _ActionTile(
        no: 7,
        title: 'الكراجات',
        subtitle: 'عرض وإدارة الكراجات',
        icon: Icons.garage_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => GarageScreen(
                placeType: 'Warehouse',
                placeId: wid,
              ),
            ),
          );
        },
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
