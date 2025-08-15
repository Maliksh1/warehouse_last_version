import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:warehouse/providers/auth_provider.dart';
import 'package:warehouse/screens/start_application_screen.dart';
import 'package:warehouse/lang/app_localizations.dart';
import 'app_container.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final savedEmail = await _storage.read(key: 'saved_email');
    final savedPassword = await _storage.read(key: 'saved_password');
    final savedPhone = await _storage.read(key: 'saved_phone');

    if (savedEmail != null && savedPassword != null && savedPhone != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _phoneController.text = savedPhone;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials(
      String email, String password, String phone) async {
    await _storage.write(key: 'saved_email', value: email);
    await _storage.write(key: 'saved_password', value: password);
    await _storage.write(key: 'saved_phone', value: phone);
  }

  Future<void> _clearCredentials() async {
    await _storage.delete(key: 'saved_email');
    await _storage.delete(key: 'saved_password');
    await _storage.delete(key: 'saved_phone');
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final phone = _phoneController.text.trim();

      if (_rememberMe) {
        await _saveCredentials(email, password, phone);
      } else {
        await _clearCredentials();
      }

      ref.read(authProvider.notifier).login(
            email: email,
            password: password,
            phoneNumber: phone,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (prev, next) {
      next.whenOrNull(
        data: (loggedIn) {
          if (loggedIn && context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => AppContainer()),
            );
          }
        },
        error: (error, _) {
          String errorMessage = error.toString();
          final msgMatch =
              RegExp(r'msg[^\w]*:\s*(.*?)($|,|\})').firstMatch(errorMessage);
          if (msgMatch != null) {
            errorMessage = msgMatch.group(1)!;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(t.get('login') ?? 'تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField(
                _emailController,
                t.get('email') ?? 'البريد الإلكتروني',
                TextInputType.emailAddress,
              ),
              _buildField(
                _passwordController,
                t.get('password') ?? 'كلمة المرور',
                TextInputType.text,
                obscure: true,
              ),
              _buildField(
                _phoneController,
                t.get('phone_number') ?? 'رقم الهاتف',
                TextInputType.phone,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (val) {
                      setState(() {
                        _rememberMe = val ?? false;
                      });
                    },
                  ),
                  const Text("تذكرني"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: authState.isLoading ? null : _login,
                child: authState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(t.get('login') ?? 'دخول'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StartApplicationScreen(),
                    ),
                  );
                },
                child: const Text(
                  'إنشاء حساب مشرف',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    TextInputType inputType, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';

          if (controller == _emailController &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'أدخل بريدًا إلكترونيًا صحيحًا';
          }

          if (controller == _passwordController && value.length < 9) {
            return 'كلمة المرور يجب ألا تقل عن 9 رموز';
          }

          if (controller == _phoneController && value.length > 10) {
            return 'رقم الهاتف يجب ألا يزيد عن 10 أرقام';
          }

          return null;
        },
      ),
    );
  }
}
