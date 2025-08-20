import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يدير حالة اللغة ويحفظها في SharedPreferences
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;

  /// مرّر اللغة الابتدائية و SharedPreferences من main.dart عبر override
  LocaleNotifier(Locale initialLocale, this.prefs) : super(initialLocale);

  /// تبديل سريع بين العربية/الإنجليزية
  Future<void> toggleLocale() async {
    final newCode = state.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(newCode);
  }

  /// تعيين لغة محددة ('ar' أو 'en')
  Future<void> setLocale(String languageCode) async {
    if (!['ar', 'en'].contains(languageCode)) {
      // لغة غير مدعومة حاليًا — تجاهل بهدوء
      return;
    }
    final newLocale = Locale(languageCode);
    state = newLocale;
    await prefs.setString('language_code', languageCode);
  }

  /// غلاف مريح ليستقبل Locale مباشرة (متوافق مع LanguageSwitcher لديك)
  Future<void> changeLocale(Locale locale) => setLocale(locale.languageCode);
}

/// مزوّد الحالة للّغة — سيتم override له في main.dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  throw UnimplementedError('localeProvider must be overridden in main.dart');
});

/// (اختياري) مزوّد صفحة/قسم مختار — تركته هنا كما ظهر في كودك السابق
final selectedPageIndexProvider = StateProvider<int>((ref) => 0);
