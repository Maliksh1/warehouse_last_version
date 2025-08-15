import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:warehouse/providers/auth_provider.dart';
import '../lang/app_localizations.dart';

class StartApplicationScreen extends ConsumerStatefulWidget {
  const StartApplicationScreen({super.key});

  @override
  ConsumerState<StartApplicationScreen> createState() =>
      _StartApplicationScreenState();
}

class _StartApplicationScreenState
    extends ConsumerState<StartApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final salaryController = TextEditingController();
  final countryController = TextEditingController();
  final workHoursController = TextEditingController();

  // Date and Time
  DateTime? birthDay;
  TimeOfDay? startTime;

  int selectedSpecializationId = 1;

  bool isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (birthDay == null || startTime == null) {
      _showError('الرجاء إدخال تاريخ الميلاد ووقت البدء');
      return;
    }

    setState(() => isLoading = true);

    final formattedDate = DateFormat('yyyy-MM-dd').format(birthDay!);
    final formattedTime =
        '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}';

    try {
      await ref.read(authProvider.notifier).registerAdminExtended(
            name: nameController.text.trim(),
            email: emailController.text.trim(),
            password: passwordController.text,
            phoneNumber: phoneController.text.trim(),
            salary: salaryController.text.trim(),
            birthDay: formattedDate,
            country: countryController.text.trim(),
            startTime: formattedTime,
            workHours: workHoursController.text.trim(),
          );
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => birthDay = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => startTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: Text(t.get('start_application') ?? 'بدء التطبيق')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(nameController, 'اسم المشرف', TextInputType.name,
                  validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return 'الاسم يجب أن لا يقل عن 3 أحرف';
                }
                return null;
              }),
              _buildField(emailController, 'البريد الإلكتروني',
                  TextInputType.emailAddress, validator: (val) {
                if (val == null || val.isEmpty) return 'مطلوب';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(val)) {
                  return 'صيغة بريد غير صحيحة';
                }
                return null;
              }),
              _buildField(passwordController, 'كلمة المرور',
                  TextInputType.visiblePassword, obscure: true,
                  validator: (val) {
                if (val == null || val.length < 9) {
                  return 'كلمة المرور لا تقل عن 9 رموز';
                }
                return null;
              }),
              _buildField(phoneController, 'رقم الهاتف', TextInputType.phone,
                  validator: (val) {
                if (val == null || val.isEmpty) return 'مطلوب';
                if (val.length > 10) return 'لا يزيد عن 10 أرقام';
                return null;
              }),
              _buildField(salaryController, 'الراتب', TextInputType.number,
                  validator: (val) {
                if (val == null || double.tryParse(val) == null) {
                  return 'أدخل رقمًا صحيحًا';
                }
                return null;
              }),
              _buildField(countryController, 'الدولة', TextInputType.text),
              _buildField(
                  workHoursController, 'عدد ساعات العمل', TextInputType.number),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _pickBirthDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  birthDay == null
                      ? 'اختر تاريخ الميلاد'
                      : 'تاريخ الميلاد: ${DateFormat('yyyy-MM-dd').format(birthDay!)}',
                ),
              ),
              TextButton.icon(
                onPressed: _pickStartTime,
                icon: const Icon(Icons.access_time),
                label: Text(
                  startTime == null
                      ? 'اختر وقت البدء'
                      : 'وقت البدء: ${startTime!.format(context)}',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إنشاء المشرف'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType, {
    String? Function(String?)? validator,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator ??
            (value) => (value == null || value.isEmpty) ? 'مطلوب' : null,
      ),
    );
  }
}
