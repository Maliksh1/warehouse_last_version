// lib/screens/wizards/storage_media_import_wizard.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/models/storage_media.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/import_api.dart';

// --- WIZARD CONTAINER (NO CHANGES) ---
class StorageMediaImportWizard extends ConsumerStatefulWidget {
  const StorageMediaImportWizard({super.key});

  @override
  ConsumerState<StorageMediaImportWizard> createState() =>
      _StorageMediaImportWizardState();
}

class _StorageMediaImportWizardState
    extends ConsumerState<StorageMediaImportWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  final Map<String, dynamic> _importHeaderData = {};
  final List<Map<String, dynamic>> _importItems = [];

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  Future<void> _submitData() async {
    setState(() => _isSubmitting = true);

    final success = await ImportApi.createPendingImportOperation(
      supplier: _importHeaderData['supplier'] as Supplier,
      warehouse: _importHeaderData['warehouse'] as Warehouse,
      storageMedia: _importHeaderData['storage_media'] as StorageMedia,
      items: _importItems,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Operation submitted successfully!"
              : ImportApi.lastErrorMessage ?? "An error occurred."),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        ref.refresh(pendingImportsProvider);
        Navigator.of(context).pop();
      }
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Step1SelectMedia(
        onSelected: (media) {
          setState(() => _importHeaderData['storage_media'] = media);
          _nextPage();
        },
      ),
      Step2SelectSupplier(
        storageMediaId:
            (_importHeaderData['storage_media'] as StorageMedia?)?.id,
        onSelected: (supplier) {
          setState(() => _importHeaderData['supplier'] = supplier);
          _nextPage();
        },
      ),
      Step3SelectWarehouse(
        storageMediaId:
            (_importHeaderData['storage_media'] as StorageMedia?)?.id,
        onSelected: (warehouse) {
          setState(() => _importHeaderData['warehouse'] = warehouse);
          _nextPage();
        },
      ),
      Step4AddItems(
        // <-- The corrected Step 4 is used here
        storageMediaId:
            (_importHeaderData['storage_media'] as StorageMedia?)?.id,
        warehouse: _importHeaderData['warehouse'] as Warehouse?,
        onComplete: (items) {
          setState(() {
            _importItems.clear();
            _importItems.addAll(items);
          });
          _submitData();
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Import Storage Media (Step ${_currentPage + 1})'),
        leading: _currentPage > 0 && !_isSubmitting
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Submitting Operation..."),
                ],
              ),
            )
          : PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: pages,
            ),
    );
  }
}

// --- STEPS 1, 2, 3 (NO CHANGES) ---
class Step1SelectMedia extends ConsumerWidget {
  final Function(StorageMedia) onSelected;
  const Step1SelectMedia({required this.onSelected, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(storageMediaListProvider);
    return mediaAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (mediaList) {
        if (mediaList.isEmpty) {
          return const Center(child: Text('No storage media found.'));
        }
        return ListView.builder(
          itemCount: mediaList.length,
          itemBuilder: (context, index) {
            final media = mediaList[index];
            return ListTile(
              title: Text(media.name),
              leading: const Icon(Icons.widgets_outlined),
              onTap: () => onSelected(media),
            );
          },
        );
      },
    );
  }
}

class Step2SelectSupplier extends ConsumerWidget {
  final int? storageMediaId;
  final Function(Supplier) onSelected;
  const Step2SelectSupplier(
      {required this.storageMediaId, required this.onSelected, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storageMediaId == null) {
      return const Center(
          child: Text("Please go back and select a storage media first."));
    }
    final suppliersAsync =
        ref.watch(suppliersForMediaProvider(storageMediaId!));
    return suppliersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (suppliers) {
        if (suppliers.isEmpty) {
          return const Center(child: Text('No suppliers found for this item.'));
        }
        return ListView.builder(
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return ListTile(
              title: Text(supplier.name),
              subtitle: Text(supplier.country),
              leading: const Icon(Icons.person_outline),
              onTap: () => onSelected(supplier),
            );
          },
        );
      },
    );
  }
}

class Step3SelectWarehouse extends ConsumerWidget {
  final int? storageMediaId;
  final Function(Warehouse) onSelected;
  const Step3SelectWarehouse(
      {required this.storageMediaId, required this.onSelected, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storageMediaId == null) {
      return const Center(
          child: Text("Please go back and select a storage media first."));
    }
    final warehousesAsync =
        ref.watch(warehousesForMediaProvider(storageMediaId!));
    return warehousesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (warehouses) {
        if (warehouses.isEmpty) {
          return const Center(
              child: Text('No compatible warehouses found for this item.'));
        }
        return ListView.builder(
          itemCount: warehouses.length,
          itemBuilder: (context, index) {
            final warehouse = warehouses[index];
            return ListTile(
              title: Text(warehouse.name),
              subtitle: Text(warehouse.location ?? 'No location specified'),
              leading: const Icon(Icons.warehouse_outlined),
              onTap: () => onSelected(warehouse),
            );
          },
        );
      },
    );
  }
}

// --- ✅ STEP 4: REWRITTEN AND CORRECTED ---
class Step4AddItems extends ConsumerStatefulWidget {
  final int? storageMediaId;
  final Warehouse? warehouse;
  final Function(List<Map<String, dynamic>>) onComplete;

  const Step4AddItems({
    required this.storageMediaId,
    required this.warehouse,
    required this.onComplete,
    super.key,
  });

  @override
  ConsumerState<Step4AddItems> createState() => _Step4AddItemsState();
}

class _Step4AddItemsState extends ConsumerState<Step4AddItems> {
  final List<Map<String, dynamic>> _addedItems = [];

