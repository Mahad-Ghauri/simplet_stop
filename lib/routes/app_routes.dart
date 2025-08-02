// lib/utils/app_routes.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/reading/reading_content_screen.dart';
import '../screens/audio/audio_list_screen.dart' hide AudioContent;
import '../screens/audio/audio_player_screen.dart';
import '../screens/craving/craving_timer_screen.dart' hide AudioContent;
import '../models/audio_content_model.dart';
import '../screens/payment/payment_screen.dart';
import '../providers/audio/audio_provider.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String readingContent = '/reading-content';
  static const String audioPlayer = '/audio-player';
  static const String audioList = '/audio-list';
  static const String payment = '/payment';
  static const String cravingTimer = '/craving-timer';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      dashboard: (context) => const DashboardScreen(),
      readingContent: (context) => const ReadingContentScreen(),
      audioList: (context) => const AudioListScreen(),
      audioPlayer: (context) => AudioPlayerScreen(),
      payment: (context) => const PaymentScreen(),
      cravingTimer: (context) => const CravingTimerScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case audioPlayer:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (context) {
            // Handle audio loading if arguments are provided
            if (args != null) {
              final audioProvider = Provider.of<AudioPlayerProvider>(
                context,
                listen: false,
              );

              // Use addPostFrameCallback to ensure provider is ready
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await _handleAudioPlayback(audioProvider, args);
              });
            }

            return AudioPlayerScreen();
          },
        );

      case readingContent:
        return MaterialPageRoute(
          builder: (context) => const ReadingContentScreen(),
        );

      case payment:
        return MaterialPageRoute(builder: (context) => const PaymentScreen());

      default:
        return _errorRoute();
    }
  }

  // Centralized audio playback handler
  static Future<void> _handleAudioPlayback(
    AudioPlayerProvider provider,
    Map<String, dynamic> args,
  ) async {
    try {
      if (args.containsKey('audio')) {
        // Play AudioContent object directly
        final audio = args['audio'] as AudioContent;
        debugPrint('Playing AudioContent: ${audio.title}');
        await provider.playAudioContent(audio);
      } else if (args.containsKey('audioMap')) {
        // Convert map to AudioContent and play
        final audioMap = args['audioMap'] as Map<String, dynamic>;
        final audio = AudioContent.fromMap(audioMap);
        debugPrint('Playing AudioContent from map: ${audio.title}');
        await provider.playAudioContent(audio);
      } else if (args.containsKey('audioId')) {
        // Load from Firestore by ID
        final audioId = args['audioId'] as String;
        debugPrint('Playing AudioContent by ID: $audioId');
        await provider.playAudioById(audioId);
      } else if (args.containsKey('url')) {
        // Direct URL playback
        final url = args['url'] as String;
        debugPrint('Playing from URL: $url');
        await provider.playFromUrl(url);
      } else if (args.containsKey('filePath')) {
        // Direct file playback
        final filePath = args['filePath'] as String;
        debugPrint('Playing from file: $filePath');
        await provider.playFromFile(filePath);
      } else if (args.containsKey('assetPath')) {
        // Direct asset playback
        final assetPath = args['assetPath'] as String;
        debugPrint('Playing from asset: $assetPath');
        await provider.playFromAsset(assetPath);
      }
    } catch (e) {
      debugPrint('Error in audio playback handler: $e');
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Page not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'The requested page could not be found.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NAVIGATION HELPER METHODS

  // Basic navigation methods
  static void pushAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pushReplacement(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void push(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  static String? getCurrentRouteName(BuildContext context) {
    return ModalRoute.of(context)?.settings.name;
  }

  // AUDIO PLAYER NAVIGATION METHODS

  /// Navigate to audio player with AudioContent object from Firestore
  static void pushAudioPlayer(BuildContext context, AudioContent audio) {
    debugPrint('Navigating to audio player with AudioContent: ${audio.title}');
    Navigator.pushNamed(context, audioPlayer, arguments: {'audio': audio});
  }

  /// Navigate to audio player by loading AudioContent from Firestore by ID
  static void pushAudioPlayerById(BuildContext context, String audioId) {
    debugPrint('Navigating to audio player with ID: $audioId');
    Navigator.pushNamed(context, audioPlayer, arguments: {'audioId': audioId});
  }

  /// Navigate to audio player with AudioContent as Map
  static void pushAudioPlayerFromMap(
    BuildContext context,
    Map<String, dynamic> audioMap,
  ) {
    debugPrint('Navigating to audio player with audio map');
    Navigator.pushNamed(
      context,
      audioPlayer,
      arguments: {'audioMap': audioMap},
    );
  }

  /// Navigate to audio player with direct URL
  static void pushAudioPlayerFromUrl(BuildContext context, String url) {
    debugPrint('Navigating to audio player with URL: $url');
    Navigator.pushNamed(context, audioPlayer, arguments: {'url': url});
  }

  /// Navigate to audio player with direct asset path
  static void pushAudioPlayerFromAsset(BuildContext context, String assetPath) {
    debugPrint('Navigating to audio player with asset: $assetPath');
    Navigator.pushNamed(
      context,
      audioPlayer,
      arguments: {'assetPath': assetPath},
    );
  }

  /// Navigate to audio player with direct file path
  static void pushAudioPlayerFromFile(BuildContext context, String filePath) {
    debugPrint('Navigating to audio player with file: $filePath');
    Navigator.pushNamed(
      context,
      audioPlayer,
      arguments: {'filePath': filePath},
    );
  }

  // OTHER SPECIALIZED NAVIGATION METHODS

  /// Navigate to payment screen with options
  static void pushPayment(
    BuildContext context, {
    String? planType,
    String? returnRoute,
  }) {
    Navigator.pushNamed(
      context,
      payment,
      arguments: {'planType': planType, 'returnRoute': returnRoute},
    );
  }

  /// Navigate to reading content screen
  static void pushReadingContent(BuildContext context, {String? contentId}) {
    Navigator.pushNamed(
      context,
      readingContent,
      arguments: contentId != null ? {'contentId': contentId} : null,
    );
  }

  // SAFE NAVIGATION WITH ERROR HANDLING

  /// Safe navigation that handles errors gracefully
  static Future<T?> safePush<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    try {
      return await Navigator.pushNamed<T>(
        context,
        routeName,
        arguments: arguments,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return null;
    }
  }

  // UTILITY METHODS

  /// Check if a route exists
  static bool routeExists(String routeName) {
    return routes.containsKey(routeName) ||
        routeName == audioPlayer ||
        routeName == readingContent ||
        routeName == payment;
  }

  /// Get all available routes
  static List<String> get availableRoutes {
    return [...routes.keys, audioPlayer, readingContent, payment];
  }
}
