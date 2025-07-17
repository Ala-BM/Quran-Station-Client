import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:theway/Services/json_theme_loader.dart';

class JsonThemeProvider extends ChangeNotifier {
  String _currentTheme = 'Light';
  ThemeData _themeData = ThemeData.light();
  Map<String, ThemeData> _availableThemes = {};
  late Box _settingsBox;
  bool _isInitialized = false;

  String get currentTheme => _currentTheme;
  ThemeData get themeData => _themeData;
  List<String> get availableThemes => _availableThemes.keys.toList();
  bool get isInitialized => _isInitialized;

  JsonThemeProvider() {
    _initializeThemes();
  }

  Future<void> _initializeThemes() async {
    try {
      // Initialize Hive box
      _settingsBox = await Hive.openBox('settings');
      
      // Load themes from JSON
      _availableThemes = await JsonThemeLoader.loadThemes();
      
      // Load saved theme preference
      _currentTheme = _settingsBox.get('theme', defaultValue: 'Light');
      
      // Set initial theme
      if (_availableThemes.containsKey(_currentTheme)) {
        _themeData = _availableThemes[_currentTheme]!;
      } else {
        _currentTheme = _availableThemes.keys.first;
        _themeData = _availableThemes[_currentTheme]!;
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing themes: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setTheme(String themeName) async {
    if (_availableThemes.containsKey(themeName)) {
      _currentTheme = themeName;
      _themeData = _availableThemes[themeName]!;
      
      // Save to Hive
      await _settingsBox.put('theme', themeName);
      
      notifyListeners();
    }
  }

  // Method to reload themes (useful for hot reload during development)
  Future<void> reloadThemes() async {
    _availableThemes = await JsonThemeLoader.loadThemes();
    if (_availableThemes.containsKey(_currentTheme)) {
      _themeData = _availableThemes[_currentTheme]!;
    }
    notifyListeners();
  }

  // Method to add custom theme at runtime
  void addCustomTheme(String name, ThemeData theme) {
    _availableThemes[name] = theme;
    notifyListeners();
  }

  // Method to get theme colors for preview
  Map<String, Color> getThemeColors(String themeName) {
    if (!_availableThemes.containsKey(themeName)) return {};
    
    final theme = _availableThemes[themeName]!;
    return {
      'primary': theme.colorScheme.primary,
      'secondary': theme.colorScheme.secondary,
      'background': theme.colorScheme.background,
      'surface': theme.colorScheme.surface,
    };
  }
}