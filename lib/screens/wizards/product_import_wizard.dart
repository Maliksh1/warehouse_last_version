import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/models/pending_product_import.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/supplier.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/providers/data_providers.dart';
import 'package:warehouse/services/import_api.dart';

// --- WIZARD CONTAINER ---
class ProductImportWizard extends ConsumerStatefulWidget {
  final int? preselectedWarehouseId;
  const ProductImportWizard({super.key, this.preselectedWarehouseId});

  @override
  ConsumerState<ProductImportWizard> createState() =>
      _ProductImportWizardState();
}

class _ProductImportWizardState extends ConsumerState<ProductImportWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Supplier? _selectedSupplier;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // ✅ تنظيف الحالة عند بدء المعالج لضمان عدم وجود بيانات قديمة
    Future.microtask(
        () => ref.read(productImportWizardProvider.notifier).clearProducts());
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  void _previousPage() {
    _pageController.previousPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final selectedProducts = ref.read(productImportWizardProvider);

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one product.'),
        backgroundColor: Colors.orange,
      ));
      setState(() => _isSubmitting = false);
      return;
    }

    // ✅ التحقق من أن جميع المنتجات لديها كميات توزيع
    for (var product in selectedProducts) {
      final totalDistributed =
          product.distribution.fold<double>(0, (sum, dist) => sum + dist.load);
      if (totalDistributed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Please specify a distribution quantity for "${product.product.name}".'),
          backgroundColor: Colors.orange,
        ));
        setState(() => _isSubmitting = false);
        return;
      }
    }

    final success = await ImportApi.createPendingProductImport(
        supplier: _selectedSupplier!, products: selectedProducts);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success
            ? 'Operation Submitted Successfully!'
            : ImportApi.lastErrorMessage ?? 'Failed to submit operation!'),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
      if (success) {
        // تحديث قائمة العمليات المعلقة بعد الإرسال الناجح
        ref.invalidate(allPendingOperationsProvider);
        Navigator.of(context).pop();
      } else {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _Step1SelectSupplier(onSelected: (supplier) {
        setState(() => _selectedSupplier = supplier);
        _nextPage();
      }),
      _Step2ManageProducts(
        supplier: _selectedSupplier,
        onSubmit: _submit,
        isSubmitting: _isSubmitting,
        // ✅ تمرير معرّف المستودع إلى الخطوة الثانية
        preselectedWarehouseId: widget.preselectedWarehouseId,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Import Products (Step ${_currentPage + 1})'),
        leading: _currentPage > 0 && !_isSubmitting
            ? IconButton(
                icon: const Icon(Icons.arrow_back), onPressed: _previousPage)
            : null,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: pages,
      ),
    );
  }
}

// --- STEP 1: SELECT SUPPLIER ---
class _Step1SelectSupplier extends ConsumerWidget {
  final Function(Supplier) onSelected;
  const _Step1SelectSupplier({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    return suppliersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (suppliers) => ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(supplier.name),
            subtitle: Text(supplier.country),
            onTap: () => onSelected(supplier),
          );
        },
      ),
    );
  }
}

// --- STEP 2: MANAGE PRODUCTS & DISTRIBUTION ---
class _Step2ManageProducts extends ConsumerWidget {
  final Supplier? supplier;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;
  final int? preselectedWarehouseId; // ✅ استقبال معرّف المستودع

  const _Step2ManageProducts(
      {required this.supplier,
      required this.onSubmit,
      required this.isSubmitting,
      required this.preselectedWarehouseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (supplier == null) {
      return const Center(child: Text('Please select a supplier first.'));
    }

    final selectedProducts = ref.watch(productImportWizardProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Add Product'),
        onPressed: () => _showAddProductDialog(context, ref, supplier!),
      ),
      body: Column(
        children: [
          Expanded(
            child: selectedProducts.isEmpty
                ? const Center(child: Text('No products added yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: selectedProducts.length,
                    itemBuilder: (context, index) {
                      return _ImportedProductCard(
                        productInfo: selectedProducts[index],
                        // ✅ تمرير المعرّف للكارد
                        preselectedWarehouseId: preselectedWarehouseId,
                      );
                    },
                  ),
          ),
          if (selectedProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ))
                    : const Icon(Icons.send),
                label: Text(
                    isSubmitting ? 'Submitting...' : 'Submit Import Operation'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: isSubmitting ? null : onSubmit,
              ),
            )
        ],
      ),
    );
  }

  void _showAddProductDialog(
      BuildContext context, WidgetRef ref, Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final productsAsync =
              ref.watch(productsForSupplierProvider(supplier.id));
          final alreadyAddedIds = ref
              .watch(productImportWizardProvider)
              .map((p) => p.product.id)
              .toSet();

          return AlertDialog(
            title: const Text('Select a Product'),
            content: SizedBox(
              width: double.maxFinite,
              child: productsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (products) {
                  final availableProducts = products
                      .where((p) => !alreadyAddedIds.contains(p.id))
                      .toList();
                  if (availableProducts.isEmpty) {
                    return const Center(
                        child: Text(
                            'All available products from this supplier have been added.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableProducts.length,
                    itemBuilder: (context, index) {
                      final product = availableProducts[index];
                      return ListTile(
                        title: Text(product.name),
                        onTap: () async {
                          // ✅ --- المنطق الجديد والمحسن ---
                          final productId = int.tryParse(product.id);
                          if (productId == null) return; // حماية

                          final allWarehouses = await ref.read(
                              warehousesForProductProvider(productId).future);

                          List<Warehouse> warehousesForDistribution;

                          if (preselectedWarehouseId != null) {
                            // إذا كان هناك مستودع محدد، قم بتصفيته
                            warehousesForDistribution = allWarehouses
                                .where((w) => w.id == preselectedWarehouseId)
                                .toList();

                            // تحقق إذا كان المستودع المحدد متوافقًا
                            if (warehousesForDistribution.isEmpty &&
                                context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    '"${product.name}" is not compatible with the selected warehouse.'),
                                backgroundColor: Colors.orange,
                              ));
                              Navigator.of(context).pop();
                              return; // لا تقم بإضافة المنتج
                            }
                          } else {
                            // إذا لم يكن هناك تحديد مسبق، استخدم كل المستودعات المتوافقة
                            warehousesForDistribution = allWarehouses;
                          }

                          ref
                              .read(productImportWizardProvider.notifier)
                              .addProduct(product, warehousesForDistribution);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'))
            ],
          );
        },
      ),
    );
  }
}

