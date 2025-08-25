// lib/screens/distribution_center_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/models/parent_storage_media.dart';
import 'package:warehouse/services/section_api.dart';

// شاشة الموظفين (تُستخدم داخل تبويب الموظفين)
import 'package:warehouse/screens/employees_screen.dart';

/// شاشة تفاصيل مركز توزيع
class DistributionCenterDetailsScreen extends ConsumerStatefulWidget {
  final DistributionCenter center;
  const DistributionCenterDetailsScreen({super.key, required this.center});

  @override
  ConsumerState<DistributionCenterDetailsScreen> createState() =>
      _DistributionCenterDetailsScreenState();
}

class _DistributionCenterDetailsScreenState
    extends ConsumerState<DistributionCenterDetailsScreen>
    with TickerProviderStateMixin {
  late final TabController _tab;

  int get _dcId => widget.center.id;

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
    setState(() {}); // إعادة بناء الـ FutureBuilders بالتبويبات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.center.name),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: _refreshAll,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'تفاصيل'),
            Tab(text: 'الأقسام'),
            Tab(text: 'الموظفون'),
            Tab(text: 'لوحة التحكم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _DcOverviewTab(center: widget.center),
          _DcSectionsTab(dcId: _dcId),
          // ✅ تبويب الموظفين الآن يعرض شاشة الموظفين مباشرة
          EmployeesScreen(
            placeType: 'DistributionCenter',
            placeId: _dcId,
            // placeName: widget.center.name,
          ),
          const _DcControlPanelTab(), // بدون بطاقة الموظفين
        ],
      ),
    );
  }
}

/// تبويب 1: تفاصيل مركز التوزيع
class _DcOverviewTab extends StatelessWidget {
  const _DcOverviewTab({required this.center});
  final DistributionCenter center;

  String _fmtD(double v) => v.toStringAsFixed(6);

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, height: 1.3)),
            ),
            const SizedBox(width: 8),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      center.name,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if ((center.typeName ?? '').isNotEmpty)
                    Chip(label: Text(center.typeName!)),
                ],
              ),
              const SizedBox(height: 16),
              _row('المعرّف', '${center.id}'),
              _row('الاسم', center.name),
              _row('الموقع', center.location),
              _row('Latitude', _fmtD(center.latitude)),
              _row('Longitude', _fmtD(center.longitude)),
              _row('عدد الأقسام', '${center.numSections}'),
              if (center.warehouseId != null)
                _row('المستودع المرتبط', '#${center.warehouseId}'),
            ],
          ),
        ),
      ),
    );
  }
}

/// تبويب 2: الأقسام الخاصة بمركز التوزيع
class _DcSectionsTab extends StatefulWidget {
  const _DcSectionsTab({required this.dcId});
  final int dcId;

  @override
  State<_DcSectionsTab> createState() => _DcSectionsTabState();
}

class _DcSectionsTabState extends State<_DcSectionsTab> {
  late Future<List<WarehouseSection>> _future;

  @override
  void initState() {
    super.initState();
    _future = SectionApi.fetchSectionsByDistributionCenter(widget.dcId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WarehouseSection>>(
      future: _future,
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('خطأ في تحميل الأقسام:\n${snap.error}')));
        }
        final list = snap.data ?? const <WarehouseSection>[];
        if (list.isEmpty) {
          return const Center(child: Text('لا توجد أقسام لهذا المركز'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final s = list[i];
            final usage = s.usageRate.clamp(0.0, 1.0);
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
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: usage,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 6),
                    Text('الاستخدام: ${(usage * 100).toStringAsFixed(1)}%'),
                    Text(
                        'السعة: ${s.capacity.toStringAsFixed(0)} ${s.capacityUnit}'),
                    if (s.supportedTypeId.isNotEmpty)
                      Text('النوع المدعوم: ${s.supportedTypeId}'),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => _DcSectionDetailsScreen(section: s),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

/// شاشة تفاصيل القسم (نسخة خفيفة خاصة بمراكز التوزيع)
class _DcSectionDetailsScreen extends StatefulWidget {
  final WarehouseSection section;
  const _DcSectionDetailsScreen({required this.section});

  @override
  State<_DcSectionDetailsScreen> createState() =>
      _DcSectionDetailsScreenState();
}

class _DcSectionDetailsScreenState extends State<_DcSectionDetailsScreen> {
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
      appBar: AppBar(title: Text('القسم: ${widget.section.name}')),
      body: _future == null
          ? const Center(child: Text('معرّف القسم غير صالح'))
          : FutureBuilder<StorageElementsResult>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                      child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('خطأ في تحميل وسائط التخزين:\n${snap.error}'),
                  ));
                }
                final res = snap.data!;
                if (res.elements.isEmpty) {
                  return const Center(child: Text('لا توجد وسائط تخزين'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: res.elements.length + (res.parent != null ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
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
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text(el.code?.isNotEmpty == true
                            ? el.code!
                            : '#${el.id}'),
                        subtitle: (el.status == null || el.status!.isEmpty)
                            ? null
                            : Text('الحالة: ${el.status}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  _StorageElementDetailsScreen(element: el),
                            ),
                          );
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

/// تفاصيل وسيطة التخزين: تعرض الكونتينرات
class _StorageElementDetailsScreen extends StatefulWidget {
  final StorageElement element;
  const _StorageElementDetailsScreen({required this.element});

  @override
  State<_StorageElementDetailsScreen> createState() =>
      _StorageElementDetailsScreenState();
}

class _StorageElementDetailsScreenState
    extends State<_StorageElementDetailsScreen> {
  late Future<List<Continer>> _future;

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
      appBar: AppBar(title: Text('الوسيطة: $title')),
      body: FutureBuilder<List<Continer>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('خطأ في تحميل الحاويات:\n${snap.error}'),
            ));
          }
          final list = snap.data ?? const <Continer>[];
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
                child: ListTile(
                  leading: const Icon(Icons.all_inbox_outlined),
                  title:
                      Text(c.code?.isNotEmpty == true ? c.code! : '#${c.id}'),
                  subtitle: (c.status == null || c.status!.isEmpty)
                      ? null
                      : Text('الحالة: ${c.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// تبويب 4: لوحة التحكم — تم حذف بطاقة “الموظفون”
class _DcControlPanelTab extends StatelessWidget {
  const _DcControlPanelTab({super.key});

  @override
  Widget build(BuildContext context) {
    // يمكنك لاحقًا إضافة بطاقات أخرى هنا
    return const Center(
      child: Text('لا توجد عناصر في لوحة التحكم بعد'),
    );
  }
}
