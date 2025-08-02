# Multilingual Setup for SimpeltStop

This document explains how the multilingual (internationalization) system is set up in the SimpeltStop Flutter app.

## Overview

The app now supports multiple languages with a comprehensive localization system that includes:

- **3 Languages**: English (en), Spanish (es), French (fr)
- **Dynamic Language Switching**: Users can change language from the profile settings
- **Persistent Language Selection**: Language choice is saved and restored on app restart
- **Complete UI Translation**: All user-facing text is translated

## File Structure

```
assets/translations/
├── en.json          # English translations
├── es.json          # Spanish translations
└── fr.json          # French translations

lib/
├── services/
│   └── localization_service.dart    # Main localization service
├── utils/
│   └── localization_extension.dart  # Extension for easier usage
└── widgets/common/
    └── language_selector.dart       # Language selection UI
```

## How to Use

### 1. Basic Translation

```dart
// Using the service directly
final localizationService = Provider.of<LocalizationService>(context, listen: false);
String text = localizationService.tr('auth.welcome_back');

// Using the extension (recommended)
String text = context.tr('auth.welcome_back');
```

### 2. Translation with Parameters

```dart
// In translation file: "welcome_user": "Welcome, {0}!"
String text = context.tr('welcome_user', args: ['John']);
// Result: "Welcome, John!"
```

### 3. Adding New Translations

1. **Add the key to all language files** (`assets/translations/en.json`, `es.json`, `fr.json`):

```json
{
  "new_section": {
    "new_key": "English text"
  }
}
```

2. **Use in your code**:

```dart
Text(context.tr('new_section.new_key'))
```

### 4. Adding a New Language

1. **Create a new translation file** (`assets/translations/de.json` for German):

```json
{
  "app": {
    "name": "SimpeltStop",
    "version": "1.0.0"
  },
  "auth": {
    "welcome_back": "Willkommen zurück",
    // ... all other translations
  }
}
```

2. **Update the LocalizationService**:

```dart
static const Map<String, String> supportedLanguages = {
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'de': 'Deutsch',  // Add this line
};
```

3. **Update main.dart**:

```dart
supportedLocales: const [
  Locale('en'),
  Locale('es'),
  Locale('fr'),
  Locale('de'),  // Add this line
],
```

## Translation Keys Structure

The translation keys are organized hierarchically:

```
app.name                    # App name
auth.welcome_back          # Authentication screens
dashboard.overview         # Dashboard tabs
profile.title              # Profile section
common.loading             # Common UI elements
messages.success.login     # Success messages
messages.error.generic     # Error messages
validation.required        # Validation messages
```

## Language Selection

Users can change the language by:

1. Going to **Profile** tab
2. Tapping **Language** in the Settings section
3. Selecting their preferred language from the list

The selection is automatically saved and will persist across app restarts.

## Best Practices

1. **Always use translation keys** instead of hardcoded strings
2. **Use descriptive key names** that indicate the context
3. **Group related translations** under common prefixes
4. **Test all languages** when adding new features
5. **Keep translations concise** and natural in each language

## Technical Details

### LocalizationService

- Extends `ChangeNotifier` for reactive updates
- Uses `SharedPreferences` to persist language selection
- Loads JSON translation files from assets
- Provides fallback to English if translation is missing
- Supports string interpolation with `{0}`, `{1}`, etc.

### Performance

- Translations are loaded once per language change
- JSON files are cached in memory
- No performance impact on UI rendering
- Minimal memory footprint

## Troubleshooting

### Translation Not Showing

1. Check if the key exists in all language files
2. Verify the key path is correct (use dot notation)
3. Ensure the LocalizationService is properly initialized

### Language Not Changing

1. Check if the language code is added to `supportedLanguages`
2. Verify the translation file exists in `assets/translations/`
3. Ensure the file is properly formatted JSON

### Missing Translations

1. Add the missing key to all language files
2. Use English as fallback for missing translations
3. Consider using a translation management tool for larger projects

## Future Enhancements

- **RTL Support**: For languages like Arabic and Hebrew
- **Pluralization**: Handle different plural forms
- **Date/Number Formatting**: Locale-specific formatting
- **Translation Management**: Online translation management system
- **Auto-detection**: Detect device language on first launch 