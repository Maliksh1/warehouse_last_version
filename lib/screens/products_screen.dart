import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/models/product.dart';
import 'package:warehouse/providers/api_service_provider.dart';
import 'package:warehouse/providers/navigation_provider.dart';
import 'package:warehouse/providers/product_provider.dart';
import 'package:warehouse/widgets/Dialogs/show_add_general_product_dialog.dart';
import '../widgets/Dialogs/show_edit_product_dialog.dart';

/// FutureProvider يجلب المنتجات بشكل مرن
final productsListProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final raw = await api.getProducts(); // يمكن أن يكون List/Map/String

  List<dynamic> fromMap(Map map) {
    final m = Map<String, dynamic>.from(map);
    if (m['products'] is List) return List<dynamic>.from(m['products']);
    if (m['data'] is List) return List<dynamic>.from(m['data']);
    if (m['items'] is List) return List<dynamic>.from(m['items']);
    return const [];
  }

  List<dynamic> fromString(String s) {
    String t = s.trim();
    final start = t.indexOf(RegExp(r'[\{\[]'));
    if (start == -1) return const [];
    t = t.substring(start);
    final lastBrace = t.lastIndexOf('}');
    final lastBracket = t.lastIndexOf(']');
    final end = (lastBrace > lastBracket) ? lastBrace : lastBracket;
    if (end != -1) t = t.substring(0, end + 1);
    final decoded = jsonDecode(t);
    if (decoded is List) return decoded;
    if (decoded is Map) return fromMap(decoded);
    return const [];
  }

  List<dynamic> listDyn = const [];
  if (raw is List) {
    listDyn = raw;
  } else if (raw is Map) {
    listDyn = fromMap(raw as Map);
  } else if (raw is String) {
    listDyn = fromString(raw as String);
  }

  return listDyn
      .whereType<Map>()
      .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
      .toList();
});

/// تأكيد الحذف
Future<bool> confirmDeleteProduct(
  BuildContext context,
  WidgetRef ref, {
  required Product product,
}) async {
  bool isLoading = false;

  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: !isLoading,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('delete_product'),
        content: const Text('are_you_sure_delete'),
        actions: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            label: const Text('حذف'),
            onPressed: isLoading
                ? null
                : () async {
                    setState(() => isLoading = true);
                    try {
                      final api = ref.read(apiServiceProvider);
                      final ok = await api.deleteProduct(product.id.toString());

                      if (!context.mounted) return;
                      Navigator.pop(context, ok);

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'تم حذف المنتج' : 'فشل الحذف'),
                        backgroundColor: ok ? Colors.green : Colors.red,
                      ));

                      if (ok) {
                        // إنعاش اللستة
                        ref.invalidate(productsListProvider);
                        ref.read(productProvider.notifier).loadFromBackend();
                      }
                    } catch (e) {
                      setState(() => isLoading = false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
          ),
        ],
      ),
    ),
  );

  return res == true;
}

/// شاشة عرض المنتجات + زر تحديث
class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final productsAsync = ref.watch(productsListProvider);
    final navigation = ref.read(navigationProvider.notifier);

    Future<void> _refresh() async {
      // تحديث مزود الشاشة + مزامنة الحالة العامة إن كنت تستخدمها في أماكن أخرى
      ref.invalidate(productsListProvider);
      await ref.read(productProvider.notifier).loadFromBackend();
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.get('products') ?? 'المنتجات',
                    style: Theme.of(context).textTheme.headlineMedium),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(t.get('refresh') ?? 'تحديث'),
                      onPressed: productsAsync.isLoading ? null : _refresh,
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_box),
                      label: Text(t.get('add_product') ?? 'إضافة منتج'),
                      onPressed: () {
                        // الديالوج نفسه يقوم بعمل loadFromBackend بعد النجاح
                        showAddGeneralProductDialog(context, ref);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: productsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, st) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('خطأ في تحميل المنتجات:\n$err'),
                    ),
                  ),
                  data: (products) {
                    // سحب للتحديث
                    if (products.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            Center(child: Text('لا توجد منتجات بعد')),
                            SizedBox(height: 200),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final p = products[index];
                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.inventory_2_outlined),
                            ),
                            title: Text(p.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((p.description ?? '').trim().isNotEmpty)
                                  Text('الوصف: ${p.description}'),
                                Text('الكمية: ${p.quantity} ${p.unit}'),
                                Text('السعر: ${p.actualPiecePrice}'),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () => navigation.go(
                              NavigationState.productDetails(p.id),
                            ),
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                IconButton(
                                  tooltip: t.get('edit') ?? 'تعديل',
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () async {
                                    // ديالوج التعديل الخاص بك
                                    showEditProductDialog(
                                      context,
                                      ref,
                                      product: p,
                                    );
                                    // بعد الإغلاق سيُستدعى التحديث من الديالوج (إن رغبت)
                                    // أو يمكنك إجبار تحديث القائمة هنا:
                                    // await _refresh();
                                  },
                                ),
                                IconButton(
                                  tooltip: t.get('delete') ?? 'حذف',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final ok = await confirmDeleteProduct(
                                      context,
                                      ref,
                                      product: p,
                                    );
                                    if (ok) await _refresh();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
