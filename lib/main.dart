import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/widgets/Dialogs/show_add_general_product_dialog.dart';

import 'lang/app_localizations.dart';
import 'providers/locale_provider.dart';
// إذا لا تستخدم navigation_provider هنا يمكنك حذف الاستيراد
import 'providers/navigation_provider.dart';

import 'screens/app_container.dart';

import 'screens/product_details_screen.dart';
import 'screens/splash_screen.dart'; // <-- أضف هذا

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language_code') ?? 'ar';

  runApp(
    ProviderScope(
      overrides: [
        localeProvider.overrideWith(
          (ref) => LocaleNotifier(Locale(savedLanguage), prefs),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: AppLocalizations.of(context)?.get('app_title') ?? 'Warehouse',
      locale: currentLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        cardTheme: const CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          margin: EdgeInsets.zero,
        ),
        textTheme: const TextTheme(
          headlineMedium:
              TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14.0),
          bodySmall: TextStyle(fontSize: 12.0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          background: Colors.white,
          onBackground: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
      ),

      // ✅ ابدأ بـ SplashScreen
      home: const SplashScreen(),

      // ✅ Routes with arguments
      onGenerateRoute: (settings) {
        if (settings.name == '/add-product') {
  
          return MaterialPageRoute(
            builder: (context) => _AddProductDialogWrapper(),
          );
        }

        if (settings.name == '/product-details') {
          final productId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(productId: productId),
          );
        }

        return null;
      },
    );
  }
}

class _AddProductDialogWrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show the dialog when this widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showAddGeneralProductDialog(context, ref);
    });
    
    // Return a simple container as the widget
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
