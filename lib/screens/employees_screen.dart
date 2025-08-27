// lib/screens/employees_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/services/employees_api.dart';
import 'package:warehouse/widgets/Dialogs/edit_employee_dialog.dart';
import 'package:warehouse/screens/employee_details_screen.dart';
// **[NEW]** Imports for the new add employee flow
import 'package:warehouse/models/warehouse.dart';
import 'package:warehouse/models/distribution_center.dart';
import 'package:warehouse/services/warehouse_api.dart';
import 'package:warehouse/services/distribution_center_api.dart';
import 'package:warehouse/warehouse_updates/updated_api_service.dart'; // For specializations

class EmployeesScreen extends StatefulWidget {
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
  bool _isGeneralView = false;

  @override
  void initState() {
    super.initState();
    _isGeneralView = (widget.placeType == null || widget.placeId == null);
    _loadEmployees();
  }

  void _loadEmployees() {
    if (_isGeneralView) {
      _future = EmployeesApi.fetchAllEmployees();
    } else {
      _future = EmployeesApi.fetchOnPlace(
        placeType: widget.placeType!,
        placeId: widget.placeId!,
      );
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loadEmployees();
    });
  }

  Future<void> _addEmployee() async {
    if (!_isGeneralView) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => _AddEmployeeDialog(
          workableType: widget.placeType!,
          workableId: widget.placeId!,
        ),
      );
      if (ok == true) _reload();
    } else {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (_) => const _SelectWorkplaceDialog(),
      );

      if (result != null && mounted) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => _AddEmployeeDialog(
            workableType: result['type'],
            workableId: result['id'],
          ),
        );
        if (ok == true) _reload();
      }
    }
  }

  Future<void> _editEmployee(Employee employee) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => EditEmployeeDialog(employee: employee),
    );
    if (ok == true) {
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم تحديث بيانات الموظف بنجاح'),
          backgroundColor: Colors.green,
        ));
      }
    }
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('حذف الموظف "${employee.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final ok = await EmployeesApi.delete(employee.id);
      if (ok) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('تم حذف الموظف'),
          backgroundColor: Colors.green,
        ));
        _reload();
      } else {
        final msg = EmployeesApi.lastErrorMessage ?? 'تعذّر حذف الموظف';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isGeneralView
              ? 'كل الموظفين'
              : 'الموظفون - ${widget.placeType} #${widget.placeId}',
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
      body: FutureBuilder<List<Employee>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('خطأ في تحميل الموظفين:\n${snap.error ?? ''}'),
              ),
            );
          }
          final list = snap.data ?? const <Employee>[];
          if (list.isEmpty) {
            return Center(
                child: Text(_isGeneralView
                    ? 'لا يوجد موظفون في النظام حالياً'
                    : 'لا يوجد موظفون في هذا المكان'));
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
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EmployeeDetailsScreen(employee: e),
                      ),
                    );

                    if (result == 'edit') {
                      _editEmployee(e);
                    } else if (result == 'delete') {
                      _deleteEmployee(e);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SelectWorkplaceDialog extends StatefulWidget {
  const _SelectWorkplaceDialog();

  @override
  State<_SelectWorkplaceDialog> createState() => _SelectWorkplaceDialogState();
}

class _SelectWorkplaceDialogState extends State<_SelectWorkplaceDialog> {
  String _selectedType = 'Warehouse';

  late Future<List<Warehouse>> _warehousesFuture;
  late Future<List<DistributionCenter>> _centersFuture;

  dynamic _selectedValue;

  @override
  void initState() {
    super.initState();
    _warehousesFuture = WarehouseApi.fetchAllWarehouses();
    _centersFuture = DistributionCenterApi.fetchAllDistributionCenters();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تحديد مكان العمل'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(children: [
                    Icon(Icons.warehouse),
                    SizedBox(width: 8),
                    Text('مستودع')
                  ]),
                  value: 'Warehouse',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        _selectedValue = null;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Row(children: [
                    Icon(Icons.hub),
                    SizedBox(width: 8),
                    Text('مركز توزيع')
                  ]),
                  value: 'DistributionCenter',
                  groupValue: _selectedType,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                        _selectedValue = null;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedType == 'Warehouse')
            _buildDropdown<Warehouse>(_warehousesFuture, 'اختر المستودع')
          else
            _buildDropdown<DistributionCenter>(
                _centersFuture, 'اختر مركز التوزيع'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _selectedValue == null
              ? null
              : () {
                  final id = int.tryParse(_selectedValue.id.toString());
                  if (id == null) return;

                  Navigator.pop(context, {
                    'type': _selectedType,
                    'id': id,
                  });
                },
          child: const Text('التالي'),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(Future<List<T>> future, String hint) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('خطأ في التحميل: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('لا توجد بيانات متاحة');
        }

        final items = snapshot.data!;
        return DropdownButtonFormField<T>(
          value: _selectedValue,
          hint: Text(hint),
          isExpanded: true,
          items: items.map<DropdownMenuItem<T>>((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text((item as dynamic).name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedValue = value;
            });
          },
          validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
        );
      },
    );
  }
}