// --- CARD FOR EACH IMPORTED PRODUCT ---
class _ImportedProductCard extends ConsumerWidget {
  final ImportedProductInfo productInfo;
  final int? preselectedWarehouseId; // ✅ استقبال معرّف المستودع

  const _ImportedProductCard(
      {required this.productInfo, this.preselectedWarehouseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productImportWizardProvider.notifier);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(child: Text(productInfo.product.id.toString())),
        title: Text(productInfo.product.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () {
              final productId = int.tryParse(productInfo.product.id);
              if (productId != null) {
                notifier.removeProduct(productId);
              }
            }),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: 'Total Imported Quantity',
                  initialValue: productInfo.importedLoad.toString(),
                  onChanged: (val) =>
                      productInfo.importedLoad = double.tryParse(val) ?? 0,
                ),
                _buildTextField(
                  label: 'Price per Unit',
                  initialValue: productInfo.pricePerUnit.toString(),
                  onChanged: (val) =>
                      productInfo.pricePerUnit = double.tryParse(val) ?? 0,
                ),
                _buildDateField(
                  context: context,
                  label: 'Production Date',
                  currentValue: productInfo.productionDate,
                  onChanged: (val) => productInfo.productionDate = val,
                ),
                _buildDateField(
                  context: context,
                  label: 'Expiration Date',
                  currentValue: productInfo.expirationDate,
                  onChanged: (val) => productInfo.expirationDate = val,
                ),
                // ✅ ---  هنا الإضافة المطلوبة ---
                _buildTextField(
                    label: 'Special Description',
                    initialValue: productInfo.specialDescription,
                    onChanged: (val) => productInfo.specialDescription = val,
                    isNumeric: false),
                const SizedBox(height: 16),
                const Text('Distribution Plan',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (productInfo.distribution.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      preselectedWarehouseId != null
                          ? 'This product is not compatible with the selected warehouse.'
                          : 'No compatible warehouses found for this product.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ...productInfo.distribution.map((dist) {
                    return _DistributionRow(
                      distributionInfo: dist,
                      // ✅ اجعل الصف للقراءة فقط إذا كان المستودع محددًا مسبقًا
                      isReadOnly: preselectedWarehouseId != null,
                    );
                  }).toList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ... (دوال بناء الحقول تبقى كما هي)
  Widget _buildTextField(
      {required String label,
      required String initialValue,
      required Function(String) onChanged,
      bool isNumeric = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateField(
      {required BuildContext context,
      required String label,
      required String currentValue,
      required Function(String) onChanged}) {
    final controller = TextEditingController(text: currentValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: const Icon(Icons.calendar_today)),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
          );
          if (date != null) {
            final formattedDate = DateFormat('yyyy-MM-dd').format(date);
            onChanged(formattedDate);
            controller.text = formattedDate;
          }
        },
      ),
    );
  }
}

class _DistributionRow extends StatefulWidget {
  final ProductDistributionInfo distributionInfo;
  final bool isReadOnly; // ✅ متغير جديد للتحكم
  const _DistributionRow(
      {required this.distributionInfo, this.isReadOnly = false});

  @override
  State<_DistributionRow> createState() => _DistributionRowState();
}

class _DistributionRowState extends State<_DistributionRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: widget.distributionInfo.load.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              flex: 3,
              child: Text(
                widget.distributionInfo.warehouse.name,
                overflow: TextOverflow.ellipsis,
                // ✅ تمييز بصري إذا كان للقراءة فقط
                style: TextStyle(
                  color: widget.isReadOnly ? Colors.grey.shade700 : null,
                  fontStyle: widget.isReadOnly ? FontStyle.italic : null,
                ),
              )),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'Load', border: UnderlineInputBorder()),
              onChanged: (val) =>
                  widget.distributionInfo.load = double.tryParse(val) ?? 0,
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: widget.distributionInfo.sendVehicles,
            onChanged: (val) {
              setState(() {
                widget.distributionInfo.sendVehicles = val ?? false;
              });
            },
          ),
          const Text('Vehicles?', style: TextStyle(fontSize: 12))
        ],
      ),
    );
  }
}
