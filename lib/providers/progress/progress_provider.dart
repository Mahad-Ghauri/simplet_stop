import 'package:flutter/material.dart';
import '../../models/progress_model.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class ProgressProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;

  ProgressModel? _progress;
  bool _isLoading = false;
  String? _error;

  // Getters
  ProgressModel? get progress => _progress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProgress => _progress != null;

  // Progress calculations
  double get readingProgress => _progress?.readingProgress ?? 0.0;
  double get audioProgress => _progress?.audioProgress ?? 0.0;
  double get overallProgress => _progress?.overallProgress ?? 0.0;
  int get pagesRead => _progress?.pagesRead ?? 0;
  int get audiosListened => _progress?.audiosListened ?? 0;
  int get nextUnlockThreshold => _progress?.nextUnlockThreshold ?? 1;

  // Stream for progress updates
  Stream<ProgressModel?> getProgressStream(String userId) {
    return _firestoreService.getProgressStream(userId);
  }

  Future<void> loadProgress(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _progress = await _firestoreService.getProgress(userId);

      // If no progress exists, create initial progress
      if (_progress == null) {
        await createInitialProgress(userId);
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load progress: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createInitialProgress(String userId) async {
    try {
      final progressId = DateTime.now().millisecondsSinceEpoch.toString();
      final progress = ProgressModel(
        id: progressId,
        userId: userId,
        lastUpdated: DateTime.now(),
      );

      await _firestoreService.createProgress(progress);
      _progress = progress;
      notifyListeners();
    } catch (e) {
      _setError('Failed to create initial progress: ${e.toString()}');
    }
  }

  Future<void> incrementPagesRead(String userId) async {
    if (_progress == null) {
      await loadProgress(userId);
    }

    try {
      _setLoading(true);
      _clearError();

      final newPagesRead = (_progress?.pagesRead ?? 0) + 1;
      final newUnlockedAudios = _getNewUnlockedAudios(newPagesRead);

      final updates = <String, dynamic>{
        'pagesRead': newPagesRead,
        'unlockedAudioIds': newUnlockedAudios,
      };

      await _firestoreService.updateProgress(userId, updates);

      // Update local progress
      _progress = _progress?.copyWith(
        pagesRead: newPagesRead,
        unlockedAudioIds: newUnlockedAudios,
        lastUpdated: DateTime.now(),
      );

      // Update local storage
      await _storageService.setPagesRead(newPagesRead);

      notifyListeners();
    } catch (e) {
      _setError('Failed to update pages read: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAudioCompleted(String userId, String audioId) async {
    if (_progress == null) {
      await loadProgress(userId);
    }

    try {
      _setLoading(true);
      _clearError();

      final completedAudios = List<String>.from(
        _progress?.completedAudioIds ?? [],
      );
      if (!completedAudios.contains(audioId)) {
        completedAudios.add(audioId);
      }

      final newAudiosListened = completedAudios.length;

      final updates = <String, dynamic>{
        'audiosListened': newAudiosListened,
        'completedAudioIds': completedAudios,
      };

      await _firestoreService.updateProgress(userId, updates);

      // Update local progress
      _progress = _progress?.copyWith(
        audiosListened: newAudiosListened,
        completedAudioIds: completedAudios,
        lastUpdated: DateTime.now(),
      );

      // Update local storage
      await _storageService.addCompletedAudio(audioId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to mark audio completed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> unlockAudio(String userId, String audioId) async {
    if (_progress == null) {
      await loadProgress(userId);
    }

    try {
      _setLoading(true);
      _clearError();

      final unlockedAudios = List<String>.from(
        _progress?.unlockedAudioIds ?? [],
      );
      if (!unlockedAudios.contains(audioId)) {
        unlockedAudios.add(audioId);
      }

      final updates = <String, dynamic>{'unlockedAudioIds': unlockedAudios};

      await _firestoreService.updateProgress(userId, updates);

      // Update local progress
      _progress = _progress?.copyWith(
        unlockedAudioIds: unlockedAudios,
        lastUpdated: DateTime.now(),
      );

      // Update local storage
      await _storageService.addUnlockedAudio(audioId);

      notifyListeners();
    } catch (e) {
      _setError('Failed to unlock audio: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  bool isAudioUnlocked(String audioId) {
    return _progress?.isAudioUnlocked(audioId) ?? false;
  }

  bool isAudioCompleted(String audioId) {
    return _progress?.isAudioCompleted(audioId) ?? false;
  }

  List<String> _getNewUnlockedAudios(int pagesRead) {
    final currentUnlocked = List<String>.from(
      _progress?.unlockedAudioIds ?? [],
    );

    // This would typically check against audio content unlock thresholds
    // For now, we'll use a simple threshold system
    const thresholds = [1, 3, 5, 10, 15, 20, 25, 30];

    for (final threshold in thresholds) {
      if (pagesRead >= threshold) {
        final audioId = 'audio_$threshold';
        if (!currentUnlocked.contains(audioId)) {
          currentUnlocked.add(audioId);
        }
      }
    }

    return currentUnlocked;
  }

  Future<void> updateMilestone(
    String userId,
    String milestoneKey,
    bool achieved,
  ) async {
    if (_progress == null) {
      await loadProgress(userId);
    }

    try {
      _setLoading(true);
      _clearError();

      final milestones = Map<String, dynamic>.from(_progress?.milestones ?? {});
      milestones[milestoneKey] = achieved;

      final updates = <String, dynamic>{'milestones': milestones};

      await _firestoreService.updateProgress(userId, updates);

      // Update local progress
      _progress = _progress?.copyWith(
        milestones: milestones,
        lastUpdated: DateTime.now(),
      );

      notifyListeners();
    } catch (e) {
      _setError('Failed to update milestone: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
