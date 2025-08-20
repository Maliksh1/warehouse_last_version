import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:warehouse/providers/api_service_provider.dart';
import 'package:warehouse/providers/product_provider.dart'; // سنحدّث القائمة عبره
import 'package:warehouse/providers/product_types_provider.dart';

Future<bool?> showAddGeneralProductDialog(
  BuildContext parentContext, // ← مرّر سياق الشاشة هنا
  WidgetRef ref,
) {
  // —— Controllers —— (لا نعمل dispose يدويًا لتفادي الاستخدام بعد الإزالة)
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();

  final nameContainerCtrl = TextEditingController();
  final capacityCtrl = TextEditingController();

  final nameStorageCtrl = TextEditingController();
  final floorsCtrl = TextEditingController();
  final classesCtrl = TextEditingController();
  final positionsCtrl = TextEditingController();

  // اختياري
  final lowTempCtrl = TextEditingController();
  final highTempCtrl = TextEditingController();
  final lowHumCtrl = TextEditingController();
  final highHumCtrl = TextEditingController();
  final lowLightCtrl = TextEditingController();
  final highLightCtrl = TextEditingController();
  final lowPressCtrl = TextEditingController();
  final highPressCtrl = TextEditingController();
  final lowVentCtrl = TextEditingController();
  final highVentCtrl = TextEditingController();

  final selectedTypeId = ValueNotifier<int?>(null);
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;
  String? _numReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return num.tryParse(v.trim()) == null ? 'رقم غير صالح' : null;
  }

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'عدد صحيح غير صالح' : null;
  }

  String? _numOpt(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return num.tryParse(v.trim()) == null ? 'رقم غير صالح' : null;
  }

  bool _pairOk(String lo, String hi) {
    final loN = num.tryParse(lo.trim());
    final hiN = num.tryParse(hi.trim());
    if (loN == null || hiN == null) return true;
    return hiN >= loN;
  }

  return showDialog<bool>(
    context: parentContext,
    barrierDismissible: false,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنتج (name)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الوصف (description)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: _req,
                  ),
                  const SizedBox(height: 8),

                  // النوع من API
                  Consumer(builder: (_, ref, __) {
                    final typesAsync = ref.watch(productTypesProvider);
                    return typesAsync.when(
                      data: (types) {
                        final items = types.whereType<Map>().map((e) {
                          final id = (e['id'] as num).toInt();
                          final name = (e['name'] ?? '').toString();
                          return DropdownMenuItem<int>(
                            value: id,
                            child: Text('$name (id: $id)'),
                          );
                        }).toList();
                        return ValueListenableBuilder<int?>(
                          valueListenable: selectedTypeId,
                          builder: (_, val, __) => DropdownButtonFormField<int>(
                            value: val,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'نوع المنتج (type_id)',
                              border: OutlineInputBorder(),
                            ),
                            items: items,
                            onChanged: (v) => selectedTypeId.value = v,
                            validator: (v) => v == null ? 'مطلوب' : null,
                          ),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Text('خطأ بتحميل الأنواع: $e'),
                    );
                  }),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: priceCtrl,
                          decoration: const InputDecoration(
                            labelText: 'سعر القطعة (actual_piece_price)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numReq,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: unitCtrl,
                          decoration: const InputDecoration(
                            labelText: 'الوحدة (unit)',
                            border: OutlineInputBorder(),
                          ),
                          validator: _req,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'الكمية (quantity)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _numReq,
                  ),

                  const SizedBox(height: 16),
                  const Text('شروط التخزين (اختياري)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // temperature
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lowTempCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أدنى حرارة (lowest_temperature)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numOpt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: highTempCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أعلى حرارة (highest_temperature)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final base = _numOpt(v);
                            if (base != null) return base;
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                lowTempCtrl.text.trim().isNotEmpty &&
                                !_pairOk(lowTempCtrl.text, v)) {
                              return 'يجب أن تكون أعلى حرارة ≥ أدنى حرارة';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // humidity
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lowHumCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أدنى رطوبة (lowest_humidity)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numOpt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: highHumCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أعلى رطوبة (highest_humidity)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final base = _numOpt(v);
                            if (base != null) return base;
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                lowHumCtrl.text.trim().isNotEmpty &&
                                !_pairOk(lowHumCtrl.text, v)) {
                              return 'يجب أن تكون أعلى رطوبة ≥ أدنى رطوبة';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // light
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lowLightCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أدنى إضاءة (lowest_light)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numOpt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: highLightCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أعلى إضاءة (highest_light)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final base = _numOpt(v);
                            if (base != null) return base;
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                lowLightCtrl.text.trim().isNotEmpty &&
                                !_pairOk(lowLightCtrl.text, v)) {
                              return 'يجب أن تكون أعلى إضاءة ≥ أدنى إضاءة';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // pressure
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lowPressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أدنى ضغط (lowest_pressure)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numOpt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: highPressCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أعلى ضغط (highest_pressure)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final base = _numOpt(v);
                            if (base != null) return base;
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                lowPressCtrl.text.trim().isNotEmpty &&
                                !_pairOk(lowPressCtrl.text, v)) {
                              return 'يجب أن يكون أعلى ضغط ≥ أدنى ضغط';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ventilation
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: lowVentCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أدنى تهوية (lowest_ventilation)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _numOpt,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: highVentCtrl,
                          decoration: const InputDecoration(
                            labelText: 'أعلى تهوية (highest_ventilation)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final base = _numOpt(v);
                            if (base != null) return base;
                            if (v != null &&
                                v.trim().isNotEmpty &&
                                lowVentCtrl.text.trim().isNotEmpty &&
                                !_pairOk(lowVentCtrl.text, v)) {
                              return 'يجب أن تكون أعلى تهوية ≥ أدنى تهوية';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('بيانات الحاوية',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameContainerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم الحاوية (name_container)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: capacityCtrl,
                    decoration: const InputDecoration(
                      labelText: 'السعة (capacity)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _numReq,
                  ),

                  const SizedBox(height: 16),
                  const Text('بيانات وسيط التخزين',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameStorageCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم وسيط التخزين (name_storage_media)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _req,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: floorsCtrl,
                          decoration: const InputDecoration(
                            labelText: 'عدد الطوابق (num_floors)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _intReq,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: classesCtrl,
                          decoration: const InputDecoration(
                            labelText: 'عدد الصفوف (num_classes)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _intReq,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: positionsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'عدد المواقع بالصف (num_positions_on_class)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _intReq,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    // فقط أغلق — لا setState، لا dispose هنا
                    Navigator.of(context).pop(false);
                  },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    if (!formKey.currentState!.validate()) return;

                    // علاقات ≥ (إن وُجدت قيم)
                    if (highTempCtrl.text.trim().isNotEmpty &&
                        lowTempCtrl.text.trim().isNotEmpty &&
                        !_pairOk(lowTempCtrl.text, highTempCtrl.text)) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content:
                                Text('يجب أن تكون أعلى حرارة ≥ أدنى حرارة'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (highHumCtrl.text.trim().isNotEmpty &&
                        lowHumCtrl.text.trim().isNotEmpty &&
                        !_pairOk(lowHumCtrl.text, highHumCtrl.text)) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content:
                                Text('يجب أن تكون أعلى رطوبة ≥ أدنى رطوبة'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (highLightCtrl.text.trim().isNotEmpty &&
                        lowLightCtrl.text.trim().isNotEmpty &&
                        !_pairOk(lowLightCtrl.text, highLightCtrl.text)) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content:
                                Text('يجب أن تكون أعلى إضاءة ≥ أدنى إضاءة'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (highPressCtrl.text.trim().isNotEmpty &&
                        lowPressCtrl.text.trim().isNotEmpty &&
                        !_pairOk(lowPressCtrl.text, highPressCtrl.text)) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content: Text('يجب أن يكون أعلى ضغط ≥ أدنى ضغط'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }
                    if (highVentCtrl.text.trim().isNotEmpty &&
                        lowVentCtrl.text.trim().isNotEmpty &&
                        !_pairOk(lowVentCtrl.text, highVentCtrl.text)) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(
                            content:
                                Text('يجب أن تكون أعلى تهوية ≥ أدنى تهوية'),
                            backgroundColor: Colors.red),
                      );
                      return;
                    }

                    setState(() => isLoading = true);
                    try {
                      final api = ref.read(apiServiceProvider);

                      // كل الحقول المطلوبة موجودة:
                      final payload = <String, dynamic>{
                        "name": nameCtrl.text.trim(),
                        "description": descCtrl.text.trim(),
                        "type_id": selectedTypeId.value,
                        "actual_piece_price": num.parse(priceCtrl.text.trim()),
                        "unit": unitCtrl.text.trim(),
                        "quantity": num.parse(qtyCtrl.text.trim()),
                        "name_container": nameContainerCtrl.text.trim(),
                        "capacity": num.parse(capacityCtrl.text.trim()),
                        "name_storage_media": nameStorageCtrl.text.trim(),
                        "num_floors": int.parse(floorsCtrl.text.trim()),
                        "num_classes": int.parse(classesCtrl.text.trim()),
                        "num_positions_on_class":
                            int.parse(positionsCtrl.text.trim()),
                        if (lowTempCtrl.text.trim().isNotEmpty)
                          "lowest_temperature":
                              num.parse(lowTempCtrl.text.trim()),
                        if (highTempCtrl.text.trim().isNotEmpty)
                          "highest_temperature":
                              num.parse(highTempCtrl.text.trim()),
                        if (lowHumCtrl.text.trim().isNotEmpty)
                          "lowest_humidity": num.parse(lowHumCtrl.text.trim()),
                        if (highHumCtrl.text.trim().isNotEmpty)
                          "highest_humidity":
                              num.parse(highHumCtrl.text.trim()),
                        if (lowLightCtrl.text.trim().isNotEmpty)
                          "lowest_light": num.parse(lowLightCtrl.text.trim()),
                        if (highLightCtrl.text.trim().isNotEmpty)
                          "highest_light": num.parse(highLightCtrl.text.trim()),
                        if (lowPressCtrl.text.trim().isNotEmpty)
                          "lowest_pressure":
                              num.parse(lowPressCtrl.text.trim()),
                        if (highPressCtrl.text.trim().isNotEmpty)
                          "highest_pressure":
                              num.parse(highPressCtrl.text.trim()),
                        if (lowVentCtrl.text.trim().isNotEmpty)
                          "lowest_ventilation":
                              num.parse(lowVentCtrl.text.trim()),
                        if (highVentCtrl.text.trim().isNotEmpty)
                          "highest_ventilation":
                              num.parse(highVentCtrl.text.trim()),
                      };

                      await api.addProduct(payload);

                      if (!context.mounted) return;

                      // ✨ أغلق الديالوج أولاً
                      Navigator.of(context).pop(true);

                      // ✨ بعد الإغلاق: حدّث القائمة واعرض الرسالة بسياق الشاشة
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref.read(productProvider.notifier).loadFromBackend();
                        ScaffoldMessenger.maybeOf(parentContext)?.showSnackBar(
                          const SnackBar(
                            content: Text('تم إنشاء المنتج بنجاح'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                        ScaffoldMessenger.maybeOf(parentContext)?.showSnackBar(
                          SnackBar(
                              content: Text('فشل الإرسال: $e'),
                              backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
        ],
      ),
    ),
  );
}
