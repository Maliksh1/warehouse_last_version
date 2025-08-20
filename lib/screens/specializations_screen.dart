import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/providers/api_service_provider.dart';
import 'package:warehouse/providers/product_types_provider.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart'; // لإعادة استعمال مزامنة/refresh نمط FutureProvider
// إذا عندك specializationsProvider مستقل، استبدله هنا واستعمله بدلاً من productTypesProvider.

class SpecializationsScreen extends ConsumerStatefulWidget {
  const SpecializationsScreen({super.key});

  @override
  ConsumerState<SpecializationsScreen> createState() =>
      _SpecializationsScreenState();
}

class _SpecializationsScreenState extends ConsumerState<SpecializationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تحميل عند الدخول
    Future.microtask(() {
      // إن كان لديك specializationsProvider خاص:
      // ref.refresh(specializationsProvider);
      // وإلا مؤقتًا نعيد تحميل أنواع المنتجات كمثال هيكلي — استبدلها بمزوّد الاختصاصات لديك
      ref.refresh(productTypesProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.read(apiServiceProvider);

    // إن كان لديك specializationsProvider:
    // final specsAsync = ref.watch(specializationsProvider);

    // وإلا (للتوافق الآن) سنجلب مباشرة من الـ API داخل FutureBuilder:
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاختصاصات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'إضافة اختصاص',
            onPressed: () => _showAddDialog(context, api),
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: api.getSpecializations(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('خطأ: ${snap.error}'));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('لا توجد اختصاصات حالياً'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = (list[i] as Map);
              final int id = (item['id'] as num).toInt();
              final String name = (item['name'] ?? '').toString();
              return ListTile(
                leading: const Icon(Icons.star),
                title: Text(name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, api, id, name),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteSpec(context, api, id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, ApiService api) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة اختصاص'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'اسم الاختصاص'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            child: const Text('إضافة'),
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              try {
                final ok = await api.addSpecialization(name);
                if (ok) {
                  setState(() {}); // أعد التحميل
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تمت الإضافة بنجاح'),
                        backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('لم يتم الإضافة'),
                        backgroundColor: Colors.orange),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('خطأ: $e'), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, ApiService api, int id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعديل الاختصاص'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'الاسم الجديد'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            child: const Text('حفظ'),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(context);
              try {
                final ok = await api.editSpecialization(id, newName);
                // 201: تم التعديل — 403: بعد 30 دقيقة لا يسمح
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'تم التعديل بنجاح'
                      : 'لا يمكن التعديل بعد مرور 30 دقيقة'),
                  backgroundColor: ok ? Colors.green : Colors.orange,
                ));
                if (ok) setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('خطأ: $e'), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSpec(BuildContext context, ApiService api, int id) async {
    try {
      final ok = await api.deleteSpecialization(id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'تم حذف الاختصاص' : 'لم يتم الحذف'),
        backgroundColor: ok ? Colors.green : Colors.orange,
      ));
      if (ok) setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
