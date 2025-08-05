import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:audio_session/audio_session.dart';
import 'package:theway/Providers/cnx_plus_provider.dart';
import 'package:theway/Providers/AudioPlayer.dart';
import 'package:theway/Providers/KhinsiderAlbums.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/screens/sources.dart';
import 'package:theway/l10n/app_localizations.dart';
import 'package:theway/Providers/hive_service.dart';
import 'package:theway/widgets/animations/blur_ani.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupAudioSession();
  await HiveService.
  initBox();
  
  if (!Hive.isAdapterRegistered(KhinAudioAdapter().typeId)) {
    Hive.registerAdapter(KhinAudioAdapter());
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AudioManager()),
        ChangeNotifierProvider(create: (context) => HiveService()),
        ChangeNotifierProvider(create: (context) => ConnectionProvider()),
        ChangeNotifierProvider(create: (context) => JsonThemeProvider())
      ],
      child: const MyApp(),
    ),
  );
}
Future<void> _setupAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
      supportedLocales: const [Locale('en'), Locale('ar')], 
      localizationsDelegates: const [
        AppLocalizations.delegate,
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
      title: 'Q Station',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlurAni(child: Sources(onLanguageChange: _changeLanguage)), 
    );
  }
}