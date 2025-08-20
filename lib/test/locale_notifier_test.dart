import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warehouse/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // نبدأ كل اختبار بمسجرة تفضيلات فارغة
    SharedPreferences.setMockInitialValues({});
  });

  test('LocaleNotifier: init, setLocale, toggleLocale, changeLocale', () async {
    final prefs = await SharedPreferences.getInstance();
    final notifier = LocaleNotifier(const Locale('ar'), prefs);

    // الحالة الابتدائية
    expect(notifier.state, const Locale('ar'));
    expect(prefs.getString('language_code'), isNull);

    // setLocale إلى en
    await notifier.setLocale('en');
    expect(notifier.state, const Locale('en'));
    expect(prefs.getString('language_code'), 'en');

    // toggle يعيدها إلى ar
    await notifier.toggleLocale();
    expect(notifier.state, const Locale('ar'));
    expect(prefs.getString('language_code'), 'ar');

    // changeLocale بتمرير Locale مباشرة
    await notifier.changeLocale(const Locale('en'));
    expect(notifier.state, const Locale('en'));
    expect(prefs.getString('language_code'), 'en');

    // setLocale للغة غير مدعومة → يتجاهل
    await notifier.setLocale('fr');
    expect(notifier.state, const Locale('en')); // لم تتغيّر
    expect(prefs.getString('language_code'), 'en');
  });

  test('Provider override يعمل ويعكس التغييرات على state', () async {
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(overrides: [
      localeProvider.overrideWith(
        (ref) => LocaleNotifier(const Locale('ar'), prefs),
      ),
    ]);

    addTearDown(container.dispose);

    // قراءة الحالة الابتدائية
    expect(container.read(localeProvider), const Locale('ar'));

    // تعديلها من خلال الـ notifier
    await container.read(localeProvider.notifier).setLocale('en');
    expect(container.read(localeProvider), const Locale('en'));

    // التبديل
    await container.read(localeProvider.notifier).toggleLocale();
    expect(container.read(localeProvider), const Locale('ar'));
  });
}