  void _showQuantityDialog(WarehouseSection section, {String? parentName}) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to ${parentName ?? ""}${section.name}'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Quantity', hintText: 'Enter quantity'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                setState(() {
                  _addedItems
                      .removeWhere((item) => item['section_id'] == section.id);
                  _addedItems.add({
                    'section_id': section.id,
                    'section_name': section.name,
                    'quantity': quantity,
                  });
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.storageMediaId == null || widget.warehouse == null) {
      return const Center(
          child: Text("Please select media and warehouse first."));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const _ListHeader(title: "Direct Warehouse Sections"),
                _WarehouseSectionsView(
                  storageMediaId: widget.storageMediaId!,
                  warehouse: widget.warehouse!,
                  addedItems: _addedItems,
                  onSectionTap: (section) => _showQuantityDialog(section,
                      parentName: "${widget.warehouse!.name} / "),
                ),
                const Divider(height: 24),
                const _ListHeader(title: "Distribution Centers"),
                _DistributionCentersView(
                  storageMediaId: widget.storageMediaId!,
                  warehouse: widget.warehouse!,
                  addedItems: _addedItems,
                  onSectionTap: _showQuantityDialog,
                ),
              ],
            ),
          ),
          if (_addedItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: Text('Confirm and Finish (${_addedItems.length} items)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () => widget.onComplete(_addedItems),
              ),
            )
        ],
      ),
    );
  }
}

// --- ✅ HELPER WIDGETS TO FIX REBUILD LOOPS ---

class _ListHeader extends StatelessWidget {
  final String title;
  const _ListHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _WarehouseSectionsView extends ConsumerWidget {
  final int storageMediaId;
  final Warehouse warehouse;
  final List<Map<String, dynamic>> addedItems;
  final Function(WarehouseSection) onSectionTap;

  const _WarehouseSectionsView({
    required this.storageMediaId,
    required this.warehouse,
    required this.addedItems,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(
        sectionsForPlaceProvider((storageMediaId, 'Warehouse', warehouse.id)));

    return sectionsAsync.when(
      loading: () =>
          const ListTile(title: Text("...Loading Warehouse Sections")),
      error: (err, stack) => ListTile(title: Text('Error: $err')),
      data: (sections) {
        if (sections.isEmpty) {
          return const ListTile(title: Text("No direct sections found."));
        }
        return Column(
          children: sections
              .map((s) => _SectionTile(
                    section: s,
                    addedItems: addedItems,
                    onTap: () => onSectionTap(s),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _DistributionCentersView extends ConsumerWidget {
  final int storageMediaId;
  final Warehouse warehouse;
  final List<Map<String, dynamic>> addedItems;
  final Function(WarehouseSection, {String? parentName}) onSectionTap;

  const _DistributionCentersView({
    required this.storageMediaId,
    required this.warehouse,
    required this.addedItems,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(distributionCentersForWarehouseProvider(
        (warehouse.id, storageMediaId)));

    return centersAsync.when(
      loading: () => const ListTile(title: Text("...Loading Centers")),
      error: (err, stack) => ListTile(title: Text('Error: $err')),
      data: (centers) {
        if (centers.isEmpty) {
          return const ListTile(title: Text("No distribution centers found."));
        }
        return Column(
          children: centers.map((center) {
            return ExpansionTile(
              leading: const Icon(Icons.business),
              title: Text(center.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              children: [
                _DistributionCenterSectionsView(
                  storageMediaId: storageMediaId,
                  center: center,
                  addedItems: addedItems,
                  onSectionTap: (section) =>
                      onSectionTap(section, parentName: "${center.name} / "),
                )
              ],
            );
          }).toList(),
        );
      },
    );
  }
}

class _DistributionCenterSectionsView extends ConsumerWidget {
  final int storageMediaId;
  final DistributionCenter center;
  final List<Map<String, dynamic>> addedItems;
  final Function(WarehouseSection) onSectionTap;

  const _DistributionCenterSectionsView({
    required this.storageMediaId,
    required this.center,
    required this.addedItems,
    required this.onSectionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(sectionsForPlaceProvider(
        (storageMediaId, 'DistributionCenter', center.id)));
    return sectionsAsync.when(
      loading: () => const ListTile(title: Text("...Loading sections")),
      error: (err, stack) => ListTile(title: Text('Error: $err')),
      data: (sections) {
        if (sections.isEmpty) {
          return const ListTile(title: Text("No sections in this center."));
        }
        return Column(
          children: sections
              .map((s) => _SectionTile(
                    section: s,
                    addedItems: addedItems,
                    onTap: () => onSectionTap(s),
                    isSubItem: true,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SectionTile extends StatelessWidget {
  final WarehouseSection section;
  final List<Map<String, dynamic>> addedItems;
  final VoidCallback onTap;
  final bool isSubItem;

  const _SectionTile({
    required this.section,
    required this.addedItems,
    required this.onTap,
    this.isSubItem = false,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyAddedItem = addedItems.firstWhere(
      (item) => item['section_id'] == section.id,
      orElse: () => {},
    );
    final bool isAdded = alreadyAddedItem.isNotEmpty;

    return ListTile(
      contentPadding:
          isSubItem ? const EdgeInsets.only(left: 40.0, right: 16.0) : null,
      title: Text(section.name),
      subtitle:
          Text('Available Area: ${section.storageMediaAvailableArea ?? 'N/A'}'),
      leading: Icon(
        isAdded ? Icons.check_circle : Icons.add_circle_outline,
        color: isAdded ? Colors.green : null,
      ),
      trailing: isAdded ? Text('Qty: ${alreadyAddedItem['quantity']}') : null,
      onTap: onTap,
    );
  }
}
