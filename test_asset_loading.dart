import 'dart:convert';
import 'package:flutter/services.dart';

void main() async {
  try {
    print('Testing asset loading...');
    
    // Test loading English translation
    final enString = await rootBundle.loadString('assets/translations/en.json');
    final enData = json.decode(enString);
    print('✅ English translation loaded successfully');
    
    // Test loading Danish translation
    final daString = await rootBundle.loadString('assets/translations/da.json');
    final daData = json.decode(daString);
    print('✅ Danish translation loaded successfully');
    
    // Test loading Spanish translation
    final esString = await rootBundle.loadString('assets/translations/es.json');
    final esData = json.decode(esString);
    print('✅ Spanish translation loaded successfully');
    
    // Test loading French translation
    final frString = await rootBundle.loadString('assets/translations/fr.json');
    final frData = json.decode(frString);
    print('✅ French translation loaded successfully');
    
    print('All translation files loaded successfully!');
    
  } catch (e) {
    print('❌ Error loading translations: $e');
  }
} 