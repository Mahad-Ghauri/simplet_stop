// lib/providers/audio/audio_provider.dart
// ignore_for_file: unused_import

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:simplet_stop/models/audio_content_model.dart';
import 'package:simplet_stop/screens/audio/audio_list_screen.dart'
    hide AudioContent;
import '../../services/firestore_service.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  AudioContent? _currentAudio;
  String? _errorMessage;
  PlayerState _playerState = PlayerState.stopped;

  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get duration => _duration;
  Duration get position => _position;
  double get volume => _volume;
  AudioContent? get currentAudio => _currentAudio;
  String? get currentSong => _currentAudio?.title;
  String? get errorMessage => _errorMessage;
  PlayerState get playerState => _playerState;
  double get progress => _duration.inMilliseconds > 0
      ? _position.inMilliseconds / _duration.inMilliseconds
      : 0.0;

  AudioPlayerProvider() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _playerState = state;
      _isPlaying = state == PlayerState.playing;

      // Only show loading if we're trying to play but haven't started yet
      if (state == PlayerState.playing && _position == Duration.zero) {
        _isLoading = false; // Audio started playing
      } else if (state == PlayerState.paused || state == PlayerState.stopped) {
        _isLoading = false;
      }

      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _duration = duration;
      _isLoading = false; // Duration received means audio is loaded
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      _position = position;
      if (_isLoading) {
        _isLoading = false; // Position updates mean audio is playing
      }
      notifyListeners();
    });

    // Listen to player completion
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _position = Duration.zero;
      _playerState = PlayerState.completed;
      _isLoading = false;
      notifyListeners();
    });

    // Listen to errors
    _audioPlayer.onLog.listen((String message) {
      debugPrint('AudioPlayer Log: $message');
    });
  }

  // Helper method to get the correct asset path
  String _getAssetPath(String audioUrl) {
    // Remove 'assets/' prefix if present for AssetSource
    if (audioUrl.startsWith('assets/')) {
      return audioUrl.substring(7); // Remove 'assets/' prefix
    }
    return audioUrl;
  }

  // Helper method to check if running on web
  bool get _isWeb => kIsWeb;

  // Main method to play AudioContent from Firestore
  Future<void> playAudioContent(AudioContent audio) async {
    try {
      _currentAudio = audio;
      _setLoading(true);
      _clearError();

      debugPrint('Playing audio: ${audio.title} from ${audio.audioUrl}');
      debugPrint('Source type: ${audio.sourceType}');

      // Use the sourceType from the model to determine how to play
      switch (audio.sourceType) {
        case AudioSourceType.url:
          debugPrint('Playing from URL: ${audio.audioUrl}');
          await _audioPlayer.play(UrlSource(audio.audioUrl));
          break;
        case AudioSourceType.asset:
          final assetPath = _getAssetPath(audio.audioUrl);
          debugPrint(
            'Playing from asset: $assetPath (original: ${audio.audioUrl})',
          );
          await _audioPlayer.play(AssetSource(assetPath));
          break;
        case AudioSourceType.file:
          debugPrint('Playing from file: ${audio.audioUrl}');
          await _audioPlayer.play(DeviceFileSource(audio.audioUrl));
          break;
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to play audio: ${audio.title}');
      debugPrint('Error playing audio: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  // Play audio by ID from Firestore
  Future<void> playAudioById(String audioId) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Loading audio with ID: $audioId');
      final audioContent = await FirestoreService.instance.getAudioContentById(
        audioId,
      );

      if (audioContent != null) {
        await playAudioContent(audioContent);
      } else {
        _setError('Audio not found in database');
        debugPrint('Audio not found for ID: $audioId');
      }
    } catch (e) {
      _setError('Failed to load audio from database');
      debugPrint('Error loading audio by ID: $e');
    }
  }

  // Backward compatibility methods for direct source playing
  Future<void> playFromAsset(String assetPath) async {
    try {
      _setLoading(true);
      _clearError();
      _currentAudio = null; // Clear current audio as this is direct play

      final cleanAssetPath = _getAssetPath(assetPath);
      debugPrint('Playing from asset: $cleanAssetPath (original: $assetPath)');
      debugPrint('Is Web: ${kIsWeb}');

      // For web, we need to handle assets differently
      if (kIsWeb) {
        // On web, assets are served from the assets/ directory
        await _audioPlayer.play(AssetSource(cleanAssetPath));
      } else {
        await _audioPlayer.play(AssetSource(cleanAssetPath));
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to play asset: ${e.toString()}');
      debugPrint('Error playing asset: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> playFromUrl(String url) async {
    try {
      _setLoading(true);
      _clearError();
      _currentAudio = null; // Clear current audio as this is direct play

      debugPrint('Playing from URL: $url');
      await _audioPlayer.play(UrlSource(url));
      notifyListeners();
    } catch (e) {
      _setError('Failed to play from URL');
      debugPrint('Error playing URL: $e');
    }
  }

  Future<void> playFromFile(String filePath) async {
    try {
      _setLoading(true);
      _clearError();
      _currentAudio = null; // Clear current audio as this is direct play

      debugPrint('Playing from file: $filePath');
      await _audioPlayer.play(DeviceFileSource(filePath));
      notifyListeners();
    } catch (e) {
      _setError('Failed to play file');
      debugPrint('Error playing file: $e');
    }
  }

  // Playback controls
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _setError('Failed to pause audio');
      debugPrint('Error pausing: $e');
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      _setError('Failed to resume audio');
      debugPrint('Error resuming: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _position = Duration.zero;
      _isPlaying = false;
      _isLoading = false;
      _playerState = PlayerState.stopped;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop audio');
      debugPrint('Error stopping: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _setError('Failed to seek');
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set volume');
      debugPrint('Error setting volume: $e');
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  // Get current audio info for display
  String get currentAudioInfo {
    if (_currentAudio != null) {
      return _currentAudio!.title;
    }
    return 'No audio playing';
  }

  String get currentAudioDescription {
    if (_currentAudio != null) {
      return _currentAudio!.description;
    }
    return '';
  }

  String? get currentAudioThumbnail {
    return _currentAudio?.thumbnailUrl;
  }

  // Check if audio is from Firestore
  bool get isFirestoreAudio => _currentAudio != null;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
