import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define a StateNotifier to manage the Locale state
class LocaleNotifier extends StateNotifier<Locale> {
  final SharedPreferences prefs;

  // Initial locale is passed during creation
  LocaleNotifier(Locale initialLocale, this.prefs) : super(initialLocale);

  // Method to toggle language between 'ar' and 'en'
  Future<void> toggleLocale() async {
    final newLanguageCode = state.languageCode == 'ar' ? 'en' : 'ar';
    final newLocale = Locale(newLanguageCode);
    state = newLocale; // Update the state
    await prefs.setString('language_code', newLanguageCode); // Save preference
  }

  // Optional: Method to set a specific locale
  Future<void> setLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    if (['en', 'ar'].contains(languageCode)) {
      state = newLocale;
      await prefs.setString('language_code', languageCode);
    } else {
      print("Unsupported language code: $languageCode");
    }
  }
}

// Define the StateNotifierProvider for the LocaleNotifier
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  throw UnimplementedError('localeProvider must be overridden in main.dart');
});

// --- Provider to track the currently selected page/section ---
// This provider controls which widget is displayed in the main content area.
// Indices 0-12 (or more) correspond to the main section screens.
// Negative indices can be used for special views like creation forms or detail screens.
// E.g., -1 could mean "Show Create Transport Task form".
final selectedPageIndexProvider =
    StateProvider<int>((ref) => 0); // Start with index 0 (Dashboard Overview)