// lib/widgets/logout_sheet.dart
import 'package:flutter/material.dart';
import 'package:warehouse/services/logout_service.dart';

typedef AfterLogout = void Function();

Future<void> showLogoutSheet(
  BuildContext context, {
  AfterLogout? onAfterLogout,
}) async {
  final theme = Theme.of(context);
  final result = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 32, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            const Text(
              'تأكيد تسجيل الخروج',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'هل أنت متأكد من رغبتك بتسجيل الخروج من الحساب الحالي؟',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('إلغاء'),
                    onPressed: () => Navigator.of(ctx).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('تسجيل الخروج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (result == true && context.mounted) {
    // نفّذ الخروج من الحساب
    final out = await LogoutService.logout();

    // أظهر رسالة مناسبة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(out.message)),
    );

    // التوجيه لصفحة تسجيل الدخول (Route name أو Widget)
    // إن كان لديك Route معرف باسم '/login':
    if (onAfterLogout != null) {
      onAfterLogout();
    } else {
      // افتراضي: إلى مسار '/login'
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }
}
