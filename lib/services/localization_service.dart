import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';

  Map<String, dynamic> _translations = {};
  String _currentLanguage = _defaultLanguage;

  // Supported languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'es': 'Español',
    'fr': 'Français',
    'da': 'Dansk',
  };

  String get currentLanguage => _currentLanguage;
  Map<String, dynamic> get translations => _translations;

  // Get translation by key
  String tr(String key, {List<String>? args}) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        // Return the key if translation not found
        return key;
      }
    }

    if (value is String) {
      if (args != null && args.isNotEmpty) {
        // Simple string interpolation
        String result = value;
        for (int i = 0; i < args.length; i++) {
          result = result.replaceAll('{$i}', args[i]);
        }
        return result;
      }
      return value;
    }

    return key;
  }

  // Initialize localization
  Future<void> initialize() async {
    await _loadSavedLanguage();
    await _loadTranslations();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? _defaultLanguage;
  }

  // Load translations for current language
  Future<void> _loadTranslations() async {
    try {
      final path = 'assets/translations/$_currentLanguage.json';
      print('Loading translations from: $path');
      final jsonString = await rootBundle.loadString(path);
      final loadedTranslations = json.decode(jsonString);
      // Only update and notify if translations actually changed
      if (json.encode(_translations) != json.encode(loadedTranslations)) {
        _translations = loadedTranslations;
        print('Successfully loaded translations for $_currentLanguage');
        notifyListeners();
      } else {
        print(
          'Translations for $_currentLanguage already loaded, skipping notifyListeners',
        );
      }
    } catch (e) {
      print('Error loading translations for $_currentLanguage: $e');
      // Fallback to English if translation file not found
      if (_currentLanguage != _defaultLanguage) {
        print('Falling back to $_defaultLanguage');
        _currentLanguage = _defaultLanguage;
        await _loadTranslations();
      } else {
        print('Failed to load even default language translations');
        // Set empty translations to prevent crashes
        _translations = {};
      }
    }
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (supportedLanguages.containsKey(languageCode) &&
        languageCode != _currentLanguage) {
      _currentLanguage = languageCode;

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);

      // Load new translations
      await _loadTranslations();
    }
  }

  // Get current language name
  String getCurrentLanguageName() {
    return supportedLanguages[_currentLanguage] ?? 'English';
  }

  // Get all supported languages
  Map<String, String> getSupportedLanguages() {
    return supportedLanguages;
  }

  // Check if a language is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }
}
