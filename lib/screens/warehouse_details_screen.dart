import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/imported_product.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/models/product_distribution.dart';
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/warehouse_section.dart';
import 'package:warehouse/providers/product_provider.dart';
// import 'package:warehouse/providers/warehouse_section.dart';

import 'package:uuid/uuid.dart';
import 'package:warehouse/providers/warehouse_section_provider.dart';

class WarehouseDetailScreen extends ConsumerStatefulWidget {
  final Warehouse warehouse;

  const WarehouseDetailScreen({
    Key? key,
    required this.warehouse,
    required String warehouseId,
  }) : super(key: key);

  @override
  _WarehouseDetailScreenState createState() => _WarehouseDetailScreenState();
}

class _WarehouseDetailScreenState extends ConsumerState<WarehouseDetailScreen> {
  // بيانات مؤقتة للأقسام - سيتم استبدالها بخدمة البيانات الفعلية
  List<WarehouseSection> sections = [];
  List<String> availableCategories = [
    'أجهزة',
    'ملحقات',
    'قطع غيار',
    'مواد غذائية',
    'أدوات'
  ];
  List<Product> allProducts = [];

  @override
  void initState() {
    super.initState();
    // تحميل بيانات الأقسام والمنتجات - سيتم استبدالها بالتحميل الفعلي من قاعدة البيانات
    _loadSampleData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث قائمة المنتجات في كل مرة يتم فيها إعادة بناء الشاشة
    _refreshProductsList();
  }

  void _loadSampleData() {
    // بيانات تجريبية للأقسام
    sections = [
      WarehouseSection(
        id: '1',
        warehouseId: widget.warehouse.id,
        name: 'قسم الأجهزة الإلكترونية',
        supportedTypeId: 'أجهزة',
        capacity: 100,
        capacityUnit: 'وحدة',
        occupied: 30,
        products: [],
      ),
      WarehouseSection(
        id: '2',
        warehouseId: widget.warehouse.id,
        name: 'قسم قطع الغيار',
        supportedTypeId: 'قطع غيار',
        capacity: 200,
        capacityUnit: 'وحدة',
        occupied: 50,
        products: [],
      ),
    ];

    // تحميل قائمة المنتجات
    _refreshProductsList();
  }

