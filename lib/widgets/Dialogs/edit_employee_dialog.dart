import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Required for date/time formatting
import 'package:warehouse/models/employee.dart';
import 'package:warehouse/services/employees_api.dart';

/// A dialog for editing an existing employee's details.
class EditEmployeeDialog extends StatefulWidget {
  final Employee employee;

  const EditEmployeeDialog({super.key, required this.employee});

  @override
  State<EditEmployeeDialog> createState() => _EditEmployeeDialogState();
}

class _EditEmployeeDialogState extends State<EditEmployeeDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _phone;
  late final TextEditingController _salary;
  late final TextEditingController _country;
  late final TextEditingController _workHours;

  // State variables for date and time pickers
  DateTime? _birthDay;
  TimeOfDay? _startTime;

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final e = widget.employee;

    // Initialize text controllers with existing data
    _name = TextEditingController(text: e.name);
    _email = TextEditingController(text: e.email ?? '');
    _password =
        TextEditingController(); // Password is not pre-filled for security
    _phone = TextEditingController(text: e.phoneNumber ?? '');
    _salary = TextEditingController(text: e.salary ?? '');
    _country = TextEditingController(text: e.country ?? '');
    _workHours = TextEditingController(text: e.workHours ?? '');

    // Initialize date and time from employee's string data
    // Note: This requires the date/time strings to be in a valid format.
    // if (e.birthDay != null) {
    //   _birthDay = DateTime.tryParse(e.birthDay!);
    // }
    if (e.startTime != null) {
      final parts = e.startTime!.split(':');
      if (parts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
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

  // Validation helpers
  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null;

  String? _emailReq(String? v) {
    if (v == null || v.trim().isEmpty) return 'مطلوب';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim());
    return ok ? null : 'بريد غير صالح';
  }

  // Date and Time Picker Functions
  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDay ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDay) {
      setState(() {
        _birthDay = picked;
      });
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    // Build the payload with only the fields that have been changed.
    final payload = <String, dynamic>{
      'employe_id': widget.employee.id,

      // **[FIXED]** Always send the specialization_id as it is required by the backend.
      if (widget.employee.specializationId != null)
        'specialization_id': widget.employee.specializationId,

      if (_name.text.trim().isNotEmpty) 'name': _name.text.trim(),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      if (_password.text.isNotEmpty) 'password': _password.text,
      if (_phone.text.trim().isNotEmpty) 'phone_number': _phone.text.trim(),
      if (_salary.text.trim().isNotEmpty) 'salary': _salary.text.trim(),
      if (_birthDay != null)
        'birth_day': DateFormat('yyyy-MM-dd').format(_birthDay!),
      if (_country.text.trim().isNotEmpty) 'country': _country.text.trim(),
      if (_startTime != null)
        'start_time':
            '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      if (_workHours.text.trim().isNotEmpty)
        'work_hours': _workHours.text.trim(),
    };

    final ok = await EmployeesApi.edit(payload: payload);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (ok) {
      Navigator.pop(context, true); // Return true on success
    } else {
      final msg = EmployeesApi.lastErrorMessage ?? 'فشل تعديل الموظف';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعديل بيانات الموظف'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Note about non-editable fields
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  'ملاحظة: لا يمكن تعديل الاختصاص أو مكان العمل.',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 12),

              // Form Fields
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'الاسم', border: OutlineInputBorder()),
                  validator: _req),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                      labelText: 'البريد', border: OutlineInputBorder()),
                  validator: _emailReq,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _password,
                  decoration: const InputDecoration(
                      labelText: 'كلمة المرور (اتركه فارغاً لعدم التغيير)',
                      border: OutlineInputBorder()),
                  obscureText: true),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                      labelText: 'رقم الجوال', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 8),
              // Specialization (Read-only)
              TextFormField(
                initialValue: widget.employee.specialization ?? 'غير محدد',
                decoration: const InputDecoration(
                  labelText: 'الاختصاص (غير قابل للتعديل)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color.fromARGB(255, 236, 236, 236),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _salary,
                  decoration: const InputDecoration(
                      labelText: 'الراتب', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              // Birth Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _birthDay == null
                      ? 'اختر تاريخ الميلاد'
                      : 'تاريخ الميلاد: ${DateFormat('yyyy-MM-dd').format(_birthDay!)}',
                ),
                onTap: _pickBirthDate,
              ),
              TextFormField(
                  controller: _country,
                  decoration: const InputDecoration(
                      labelText: 'الدولة', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              // Start Time Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: Text(
                  _startTime == null
                      ? 'اختر وقت البدء'
                      : 'وقت البدء: ${_startTime!.format(context)}',
                ),
                onTap: _pickStartTime,
              ),
              TextFormField(
                  controller: _workHours,
                  decoration: const InputDecoration(
                      labelText: 'ساعات العمل', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number),
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
          label: Text(_submitting ? 'جارٍ الحفظ...' : 'حفظ التعديلات'),
        ),
      ],
    );
  }
}
