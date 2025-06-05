// lib/providers/warehouse_section_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/warehouse_section.dart';

class WarehouseSectionNotifier extends StateNotifier<List<WarehouseSection>> {
  WarehouseSectionNotifier() : super([]);

  void add(WarehouseSection section) {
    state = [...state, section];
  }

  void update(WarehouseSection updatedSection) {
    state = [
      for (final section in state)
        if (section.id == updatedSection.id) updatedSection else section
    ];
  }

  void remove(String id) {
    state = state.where((section) => section.id != id).toList();
  }

  void setSections(List<WarehouseSection> sections) {
    state = sections;
  }

  WarehouseSection? getById(String id) {
    return state.firstWhere((s) => s.id == id,
        // ignore: cast_from_null_always_fails
        orElse: () => null as WarehouseSection);
  }
}

final warehouseSectionProvider =
    StateNotifierProvider<WarehouseSectionNotifier, List<WarehouseSection>>(
  (ref) => WarehouseSectionNotifier(),
);
