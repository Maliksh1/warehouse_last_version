// lib/providers/warehouse_section_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/warehouse_section.dart';
import '../services/section_api.dart';

class WarehouseSectionNotifier extends StateNotifier<List<WarehouseSection>> {
  WarehouseSectionNotifier() : super(const []);

  void add(WarehouseSection section) {
    state = [...state, section];
  }

  void update(WarehouseSection updated) {
    state = [
      for (final s in state)
        if (s.id == updated.id) updated else s,
    ];
  }

  void remove(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void setSections(List<WarehouseSection> sections) {
    state = sections;
  }

  WarehouseSection? getById(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

// حالة محلية قابلة للتعديل
final warehouseSectionProvider =
    StateNotifierProvider<WarehouseSectionNotifier, List<WarehouseSection>>(
  (ref) => WarehouseSectionNotifier(),
);

// مزوّد عائلي يجلب الأقسام لمستودع محدد
final warehouseSectionsProvider =
    FutureProvider.family.autoDispose<List<WarehouseSection>, int>(
  (ref, warehouseId) async {
    final api = SectionApi(); // <-- مهم: instance وليس static
    final sections = await api.fetchSectionsByWarehouse(warehouseId);

    // مزامنة الحالة المحلية (اختياري لكنه مفيد)
    ref.read(warehouseSectionProvider.notifier).setSections(sections);

    return sections;
  },
);
