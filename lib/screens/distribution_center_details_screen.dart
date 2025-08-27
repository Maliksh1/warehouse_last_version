// lib/screens/distribution_center_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/api_service_provider.dart';
import 'package:warehouse/screens/garage_screen.dart';
import 'package:warehouse/services/section_api.dart';
import 'package:warehouse/screens/employees_screen.dart';
import 'package:warehouse/widgets/Dialogs/edit_section_dialog.dart';

class DistributionCenterDetailsScreen extends StatefulWidget {
  final DistributionCenter center;
  const DistributionCenterDetailsScreen({super.key, required this.center});

  @override
  State<DistributionCenterDetailsScreen> createState() =>
      _DistributionCenterDetailsScreenState();
}

class _DistributionCenterDetailsScreenState
    extends State<DistributionCenterDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.center.name),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'تفاصيل'),
            Tab(icon: Icon(Icons.view_week_outlined), text: 'الأقسام'),
            Tab(icon: Icon(Icons.garage_outlined), text: 'الكراج'),
            Tab(icon: Icon(Icons.people_outline), text: 'الموظفون'),
            Tab(icon: Icon(Icons.dashboard_outlined), text: 'لوحة التحكم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _DcOverviewTab(center: widget.center),
          _DcSectionsTab(center: widget.center),
          GarageScreen(
              placeType: 'DistributionCenter', placeId: widget.center.id),
          EmployeesScreen(
            placeType: 'DistributionCenter',
            placeId: widget.center.id,
          ),
          EmployeesScreen(
            placeType: 'DistributionCenter',
            placeId: widget.center.id,
          ),
          const _DcControlPanelTab(),
        ],
      ),
    );
  }
}

// Tab 1: Overview
class _DcOverviewTab extends StatelessWidget {
  const _DcOverviewTab({required this.center});
  final DistributionCenter center;

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(value.isEmpty ? '—' : value)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _row('الاسم', center.name),
              _row('الموقع', center.location),
              _row('الإحداثيات', '${center.latitude}, ${center.longitude}'),
              _row('عدد الأقسام', '${center.numSections}'),
              _row('المستودع المرتبط', 'ID #${center.warehouseId}'),
            ],
          ),
        ),
      ),
    );
  }
}

// Tab 2: Sections
class _DcSectionsTab extends StatefulWidget {
  final DistributionCenter center;
  const _DcSectionsTab({required this.center});

  @override
  State<_DcSectionsTab> createState() => _DcSectionsTabState();
}

class _DcSectionsTabState extends State<_DcSectionsTab> {
  late Future<List<WarehouseSection>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _sectionsFuture =
        SectionApi.fetchSectionsByDistributionCenter(widget.center.id);
  }

  void _refresh() {
    setState(() {
      _sectionsFuture =
          SectionApi.fetchSectionsByDistributionCenter(widget.center.id);
    });
  }

  void _addSection() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _AddSectionToCenterDialog(center: widget.center),
    );
    if (result == true) {
      _refresh();
    }
  }

  void _editSection(WarehouseSection section) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditSectionDialog(section: section),
    );
    if (result == true) {
      _refresh();
    }
  }

  void _deleteSection(WarehouseSection section) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: Text('هل تريد إلغاء القسم "${section.name}"؟ (سيتم أرشفته)'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('تراجع')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final id = int.tryParse(section.id);
      if (id == null) return;
      final success = await SectionApi.deleteSection(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(success
              ? 'تم إلغاء القسم بنجاح'
              : (SectionApi.lastErrorMessage ?? 'فشل الإلغاء')),
          backgroundColor: success ? Colors.green : Colors.red,
        ));
        if (success) _refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'DistributionCenterDetailsFAB',
        onPressed: _addSection,
        label: const Text('إضافة قسم'),
        icon: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<WarehouseSection>>(
        future: _sectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          final sections = snapshot.data ?? [];
          if (sections.isEmpty) {
            return const Center(
                child: Text('لا توجد أقسام في هذا المركز بعد.'));
          }
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                return _SectionCard(
                  section: section,
                  onEdit: () => _editSection(section),
                  onDelete: () => _deleteSection(section),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Professional looking card for a section
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
                Text(section.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          decoration:
                              isCancelled ? TextDecoration.lineThrough : null,
                        )),
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
            Text('المنتج المدعوم: ID #${section.supportedTypeId}',
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

// Tab 3: Employees (already implemented)

// Tab 4: Control Panel
class _DcControlPanelTab extends StatelessWidget {
  const _DcControlPanelTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('لوحة التحكم الخاصة بمركز التوزيع'),
    );
  }
}

// Dialog for adding a section to a Distribution Center
class _AddSectionToCenterDialog extends ConsumerStatefulWidget {
  final DistributionCenter center;
  const _AddSectionToCenterDialog({required this.center});

  @override
  ConsumerState<_AddSectionToCenterDialog> createState() =>
      _AddSectionToCenterDialogState();
}

class _AddSectionToCenterDialogState
    extends ConsumerState<_AddSectionToCenterDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _floorsCtrl = TextEditingController();
  final _classesCtrl = TextEditingController();
  final _positionsCtrl = TextEditingController();

  String? _selectedProductId;
  bool _submitting = false;
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    final apiService = ref.read(apiServiceProvider);
    _productsFuture = apiService.getProducts().then((list) {
      return list
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _floorsCtrl.dispose();
    _classesCtrl.dispose();
    _positionsCtrl.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;
  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'رقم غير صالح' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('الرجاء اختيار المنتج الخاص بالقسم'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    final payload = <String, dynamic>{
      "existable_type": "DistributionCenter",
      "existable_id": widget.center.id,
      "product_id": int.tryParse(_selectedProductId!) ?? _selectedProductId,
      "num_floors": int.parse(_floorsCtrl.text.trim()),
      "num_classes": int.parse(_classesCtrl.text.trim()),
      "num_positions_on_class": int.parse(_positionsCtrl.text.trim()),
      "name": _nameCtrl.text.trim(),
    };

    setState(() => _submitting = true);
    try {
      final ok = await SectionApi.createSection(payload);
      if (mounted) {
        Navigator.pop(context, ok);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('فشل الإرسال: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة قسم جديد'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('لا توجد منتجات لإضافتها');
                  }
                  return DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'المنتج المخزَّن في هذا القسم',
                      border: OutlineInputBorder(),
                    ),
                    items: snapshot.data!.map((p) {
                      return DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.name),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedProductId = v),
                    validator: (v) => v == null ? 'مطلوب' : null,
                  );
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'اسم القسم', border: OutlineInputBorder()),
                  validator: _req),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: TextFormField(
                          controller: _floorsCtrl,
                          decoration: const InputDecoration(
                              labelText: 'عدد الطوابق',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: _intReq)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: TextFormField(
                          controller: _classesCtrl,
                          decoration: const InputDecoration(
                              labelText: 'عدد الصفوف',
                              border: OutlineInputBorder()),
                          keyboardType: TextInputType.number,
                          validator: _intReq)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _positionsCtrl,
                  decoration: const InputDecoration(
                      labelText: 'عدد المواقع في الصف',
                      border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: _intReq),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
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
