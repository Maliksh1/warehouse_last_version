import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart';

// إنشاء مزود لخدمة API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

void showAddProductTypeDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final specificationController = TextEditingController();

  // متغير لتتبع حالة الإرسال
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false, // منع إغلاق الحوار أثناء الإرسال
    builder: (_) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(t.get('add_product_type') ?? 'إضافة نوع منتج جديد'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // حقل اسم النوع
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: t.get('type_name') ?? 'اسم النوع',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'الرجاء إدخال اسم النوع'
                        : null,
                  ),
                ),

                // حقل المواصفات
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TextFormField(
                    controller: specificationController,
                    decoration: InputDecoration(
                      labelText: t.get('specification') ?? 'المواصفات',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty
                        ? 'الرجاء إدخال المواصفات'
                        : null,
                  ),
                ),
              ],
            ),
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
                    if (formKey.currentState!.validate()) {
                      // تعيين حالة التحميل
                      setState(() {
                        isLoading = true;
                      });

                      try {
                        // إرسال البيانات إلى API
                        final apiService = ref.read(apiServiceProvider);
                        final result = await apiService.addProductType(
                          nameController.text,
                          specificationController.text,
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();

                          // عرض رسالة نجاح
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  t.get('product_type_added_successfully') ??
                                      'تم إضافة نوع المنتج بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        // إعادة تعيين حالة التحميل
                        setState(() {
                          isLoading = false;
                        });

                        // عرض رسالة خطأ
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('فشل إضافة نوع المنتج: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
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
    }),
  );
}
