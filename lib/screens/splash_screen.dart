// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warehouse/screens/app_container.dart';
import 'package:warehouse/screens/login_screen.dart';
import 'package:warehouse/screens/start_application_screen.dart';
import 'package:warehouse/providers/api_service_provider.dart';

enum _Next { app, login, start }

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // أقل مدة لعرض السبلّاش (شكل ألطف)
  static const Duration _minSplash = Duration(milliseconds: 800);
  // مهلة الشبكة القصوى لقرارات السبلّاش
  static const Duration _netTimeout = Duration(seconds: 8);

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    // نضمن ظهور السبلّاش قليلًا
    final splashDelay = Future.delayed(_minSplash);

    // احسب الوجهة التالية مع مهلة قصوى (حتى لا يعلّق)
    final next = await _computeNext().timeout(_netTimeout, onTimeout: () {
      // لو الشبكة تأخرت: ودّه للّوجن كافتراضي
      return _Next.login;
    });

    // انتظر الحد الأدنى للعرض
    await splashDelay;

    if (!mounted) return;

    switch (next) {
      case _Next.app:
        _push(AppContainer());
        break;
      case _Next.login:
        _push(const LoginScreen());
        break;
      case _Next.start:
        _push(const StartApplicationScreen());
        break;
    }
  }

  Future<_Next> _computeNext() async {
    // 1) شرط البقاء مسجلاً: وجود توكن + keep_signed_in = true
    final prefs = await SharedPreferences.getInstance();
    final keepSignedIn = prefs.getBool('keep_signed_in') ?? false;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token != null && token.isNotEmpty && keepSignedIn) {
      // المستخدم اختار البقاء مسجلاً
      return _Next.app;
    }

    // 2) بدون الشرطين معًا: قرر بين StartApplication / Login
    try {
      final api = ref.read(apiServiceProvider);

      // الاختصاصات: ابحث عن super_admin
      final specs = await api.getSpecializations();
      final superAdmin = specs.whereType<Map>().cast<Map>().firstWhere(
            (m) => (m['name'] ?? '').toString() == 'super_admin',
            orElse: () => {},
          );

      if (superAdmin.isEmpty) {
        // لا يوجد اختصاص أدمن → ابدأ الإعداد
        return _Next.start;
      }

      final sidDyn = superAdmin['id'];
      final sid = (sidDyn is num) ? sidDyn.toInt() : int.tryParse('$sidDyn');
      if (sid == null) return _Next.start;

      // هل هناك موظفون ضمن super_admin؟
      final admins = await api.getEmployeesBySpecialization(sid);
      final hasAdmin = admins.isNotEmpty;

      // لا يوجد توكن نشط مع keep_signed_in → وجّه للّوجن إذا كان هناك أدمن
      return hasAdmin ? _Next.login : _Next.start;
    } catch (_) {
      // أي مشكلة شبكة/JSON → لا تعلّق، روح Login
      return _Next.login;
    }
  }

  void _push(Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E2A47),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Image.asset(
                'assets/pictures/logo_splash.png',
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                // لو الصورة ناقصة لا توقف السبلّاش
                errorBuilder: (_, __, ___) => const FlutterLogo(size: 96),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'مرحباً بك في نظام إدارة المستودعات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
