import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/lang/app_localizations.dart';

import 'package:warehouse/providers/specializations_provider.dart';

void showAddSpecializationDialog(BuildContext context, WidgetRef ref) {
  final t = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Text(t.get('add_specialization') ?? 'إضافة اختصاص'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: t.get('specialization_name') ?? 'اسم الاختصاص',
              border: const OutlineInputBorder(),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'يرجى إدخال الاسم' : null,
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
                      setState(() => isLoading = true);
                      try {
                        final api = ref.read(apiServiceProvider);
                        await api.addSpecialization(nameController.text);

                        // ✅ تحديث البيانات من السيرفر بعد الإضافة
                        ref.invalidate(specializationsProvider);

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                t.get('specialization_added_successfully') ??
                                    'تمت إضافة الاختصاص'),
                            backgroundColor: Colors.green,
                          ));
                        }
                      } catch (e) {
                        setState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('فشل الإضافة: $e'),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(t.get('save') ?? 'حفظ'),
          ),
        ],
      );
    }),
  );
}
