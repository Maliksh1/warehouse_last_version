import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/providers/navigation_provider.dart';
import 'package:warehouse/providers/product_types_provider.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';
import 'package:warehouse/widgets/sidebar_menu.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ProductTypesScreen extends ConsumerStatefulWidget {
  const ProductTypesScreen({super.key});

  @override
  ConsumerState<ProductTypesScreen> createState() => _ProductTypesScreenState();
}

class _ProductTypesScreenState extends ConsumerState<ProductTypesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // تحديث البيانات تلقائيًا عند كل دخول للشاشة
    Future.microtask(() {
      ref.refresh(
          productTypesProvider); // يعيد تحميل البيانات ولا حاجة لاستخدام القيمة
    });
  }

  @override
  Widget build(BuildContext context) {
    final productTypesAsync = ref.watch(productTypesProvider);
    final apiService = ref.read(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('أنواع المنتجات'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(navigationProvider.notifier).state =
                MainSectionNavigationState(0);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة نوع جديد',
            onPressed: () => _showAddTypeDialog(context, ref, apiService),
          ),
        ],
      ),
      body: productTypesAsync.when(
        data: (types) => ListView.builder(
          itemCount: types.length,
          itemBuilder: (_, index) {
            final type = types[index];
            return ListTile(
              title: Text(type['name']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditDialog(
                        context, type['id'], type['name'], ref, apiService),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _deleteType(context, type['id'], ref, apiService),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('خطأ: $err')),
      ),
    );
  }

  void _showAddTypeDialog(
      BuildContext context, WidgetRef ref, ApiService apiService) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة نوع جديد'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم النوع'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              try {
                final response = await apiService.addProductType(name);
                Navigator.pop(context);
                ref.refresh(productTypesProvider);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(response['msg'] ?? 'تمت الإضافة بنجاح'),
                  backgroundColor: Colors.green,
                ));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('فشل الإضافة: $e'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, int typeId, String currentName,
      WidgetRef ref, ApiService apiService) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل النوع'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم النوع الجديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;

              try {
                final success =
                    await apiService.editProductType(typeId, newName);
                Navigator.pop(context);
                ref.refresh(productTypesProvider);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'تم تعديل النوع بنجاح'
                      : 'لا يمكن التعديل بعد مرور 30 دقيقة'),
                  backgroundColor: success ? Colors.green : Colors.orange,
                ));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('حدث خطأ أثناء التعديل: $e'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteType(BuildContext context, int typeId, WidgetRef ref,
      ApiService apiService) async {
    try {
      final success = await apiService.deleteProductType(typeId);
      ref.refresh(productTypesProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'تم حذف النوع بنجاح' : 'لم يتم الحذف'),
        backgroundColor: success ? Colors.green : Colors.orange,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('فشل الحذف: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
}
