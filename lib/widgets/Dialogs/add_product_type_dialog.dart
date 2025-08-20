import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

// لو ما كان عندك هذا المزود مضاف مسبقًا
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

void showAddProductTypeDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();

  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(t.get('add_product_type') ?? 'add_product_type'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t.get('type_name') ?? 'type_name',
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              validator: (val) {
                final v = (val ?? '').trim();
                if (v.isEmpty) return 'الرجاء إدخال اسم النوع';
                if (v.length < 2) return 'الاسم قصير جدًا';
                return null;
              },
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(t.get('cancel') ?? 'إلغاء'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;

                      setState(() => isLoading = true);
                      try {
                        final api = ref.read(apiServiceProvider);

                        // ✅ إذا دالتك في ApiService ما زالت تستقبل (name, text) مرّر نصًا فارغًا
                        // await api.addProductType(nameController.text.trim(), '');

                        // ✅ أو الأفضل: عدّل توقيع الدالة ليكون addProductType(String name) فقط
                        // ثم استخدم السطر التالي:
                        await api.addProductType(
                            nameController.text.trim(), '');

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                t.get('product_type_added_successfully') ??
                                    'تم إضافة نوع المنتج بنجاح',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }

                        // اختياري: إن كان عندك provider لقائمة الأنواع، اعمل له invalidate
                        // ref.invalidate(typesProvider);
                      } catch (e) {
                        debugPrint('addProductType error: $e');
                        setState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل إضافة نوع المنتج: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(t.get('save') ?? 'حفظ'),
            ),
          ],
        );
      },
    ),
  );
}