class _AddEmployeeDialog extends StatefulWidget {
  final String workableType;
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
  final _salary = TextEditingController();
  final _country = TextEditingController();
  final _workHours = TextEditingController(text: '8');

  int? _selectedSpecializationId;
  late Future<List<dynamic>> _specializationsFuture;

  DateTime? _birthDayValue;
  TimeOfDay? _startTimeValue = const TimeOfDay(hour: 8, minute: 0);

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _specializationsFuture = ApiService().getSpecializations();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _salary.dispose();
    _country.dispose();
    _workHours.dispose();
    super.dispose();
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;
  String? _emailReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    return ok ? null : 'بريد غير صالح';
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDayValue ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDayValue = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTimeValue ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _startTimeValue = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSpecializationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('الرجاء اختيار التخصص'), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _submitting = true);
    final ok = await EmployeesApi.create(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      phoneNumber: _phone.text.trim(),
      specializationId: _selectedSpecializationId!,
      salary: _salary.text.trim(),
      birthDay: _birthDayValue != null
          ? DateFormat('yyyy-MM-dd').format(_birthDayValue!)
          : null,
      country: _country.text.trim(),
      startTime:
          '${_startTimeValue!.hour.toString().padLeft(2, '0')}:${_startTimeValue!.minute.toString().padLeft(2, '0')}',
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
                      labelText: 'الاسم', border: OutlineInputBorder()),
                  validator: _req,
                  enabled: !_submitting),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      labelText: 'البريد', border: OutlineInputBorder()),
                  validator: _emailReq,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                      labelText: 'كلمة المرور (≥ 8)',
                      border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.length < 8)
                      ? 'مطلوب 8 أحرف على الأقل'
                      : null,
                  enabled: !_submitting,
                  obscureText: true),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                      labelText: 'رقم الجوال', border: OutlineInputBorder()),
                  validator: _req,
                  enabled: !_submitting,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              FutureBuilder<List<dynamic>>(
                future: _specializationsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('لا توجد تخصصات متاحة');
                  }
                  final items = snapshot.data!;
                  return DropdownButtonFormField<int>(
                    value: _selectedSpecializationId,
                    hint: const Text('اختر التخصص'),
                    isExpanded: true,
                    items: items.map<DropdownMenuItem<int>>((item) {
                      return DropdownMenuItem<int>(
                        value: item['id'],
                        child: Text(item['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSpecializationId = value;
                      });
                    },
                    validator: (value) => value == null ? 'مطلوب' : null,
                  );
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _salary,
                  decoration: const InputDecoration(
                      labelText: 'الراتب', border: OutlineInputBorder()),
                  validator: _req,
                  enabled: !_submitting,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _birthDayValue == null
                      ? 'اختر تاريخ الميلاد (اختياري)'
                      : 'تاريخ الميلاد: ${DateFormat('yyyy-MM-dd').format(_birthDayValue!)}',
                ),
                onTap: _pickBirthDate,
              ),
              TextFormField(
                  controller: _country,
                  decoration: const InputDecoration(
                      labelText: 'الدولة', border: OutlineInputBorder()),
                  validator: _req,
                  enabled: !_submitting),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(
                  _startTimeValue == null
                      ? 'اختر وقت البدء'
                      : 'وقت البدء: ${_startTimeValue!.format(context)}',
                ),
                onTap: _pickStartTime,
              ),
              TextFormField(
                  controller: _workHours,
                  decoration: const InputDecoration(
                      labelText: 'ساعات العمل', border: OutlineInputBorder()),
                  validator: _req,
                  enabled: !_submitting,
                  keyboardType: TextInputType.number),
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
