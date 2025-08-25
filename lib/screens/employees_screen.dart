// lib/screens/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/services/employees_api.dart';

class EmployeesScreen extends StatefulWidget {
  /// إذا تُركا null تُعرض شاشة إرشادية عامة.
  final String? placeType; // "Warehouse" | "DistributionCenter"
  final int? placeId;

  const EmployeesScreen({
    super.key,
    this.placeType,
    this.placeId,
  });

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  Future<List<Employee>>? _future;

  @override
  void initState() {
    super.initState();
    if (widget.placeType != null && widget.placeId != null) {
      _future = EmployeesApi.fetchOnPlace(
        placeType: widget.placeType!,
        placeId: widget.placeId!,
      );
    }
  }

  Future<void> _reload() async {
    if (widget.placeType == null || widget.placeId == null) return;
    setState(() {
      _future = EmployeesApi.fetchOnPlace(
        placeType: widget.placeType!,
        placeId: widget.placeId!,
      );
    });
  }

  Future<void> _addEmployee() async {
    if (widget.placeType == null || widget.placeId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _AddEmployeeDialog(
        workableType: widget.placeType!,
        workableId: widget.placeId!,
      ),
    );
    if (ok == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    // حالة الاستخدام العام من القائمة الرئيسية بدون placeType/placeId
    if (widget.placeType == null || widget.placeId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الموظفون')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'افتح هذه الصفحة من داخل مستودع أو مركز توزيع لعرض موظفيه.\n'
              'مثال: من لوحة التحكم اضغط بطاقة "الموظفون".',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الموظفون - ${widget.placeType} #${widget.placeId}',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEmployee,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('إضافة موظف'),
      ),
      body: _future == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Employee>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child:
                          Text('خطأ في تحميل الموظفين:\n${snap.error ?? ''}'),
                    ),
                  );
                }
                final list = snap.data ?? const <Employee>[];
                if (list.isEmpty) {
                  return const Center(
                      child: Text('لا يوجد موظفون في هذا المكان'));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final e = list[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          e.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (e.specialization != null &&
                                e.specialization!.isNotEmpty)
                              Text('الاختصاص: ${e.specialization}'),
                            if (e.email != null && e.email!.isNotEmpty)
                              Text('الإيميل: ${e.email}'),
                            if (e.phoneNumber != null &&
                                e.phoneNumber!.isNotEmpty)
                              Text('الجوال: ${e.phoneNumber}'),
                            if (e.salary != null && e.salary!.isNotEmpty)
                              Text('الراتب: ${e.salary}'),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'حذف',
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('تأكيد الحذف'),
                                content: Text('حذف الموظف "${e.name}"؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final ok = await EmployeesApi.delete(e.id);
                              if (ok) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('تم حذف الموظف'),
                                  backgroundColor: Colors.green,
                                ));
                                _reload();
                              } else {
                                final msg = EmployeesApi.lastErrorMessage ??
                                    'تعذّر حذف الموظف';
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(msg),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

/// حوار إضافة موظف
class _AddEmployeeDialog extends StatefulWidget {
  final String workableType; // 'Warehouse' | 'DistributionCenter'
  final int workableId;
  const _AddEmployeeDialog({
    required this.workableType,
    required this.workableId,
  });

  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _specializationId = TextEditingController(); // رقم فقط لتبسيط الواجهة
  final _salary = TextEditingController();
  final _birthDay = TextEditingController(); // اختياري: YYYY-MM-DD
  final _country = TextEditingController();
  final _startTime = TextEditingController(text: '08:00');
  final _workHours = TextEditingController(text: '8');

  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _specializationId.dispose();
    _salary.dispose();
    _birthDay.dispose();
    _country.dispose();
    _startTime.dispose();
    _workHours.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  String? _emailReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    return ok ? null : 'بريد غير صالح';
  }

  String? _intReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    return int.tryParse(v.trim()) == null ? 'رقم غير صالح' : null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final ok = await EmployeesApi.create(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phoneNumber: _phone.text.trim(),
      specializationId: int.parse(_specializationId.text.trim()),
      salary: _salary.text.trim(),
      birthDay: _birthDay.text.trim().isEmpty ? null : _birthDay.text.trim(),
      country: _country.text.trim(),
      startTime: _startTime.text.trim(),
      workHours: _workHours.text.trim(),
      workableType: widget.workableType,
      workableId: widget.workableId,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context, true);
    } else {
      final msg = EmployeesApi.lastErrorMessage ?? 'فشل إضافة الموظف';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة موظف'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  border: OutlineInputBorder(),
                ),
                validator: _req,
                enabled: !_submitting,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'البريد',
                  border: OutlineInputBorder(),
                ),
                validator: _emailReq,
                enabled: !_submitting,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _password,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور (≥ 8)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 8)
                    ? 'مطلوب 8 أحرف على الأقل'
                    : null,
                enabled: !_submitting,
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phone,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  border: OutlineInputBorder(),
                ),
                validator: _req,
                enabled: !_submitting,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specializationId,
                decoration: const InputDecoration(
                  labelText: 'ID الاختصاص',
                  border: OutlineInputBorder(),
                ),
                validator: _intReq,
                enabled: !_submitting,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _salary,
                decoration: const InputDecoration(
                  labelText: 'الراتب',
                  border: OutlineInputBorder(),
                ),
                validator: _req,
                enabled: !_submitting,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _birthDay,
                decoration: const InputDecoration(
                  labelText: 'تاريخ الميلاد (YYYY-MM-DD) - اختياري',
                  border: OutlineInputBorder(),
                ),
                enabled: !_submitting,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _country,
                decoration: const InputDecoration(
                  labelText: 'الدولة',
                  border: OutlineInputBorder(),
                ),
                validator: _req,
                enabled: !_submitting,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTime,
                      decoration: const InputDecoration(
                        labelText: 'وقت البدء',
                        border: OutlineInputBorder(),
                      ),
                      validator: _req,
                      enabled: !_submitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _workHours,
                      decoration: const InputDecoration(
                        labelText: 'ساعات العمل',
                        border: OutlineInputBorder(),
                      ),
                      validator: _req,
                      enabled: !_submitting,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'المكان: ${widget.workableType} #${widget.workableId}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context, false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_submitting ? 'جارٍ الحفظ...' : 'إضافة'),
        ),
      ],
    );
  }
}
