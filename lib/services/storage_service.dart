import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  // Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Generic methods
  Future<bool> setBool(String key, bool value) async {
    return await _preferences?.setBool(key, value) ?? false;
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _preferences?.getBool(key) ?? defaultValue;
  }

  Future<bool> setString(String key, String value) async {
    return await _preferences?.setString(key, value) ?? false;
  }

  String getString(String key, {String defaultValue = ''}) {
    return _preferences?.getString(key) ?? defaultValue;
  }

  Future<bool> setInt(String key, int value) async {
    return await _preferences?.setInt(key, value) ?? false;
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _preferences?.getInt(key) ?? defaultValue;
  }

  Future<bool> setDouble(String key, double value) async {
    return await _preferences?.setDouble(key, value) ?? false;
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _preferences?.getDouble(key) ?? defaultValue;
  }

  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences?.setStringList(key, value) ?? false;
  }

  List<String> getStringList(
    String key, {
    List<String> defaultValue = const [],
  }) {
    return _preferences?.getStringList(key) ?? defaultValue;
  }

  Future<bool> remove(String key) async {
    return await _preferences?.remove(key) ?? false;
  }

  Future<bool> clear() async {
    return await _preferences?.clear() ?? false;
  }

  bool containsKey(String key) {
    return _preferences?.containsKey(key) ?? false;
  }

  // App-specific methods
  Future<bool> setFirstTime(bool isFirstTime) async {
    return await setBool(AppConstants.isFirstTimeKey, isFirstTime);
  }

  bool isFirstTime() {
    return getBool(AppConstants.isFirstTimeKey, defaultValue: true);
  }

  Future<bool> setUserId(String userId) async {
    return await setString(AppConstants.userIdKey, userId);
  }

  String getUserId() {
    return getString(AppConstants.userIdKey);
  }

  Future<bool> setQuitDate(DateTime quitDate) async {
    return await setString(
      AppConstants.quitDateKey,
      quitDate.toIso8601String(),
    );
  }

  DateTime? getQuitDate() {
    final quitDateString = getString(AppConstants.quitDateKey);
    if (quitDateString.isEmpty) return null;
    try {
      return DateTime.parse(quitDateString);
    } catch (e) {
      return null;
    }
  }

  Future<bool> setPremiumStatus(bool isPremium) async {
    return await setBool(AppConstants.isPremiumKey, isPremium);
  }

  bool isPremium() {
    return getBool(AppConstants.isPremiumKey, defaultValue: false);
  }

  // Audio progress methods
  Future<bool> setAudioProgress(String audioId, double progress) async {
    return await setDouble('audio_progress_$audioId', progress);
  }

  double getAudioProgress(String audioId) {
    return getDouble('audio_progress_$audioId', defaultValue: 0.0);
  }

  Future<bool> setAudioCompleted(String audioId, bool completed) async {
    return await setBool('audio_completed_$audioId', completed);
  }

  bool isAudioCompleted(String audioId) {
    return getBool('audio_completed_$audioId', defaultValue: false);
  }

  // Completed audio IDs
  Future<bool> addCompletedAudio(String audioId) async {
    final completedAudios = getCompletedAudios();
    if (!completedAudios.contains(audioId)) {
      completedAudios.add(audioId);
      return await setStringList('completed_audios', completedAudios);
    }
    return true;
  }

  List<String> getCompletedAudios() {
    return getStringList('completed_audios', defaultValue: []);
  }

  // Unlocked audio IDs
  Future<bool> addUnlockedAudio(String audioId) async {
    final unlockedAudios = getUnlockedAudios();
    if (!unlockedAudios.contains(audioId)) {
      unlockedAudios.add(audioId);
      return await setStringList('unlocked_audios', unlockedAudios);
    }
    return true;
  }

  List<String> getUnlockedAudios() {
    return getStringList('unlocked_audios', defaultValue: []);
  }

  // Pages read
  Future<bool> setPagesRead(int pagesRead) async {
    return await setInt('pages_read', pagesRead);
  }

  int getPagesRead() {
    return getInt('pages_read', defaultValue: 0);
  }

  Future<bool> incrementPagesRead() async {
    final currentPages = getPagesRead();
    return await setPagesRead(currentPages + 1);
  }

  // Last craving timer
  Future<bool> setLastCravingTimer(DateTime dateTime) async {
    return await setString('last_craving_timer', dateTime.toIso8601String());
  }

  DateTime? getLastCravingTimer() {
    final dateTimeString = getString('last_craving_timer');
    if (dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  // App settings
  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool('notifications_enabled', enabled);
  }

  bool areNotificationsEnabled() {
    return getBool('notifications_enabled', defaultValue: true);
  }

  Future<bool> setSoundEnabled(bool enabled) async {
    return await setBool('sound_enabled', enabled);
  }

  bool isSoundEnabled() {
    return getBool('sound_enabled', defaultValue: true);
  }

  Future<bool> setDarkModeEnabled(bool enabled) async {
    return await setBool('dark_mode_enabled', enabled);
  }

  bool isDarkModeEnabled() {
    return getBool('dark_mode_enabled', defaultValue: false);
  }

  // Clear user data on logout
  Future<bool> clearUserData() async {
    final keysToRemove = [
      AppConstants.userIdKey,
      AppConstants.quitDateKey,
      AppConstants.isPremiumKey,
      'completed_audios',
      'unlocked_audios',
      'pages_read',
      'last_craving_timer',
    ];

    bool success = true;
    for (final key in keysToRemove) {
      final result = await remove(key);
      if (!result) success = false;
    }

    // Also remove audio progress data
    final allKeys = _preferences?.getKeys() ?? <String>{};
    for (final key in allKeys) {
      if (key.startsWith('audio_progress_') ||
          key.startsWith('audio_completed_')) {
        final result = await remove(key);
        if (!result) success = false;
      }
    }

    return success;
  }
}
