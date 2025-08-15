import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:warehouse/providers/locale_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return IconButton(
      icon: Icon(isArabic ? Icons.language : Icons.translate),
      tooltip: isArabic ? 'English' : 'العربية',
      onPressed: () {
        final newLocale = isArabic ? const Locale('en') : const Locale('ar');
        ref.read(localeProvider.notifier).changeLocale(newLocale);
      },
    );
  }
}
