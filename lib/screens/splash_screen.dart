import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1C2E), // لون قريب من خلفية الشعار
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ✅ شعار كبير وواضح
            Image.asset(
              'assets/pictures/logo_splash.png',
              height: 280,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            const Text(
              'مرحباً بك في نظام إدارة المستودعات',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
