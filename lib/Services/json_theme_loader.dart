import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonThemeLoader {
  static Map<String, ThemeData>? _themes;
  
  static Future<Map<String, ThemeData>> loadThemes() async {
    if (_themes != null) return _themes!;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/themes.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _themes = {};
      for (String themeName in jsonData['themes'].keys) {
        final themeConfig = jsonData['themes'][themeName];
        _themes![themeName] = _createThemeFromJson(themeConfig);
      }
      
      return _themes!;
    } catch (e) {
      print('Error loading themes: $e');
      return _getDefaultThemes();
    }
  }
  
  static ThemeData _createThemeFromJson(Map<String, dynamic> config) {
    final brightness = config['brightness'] == 'dark' ? Brightness.dark : Brightness.light;
    final primaryColor = Color(int.parse(config['primaryColor'].replaceAll('#', '0xFF')));
    final backgroundColor = Color(int.parse(config['backgroundColor'].replaceAll('#', '0xFF')));
    final surfaceColor = Color(int.parse(config['surfaceColor'].replaceAll('#', '0xFF')));
    final textColor = Color(int.parse(config['textColor'].replaceAll('#', '0xFF')));
    final appBarColor = Color(int.parse(config['appBarColor'].replaceAll('#', '0xFF')));
    final appBarTextColor = Color(int.parse(config['appBarTextColor'].replaceAll('#', '0xFF')));
    final buttonColor = Color(int.parse(config['buttonColor'].replaceAll('#', '0xFF')));
    final buttonTextColor = Color(int.parse(config['buttonTextColor'].replaceAll('#', '0xFF')));
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarColor,
        foregroundColor: appBarTextColor,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: buttonTextColor,
          backgroundColor: buttonColor,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
        titleLarge: TextStyle(color: textColor),
      ),
    );
  }
  
  static Map<String, ThemeData> _getDefaultThemes() {
    return {
      'Light': ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      'Dark': ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
    };
  }
}