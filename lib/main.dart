// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/services/localization_service.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'utils/constants.dart';
import 'routes/app_routes.dart';
import 'services/storage_service.dart';
import 'providers/progress/progress_provider.dart';
import 'providers/audio/audio_provider.dart';
import 'providers/payment_provider.dart';
import 'screens/welcome/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences
  await StorageService.init();

  // Initialize LocalizationService
  final localizationService = LocalizationService();
  await localizationService.initialize();

  runApp(MyApp(localizationService: localizationService));
}

class MyApp extends StatelessWidget {
  final LocalizationService localizationService;
  const MyApp({super.key, required this.localizationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => localizationService),
      ],
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return MaterialApp(
            title: 'SimpeltStop',
            theme: AppTheme.lightTheme,
            locale: Locale(localizationService.currentLanguage),
            supportedLocales: const [
              Locale('en'),
              Locale('es'),
              Locale('fr'),
              Locale('da'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: _getInitialRoute(),
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            debugShowCheckedModeBanner: false,
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }

  String _getInitialRoute() {
    return AppRoutes.splash;
  }
}
