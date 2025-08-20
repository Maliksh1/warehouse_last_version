import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warehouse/providers/locale_provider.dart';
import 'package:warehouse/widgets/language_switcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LanguageSwitcher يبدّل اللغة عند الضغط', (tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localeProvider.overrideWith(
            (ref) => LocaleNotifier(const Locale('ar'), prefs),
          ),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              final locale = ref.watch(localeProvider);
              return Scaffold(
                appBar: AppBar(
                  actions: const [LanguageSwitcher()],
                ),
                body: Center(
                  // نعرض كود اللغة الحالي حتى نتحقق منه في الاختبار
                  child: Text(locale.languageCode, key: const Key('lang')),
                ),
              );
            },
          ),
        ),
      ),
    );

    // البداية بالعربية
    expect(find.byKey(const Key('lang')), findsOneWidget);
    expect(find.text('ar'), findsOneWidget);

    // اضغط زر التبديل
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();

    // يتغير إلى الإنجليزية
    expect(find.text('en'), findsOneWidget);

    // اضغط مرة أخرى يرجع إلى العربية
    await tester.tap(find.byType(IconButton));
    await tester.pumpAndSettle();
    expect(find.text('ar'), findsOneWidget);
  });
}
