import 'package:flutter/material.dart';
import 'package:theway/Classes/AudioPlayer.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:theway/Classes/KhinsiderAlbums.dart';
import 'screens/sources.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart'; 
import 'Services/hive_service.dart';
Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter
    await HiveService.initBox();

  // Register the adapter for KhinAudio
  if (!Hive.isAdapterRegistered(KhinAudioAdapter().typeId)) {
    Hive.registerAdapter(KhinAudioAdapter());
  }



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioManager()),
        ChangeNotifierProvider(
          create: (context) => HiveService(),
        ),
      ],
      child: const MyApp(),
    ),
  );

    
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  
  @override

 _MyAppstate createState() => _MyAppstate();
}

class _MyAppstate extends State<MyApp> {
  Locale _locale = const Locale('en'); // Default language

  void _changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')], // Supported languages
      localizationsDelegates: const [
        AppLocalizations.delegate, // Custom delegate
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
            localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Sources(onLanguageChange: _changeLanguage),
    );
  }
}



