import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lang/app_localizations.dart';
import 'screens/dashboard_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('language_code') ?? 'ar';
  runApp(MyApp(savedLanguage: savedLanguage));
}

class MyApp extends StatefulWidget {
  final String savedLanguage;
  MyApp({required this.savedLanguage});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = Locale(widget.savedLanguage);
  }

  void toggleLocale() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _locale = _locale.languageCode == 'ar' ? Locale('en') : Locale('ar');
    });
    await prefs.setString('language_code', _locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: _locale.languageCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: DashboardHome(onLanguageToggle: toggleLocale),
      ),
    );
  }
}