  // دالة لتحديث قائمة المنتجات من مصدر البيانات
  void _refreshProductsList() {
    // في التطبيق الحقيقي، هذه الدالة ستقوم بجلب البيانات من قاعدة البيانات أو API
    // هنا نستخدم بيانات تجريبية للتوضيح

    // يمكن استخدام خدمة مشتركة أو مزود حالة (Provider/Bloc) للوصول إلى قائمة المنتجات المحدثة
    // ProductService.getAllProducts() أو ProductsProvider.of(context).products

    // بيانات تجريبية للمنتجات
    setState(() {
      allProducts = [
        Product(
          id: '1',
          name: 'لابتوب HP',
          supplierId: 'S001',
          importCycle: '',
          quantity: 40,
          typeId: '',
          unit: '',
          actualPiecePrice: 12,
        ),

        // إضافة المنتجات الجديدة هنا
        // في التطبيق الحقيقي، ستأتي هذه البيانات من قاعدة البيانات
      ];
      setState(() {
        allProducts = ref.read(productProvider);
        // هذا يجب أن يعكس المنتجات التي تم إضافتها فعلياً
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouse.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث قائمة المنتجات',
            onPressed: _refreshProductsList,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // تنفيذ منطق تعديل المستودع
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المستودع
            _buildWarehouseInfoCard(),
            const SizedBox(height: 24),

            // عنوان الأقسام مع زر إضافة قسم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الأقسام',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة قسم'),
                  onPressed: _showAddSectionDialog,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // قائمة الأقسام
            _buildSectionsList(),
            const SizedBox(height: 24),

            // زر استيراد المنتجات
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('استيراد منتجات'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // تحديث قائمة المنتجات قبل فتح مربع حوار الاستيراد
                  _refreshProductsList();
                  showImportProductDialog(context, ref, widget.warehouse.id);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarehouseInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.warehouse.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Chip(
                  label: Text(
                    '${(widget.warehouse.usageRate * 100).toStringAsFixed(1)}% مستخدم',
                  ),
                  backgroundColor: _getUsageColor(widget.warehouse.usageRate),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('العنوان: ${widget.warehouse.address}'),
            const SizedBox(height: 4),
            Text(
              'السعة: ${widget.warehouse.occupied}/${widget.warehouse.capacity} ${widget.warehouse.capacityUnit}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: widget.warehouse.usageRate,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getUsageColor(widget.warehouse.usageRate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsList() {
    if (sections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(Icons.category_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'لا توجد أقسام بعد',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'أضف قسماً جديداً لتخزين المنتجات',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ExpansionTile(
            title: Text(section.name),
            subtitle: Text(
              'النوع: ${section.supportedTypeId} - الإشغال: ${section.occupied}/${section.capacity} ${section.capacityUnit}',
            ),
            leading: const Icon(Icons.category),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر تعديل القسم
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'تعديل القسم',
                  onPressed: () => _showEditSectionDialog(section),
                ),
                // زر حذف القسم
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف القسم',
                  onPressed: () => _showDeleteSectionConfirmation(section),
                ),
                const Icon(Icons.expand_more),
              ],
            ),
            children: [
              if (section.products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'لا توجد منتجات في هذا القسم',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: section.products.length,
                  itemBuilder: (context, productIndex) {
                    final importedProduct = section.products[productIndex];
                    // البحث عن معلومات المنتج الأساسية
                    final baseProduct = allProducts.firstWhere(
                      (p) => p.id == importedProduct.productId,
                      orElse: () => Product(
                        id: 'unknown',
                        name: 'منتج غير معروف',
                        supplierId: 'unknown',
                        importCycle: '',
                        quantity: 40,
                        typeId: '',
                        unit: '',
                        actualPiecePrice: 10,
                      ),
                    );

                    return ListTile(
                      title: Text(baseProduct.name),
                      subtitle: Text(
                        'الكمية: ${importedProduct.quantity} - تاريخ الانتهاء: ${_formatDate(importedProduct.expirationDate)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // زر تعديل المنتج المستورد
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'تعديل المنتج',
                            onPressed: () => _showEditImportedProductDialog(
                                importedProduct, baseProduct, section),
                          ),
                          // زر حذف المنتج المستورد
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'حذف المنتج',
                            onPressed: () =>
                                _showDeleteImportedProductConfirmation(
                                    importedProduct, baseProduct, section),
                          ),
                          // زر عرض تفاصيل المنتج
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            tooltip: 'عرض التفاصيل',
                            onPressed: () => _showProductDetails(
                                importedProduct, baseProduct),
                          ),
                        ],
                      ),
                      onTap: () =>
                          _showProductDetails(importedProduct, baseProduct),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddSectionDialog() {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    String selectedCategory = availableCategories.first;
    String capacityUnit = 'وحدة';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'أدخل اسم القسم',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'نوع المنتجات المدعومة',
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(
                        labelText: 'السعة',
                        hintText: 'أدخل سعة القسم',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: capacityUnit,
                      decoration: const InputDecoration(
                        labelText: 'الوحدة',
                      ),
                      items: ['وحدة', 'كغ', 'لتر', 'متر مكعب'].map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        capacityUnit = value!;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // التحقق من صحة البيانات
              if (nameController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('يرجى ملء جميع الحقول المطلوبة')),
                );
                return;
              }

              // إنشاء قسم جديد
              final newSection = WarehouseSection(
                id: const Uuid().v4(), // توليد معرف فريد
                warehouseId: widget.warehouse.id,
                name: nameController.text,
                supportedTypeId: selectedCategory,
                capacity: double.parse(capacityController.text),
                capacityUnit: capacityUnit,
                occupied: 0, // القسم الجديد فارغ
              );

              // إضافة القسم إلى القائمة وتحديث الواجهة
              setState(() {
                sections.add(newSection);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تم إضافة قسم ${nameController.text} بنجاح')),
              );
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // دالة لعرض مربع حوار تعديل القسم
  void _showEditSectionDialog(WarehouseSection section) {
    final nameController = TextEditingController(text: section.name);
    final capacityController =
        TextEditingController(text: section.capacity.toString());
    String selectedCategory = section.supportedTypeId;
    String capacityUnit = section.capacityUnit;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل القسم'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'أدخل اسم القسم',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'نوع المنتجات المدعومة',
                ),
                items: availableCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: capacityController,
                      decoration: const InputDecoration(
                        labelText: 'السعة',
                        hintText: 'أدخل سعة القسم',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: capacityUnit,
                      decoration: const InputDecoration(
                        labelText: 'الوحدة',
                      ),
                      items: ['وحدة', 'كغ', 'لتر', 'متر مكعب'].map((unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        capacityUnit = value!;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              // التحقق من صحة البيانات
              if (nameController.text.isEmpty ||
                  capacityController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('يرجى ملء جميع الحقول المطلوبة')),
                );
                return;
              }

              // التحقق من أن السعة الجديدة لا تقل عن المساحة المستخدمة حالياً
              final newCapacity = double.parse(capacityController.text);
              if (newCapacity < section.occupied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'لا يمكن تقليل السعة إلى أقل من المساحة المستخدمة حالياً')),
                );
                return;
              }

              // تحديث القسم
              final updatedSection = section.copyWith(
                name: nameController.text,
                supportedTypeId: selectedCategory,
                capacity: newCapacity,
                capacityUnit: capacityUnit,
              );

              // تحديث القائمة وتحديث الواجهة
              setState(() {
                final index = sections.indexWhere((s) => s.id == section.id);
                if (index != -1) {
                  sections[index] = updatedSection;
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تم تعديل قسم ${nameController.text} بنجاح')),
              );
            },
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  // دالة لعرض تأكيد حذف القسم
  void _showDeleteSectionConfirmation(WarehouseSection section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من رغبتك في حذف قسم "${section.name}"؟\n\nسيتم حذف جميع المنتجات الموجودة في هذا القسم.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // حذف القسم
              setState(() {
                sections.removeWhere((s) => s.id == section.id);
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف قسم "${section.name}" بنجاح')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // دالة لعرض مربع حوار تعديل المنتج المستورد
  void _showEditImportedProductDialog(ImportedProduct importedProduct,
      Product baseProduct, WarehouseSection section) {
    final quantityController =
        TextEditingController(text: importedProduct.quantity.toString());
    final priceController =
        TextEditingController(text: importedProduct.pricePerUnit.toString());
    DateTime productionDate = importedProduct.productionDate;
    DateTime expirationDate = importedProduct.expirationDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('تعديل منتج: ${baseProduct.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات المنتج الأساسية (غير قابلة للتعديل)

                  Text('المورد: ${baseProduct.supplierId}'),
                  const Divider(),

                  // تاريخ الإنتاج
                  Row(
                    children: [
                      const Text('تاريخ الإنتاج:'),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: productionDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              productionDate = date;
                            });
                          }
                        },
                        child: Text(_formatDate(productionDate)),
                      ),
                    ],
                  )
                  // تاريخ انتهاء الصلاحية
                  ,
                  Row(
                    children: [
                      const Text('تاريخ انتهاء الصلاحية:'),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: expirationDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              expirationDate = date;
                            });
                          }
                        },
                        child: Text(_formatDate(expirationDate)),
                      ),
                    ],
                  ),

                  // سعر الوحدة
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'سعر الوحدة',
                      hintText: 'أدخل سعر الوحدة',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // الكمية
                  TextField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'الكمية',
                      hintText: 'أدخل الكمية',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  // التحقق من صحة البيانات
                  if (priceController.text.isEmpty ||
                      quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('يرجى ملء جميع الحقول المطلوبة')),
                    );
                    return;
                  }

