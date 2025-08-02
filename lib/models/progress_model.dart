import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressModel {
  final String id;
  final String userId;
  final int pagesRead;
  final int totalPages;
  final int audiosListened;
  final int totalAudios;
  final List<String> completedAudioIds;
  final List<String> unlockedAudioIds;
  final DateTime lastUpdated;
  final Map<String, dynamic>? milestones;

  ProgressModel({
    required this.id,
    required this.userId,
    this.pagesRead = 0,
    this.totalPages = 0,
    this.audiosListened = 0,
    this.totalAudios = 0,
    this.completedAudioIds = const [],
    this.unlockedAudioIds = const [],
    required this.lastUpdated,
    this.milestones,
  });

  // Factory constructor to create ProgressModel from Firestore document
  factory ProgressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      pagesRead: data['pagesRead'] ?? 0,
      totalPages: data['totalPages'] ?? 0,
      audiosListened: data['audiosListened'] ?? 0,
      totalAudios: data['totalAudios'] ?? 0,
      completedAudioIds: List<String>.from(data['completedAudioIds'] ?? []),
      unlockedAudioIds: List<String>.from(data['unlockedAudioIds'] ?? []),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      milestones: data['milestones'],
    );
  }

  // Factory constructor to create ProgressModel from Map
  factory ProgressModel.fromMap(Map<String, dynamic> map) {
    return ProgressModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      pagesRead: map['pagesRead'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      audiosListened: map['audiosListened'] ?? 0,
      totalAudios: map['totalAudios'] ?? 0,
      completedAudioIds: List<String>.from(map['completedAudioIds'] ?? []),
      unlockedAudioIds: List<String>.from(map['unlockedAudioIds'] ?? []),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      milestones: map['milestones'],
    );
  }

  // Convert ProgressModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pagesRead': pagesRead,
      'totalPages': totalPages,
      'audiosListened': audiosListened,
      'totalAudios': totalAudios,
      'completedAudioIds': completedAudioIds,
      'unlockedAudioIds': unlockedAudioIds,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'milestones': milestones,
    };
  }

  // Convert ProgressModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'pagesRead': pagesRead,
      'totalPages': totalPages,
      'audiosListened': audiosListened,
      'totalAudios': totalAudios,
      'completedAudioIds': completedAudioIds,
      'unlockedAudioIds': unlockedAudioIds,
      'lastUpdated': lastUpdated.toIso8601String(),
      'milestones': milestones,
    };
  }

  // Copy with method for updating progress data
  ProgressModel copyWith({
    String? id,
    String? userId,
    int? pagesRead,
    int? totalPages,
    int? audiosListened,
    int? totalAudios,
    List<String>? completedAudioIds,
    List<String>? unlockedAudioIds,
    DateTime? lastUpdated,
    Map<String, dynamic>? milestones,
  }) {
    return ProgressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pagesRead: pagesRead ?? this.pagesRead,
      totalPages: totalPages ?? this.totalPages,
      audiosListened: audiosListened ?? this.audiosListened,
      totalAudios: totalAudios ?? this.totalAudios,
      completedAudioIds: completedAudioIds ?? this.completedAudioIds,
      unlockedAudioIds: unlockedAudioIds ?? this.unlockedAudioIds,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      milestones: milestones ?? this.milestones,
    );
  }

  // Calculate reading progress percentage
  double get readingProgress {
    if (totalPages == 0) return 0.0;
    return (pagesRead / totalPages).clamp(0.0, 1.0);
  }

  // Calculate audio progress percentage
  double get audioProgress {
    if (totalAudios == 0) return 0.0;
    return (audiosListened / totalAudios).clamp(0.0, 1.0);
  }

  // Calculate overall progress percentage
  double get overallProgress {
    final readingWeight = 0.4;
    final audioWeight = 0.6;
    return (readingProgress * readingWeight) + (audioProgress * audioWeight);
  }

  // Check if audio is completed
  bool isAudioCompleted(String audioId) {
    return completedAudioIds.contains(audioId);
  }

  // Check if audio is unlocked
  bool isAudioUnlocked(String audioId) {
    return unlockedAudioIds.contains(audioId);
  }

  // Get next unlockable audio count
  int get nextUnlockThreshold {
    const thresholds = [1, 3, 5, 10, 15, 20, 25, 30];
    for (final threshold in thresholds) {
      if (pagesRead < threshold) {
        return threshold;
      }
    }
    return pagesRead + 5; // Default next threshold
  }

  // Check if milestone is achieved
  bool isMilestoneAchieved(String milestoneKey) {
    return milestones?[milestoneKey] == true;
  }

  @override
  String toString() {
    return 'ProgressModel(id: $id, userId: $userId, pagesRead: $pagesRead, audiosListened: $audiosListened)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProgressModel &&
        other.id == id &&
        other.userId == userId &&
        other.pagesRead == pagesRead &&
        other.audiosListened == audiosListened;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        pagesRead.hashCode ^
        audiosListened.hashCode;
  }
}
