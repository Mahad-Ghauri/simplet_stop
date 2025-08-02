import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';

extension LocalizationExtension on BuildContext {
  LocalizationService get localization =>
      Provider.of<LocalizationService>(this, listen: false);

  String tr(String key, {List<String>? args}) {
    return localization.tr(key, args: args);
  }
}