                  final newQuantity = double.parse(quantityController.text);
                  final oldQuantity = importedProduct.quantity;
                  final quantityDifference = newQuantity - oldQuantity;

                  // تحديث المنتج المستورد
                  final updatedProduct = importedProduct.copyWith(
                    productionDate: productionDate,
                    expirationDate: expirationDate,
                    pricePerUnit: double.parse(priceController.text),
                    quantity: newQuantity,
                  );

                  // تحديث القسم والمنتج
                  this.setState(() {
                    final sectionIndex =
                        sections.indexWhere((s) => s.id == section.id);
                    if (sectionIndex != -1) {
                      // تحديث المنتج في القسم
                      final productIndex = sections[sectionIndex]
                          .products
                          .indexWhere((p) => p.id == importedProduct.id);
                      if (productIndex != -1) {
                        final updatedProducts = List<ImportedProduct>.from(
                            sections[sectionIndex].products);
                        updatedProducts[productIndex] = updatedProduct;

                        // تحديث المساحة المستخدمة في القسم
                        final newOccupied = sections[sectionIndex].occupied +
                            quantityDifference;

                        // تحديث القسم
                        sections[sectionIndex] =
                            sections[sectionIndex].copyWith(
                          occupied: newOccupied,
                          products: updatedProducts,
                          supportedTypeId: '',
                        );
                      }
                    }
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('تم تعديل منتج ${baseProduct.name} بنجاح')),
                  );
                },
                child: const Text('حفظ التعديلات'),
              ),
            ],
          );
        },
      ),
    );
  }

  // دالة لعرض تأكيد حذف المنتج المستورد
  void _showDeleteImportedProductConfirmation(ImportedProduct importedProduct,
      Product baseProduct, WarehouseSection section) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
            'هل أنت متأكد من رغبتك في حذف منتج "${baseProduct.name}" من هذا القسم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // حذف المنتج من القسم
              setState(() {
                final sectionIndex =
                    sections.indexWhere((s) => s.id == section.id);
                if (sectionIndex != -1) {
                  // تحديث المساحة المستخدمة في القسم
                  final newOccupied = sections[sectionIndex].occupied -
                      importedProduct.quantity;

                  // إزالة المنتج من القسم
                  final updatedProducts = List<ImportedProduct>.from(
                      sections[sectionIndex].products)
                    ..removeWhere((p) => p.id == importedProduct.id);

                  // تحديث القسم
                  sections[sectionIndex] = sections[sectionIndex].copyWith(
                    occupied: newOccupied,
                    products: updatedProducts,
                    supportedTypeId: '',
                  );
                }
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('تم حذف منتج "${baseProduct.name}" بنجاح')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void showImportProductDialog(
      BuildContext context, WidgetRef ref, String warehouseId) {
    final t = AppLocalizations.of(context)!;
    final uuid = const Uuid();

    showDialog(
      context: context,
      builder: (_) {
        String? selectedProductId;
        String? selectedSectionId;
        final quantityController = TextEditingController();

        final allProducts = ref.watch(productProvider);
        final allSections = ref
            .watch(warehouseSectionProvider)
            .where((s) => s.warehouseId == warehouseId)
            .toList();

        Product? selectedProduct;
        List<WarehouseSection> compatibleSections = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(t.get('import_product')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      items: allProducts.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedProductId = val;
                          selectedProduct = allProducts
                              .firstWhere((p) => p.id == selectedProductId);
                          compatibleSections = allSections
                              .where((s) =>
                                  s.supportedTypeId == selectedProduct!.typeId)
                              .toList();
                          selectedSectionId = null; // reset section
                        });
                      },
                      decoration:
                          InputDecoration(labelText: t.get('select_product')),
                    ),
                    const SizedBox(height: 10),
                    if (selectedProduct != null)
                      compatibleSections.isNotEmpty
                          ? DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: selectedSectionId,
                              items: compatibleSections.map((s) {
                                return DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  selectedSectionId = val;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: t.get('select_section')),
                            )
                          : Text(
                              t.get('no_compatible_sections') ??
                                  'لا توجد أقسام متوافقة مع نوع هذا المنتج',
                              style: const TextStyle(color: Colors.red),
                            ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: t.get('quantity'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.get('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedProductId != null &&
                        selectedSectionId != null &&
                        quantityController.text.isNotEmpty) {
                      final distribution = ProductDistribution(
                        warehouseId: warehouseId,
                        sectionId: selectedSectionId!,
                        quantity:
                            double.tryParse(quantityController.text) ?? 0.0,
                      );

                      // ✅ قم بحفظ أو إرسال التوزيع
                      print(
                          '✅ توزيع المنتج: $selectedProductId على القسم: $selectedSectionId بكمية ${distribution.quantity}');

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.get('product_imported_successfully')),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.get('please_fill_all_fields')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(t.get('import')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // دالة لعرض معلومات المنتج المختار
  Widget _buildSelectedProductInfo(String productId) {
    final product = allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: 'unknown',
        name: 'منتج غير معروف',
        supplierId: 'unknown',
        importCycle: '',
        quantity: 100,
        typeId: '',
        unit: '',
        actualPiecePrice: 12,
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات المنتج:',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blue[800])),
            const SizedBox(height: 8),
            Text('الاسم: ${product.name}'),
            Text('الاسم: ${product.actualPiecePrice}'),
            Text('الاسم: ${product.description}'),
            Text('الاسم: ${product.quantity}'),
            Text('المورد: ${product.supplierId}'),
          ],
        ),
      ),
    );
  }

  // هذه هي الدالة التي تم إصلاحها لمعالجة خطأ NoSuchMethodError: 'first'
  void _showAddDistributionDialog(
    BuildContext context,
    String productId,
    Function(String sectionId, double quantity) onAdd,
  ) {
    // الحصول على معلومات المنتج
    final product = allProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
        id: 'unknown',
        name: 'منتج غير معروف',
        supplierId: 'unknown',
        importCycle: '',
        quantity: 100,
        typeId: '',
        unit: '',
        actualPiecePrice: 12,
      ),
    );

    // تصفية الأقسام التي تدعم فئة المنتج
    final compatibleSections = sections
        .where((section) => section.supportedTypeId == product.name)
        .toList();

    if (compatibleSections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('لا توجد أقسام تدعم فئة المنتج "${product.name}"')),
      );
      return;
    }

    // تعيين القسم الافتراضي - مع التحقق من وجود أقسام متوافقة
    String? selectedSectionId =
        compatibleSections.isNotEmpty ? compatibleSections[0].id : null;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة توزيع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedSectionId != null)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'القسم',
                  hintText: 'اختر القسم',
                ),
                value: selectedSectionId,
                items: compatibleSections.map((section) {
                  return DropdownMenuItem<String>(
                    value: section.id,
                    child: Text('${section.name} (${section.supportedTypeId})'),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedSectionId = value;
                },
              )
            else
              const Text('لا توجد أقسام متوافقة مع فئة هذا المنتج'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'الكمية',
                hintText: 'أدخل الكمية',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: selectedSectionId == null
                ? null
                : () {
                    if (quantityController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('يرجى إدخال الكمية')),
                      );
                      return;
                    }

                    // التحقق من أن القسم لديه مساحة كافية
                    final section =
                        sections.firstWhere((s) => s.id == selectedSectionId);
                    final quantity = double.parse(quantityController.text);

                    if (section.occupied + quantity > section.capacity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'لا توجد مساحة كافية في القسم. المساحة المتاحة: ${section.capacity - section.occupied} ${section.capacityUnit}')),
                      );
                      return;
                    }

                    onAdd(selectedSectionId!, quantity);
                    Navigator.pop(context);
                  },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(
      ImportedProduct importedProduct, Product baseProduct) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(baseProduct.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الكود: ${baseProduct.actualPiecePrice}'),
            Text('الفئة: ${baseProduct.name}'),
            Text('المورد: ${baseProduct.supplierId}'),
            const Divider(),
            Text('الكمية المستوردة: ${importedProduct.quantity}'),
            Text('سعر الوحدة: ${importedProduct.pricePerUnit}'),
            Text(
                'تاريخ الإنتاج: ${_formatDate(importedProduct.productionDate)}'),
            Text(
                'تاريخ انتهاء الصلاحية: ${_formatDate(importedProduct.expirationDate)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getUsageColor(double usageRate) {
    if (usageRate < 0.7) return Colors.green;
    if (usageRate < 0.9) return Colors.orange;
    return Colors.red;
  }
}
