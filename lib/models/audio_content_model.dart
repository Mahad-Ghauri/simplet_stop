// lib/models/audio_content_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AudioSourceType { asset, url, file }

class AudioContent {
  final String id;
  final String title;
  final String description;
  final String type;
  final String audioUrl;
  final String? thumbnailUrl;
  final Duration duration;
  final bool isPremium;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  AudioContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.audioUrl,
    this.thumbnailUrl,
    required this.duration,
    required this.isPremium,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  // Determine source type based on the audioUrl
  AudioSourceType get sourceType {
    if (audioUrl.startsWith('assets/') ||
        audioUrl.startsWith('audio/') ||
        (!audioUrl.startsWith('http') &&
            !audioUrl.startsWith('/') &&
            !audioUrl.contains('://'))) {
      return AudioSourceType.asset;
    } else if (audioUrl.startsWith('http://') ||
        audioUrl.startsWith('https://')) {
      return AudioSourceType.url;
    } else if (audioUrl.startsWith('/')) {
      return AudioSourceType.file;
    } else {
      // Default to asset for relative paths
      return AudioSourceType.asset;
    }
  }

  // Create from Firestore document
  factory AudioContent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AudioContent._fromMap(data, id: doc.id);
  }

  // Create from Map (for JSON/Map deserialization)
  factory AudioContent.fromMap(Map<String, dynamic> map) {
    return AudioContent._fromMap(map, id: map['id'] ?? '');
  }

  // Internal method to handle map deserialization
  factory AudioContent._fromMap(Map<String, dynamic> map, {required String id}) {
    return AudioContent(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      audioUrl: map['audioUrl'] ?? map['audio_url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? map['thumbnail_url'],
      duration: map['duration'] is int 
          ? Duration(milliseconds: map['duration'] as int)
          : _parseDuration(map['duration']),
      isPremium: map['isPremium'] ?? map['is_premium'] ?? false,
      isActive: map['isActive'] ?? map['is_active'] ?? true,
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : map['updatedAt'] is DateTime
              ? map['updatedAt'] as DateTime
              : DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'audioUrl': audioUrl,
      'thumbnailUrl': thumbnailUrl,
      'duration': duration.inMilliseconds,
      'isPremium': isPremium,
      'isActive': isActive,
      'order': order,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper method to parse duration from Firestore
  static Duration _parseDuration(dynamic durationData) {
    if (durationData is int) {
      return Duration(milliseconds: durationData);
    } else if (durationData is Map<String, dynamic>) {
      // Handle legacy format if needed
      final minutes = durationData['minutes'] ?? 0;
      final seconds = durationData['seconds'] ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }

  // Copy with method for updates
  AudioContent copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? audioUrl,
    String? thumbnailUrl,
    Duration? duration,
    bool? isPremium,
    bool? isActive,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AudioContent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      audioUrl: audioUrl ?? this.audioUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      isPremium: isPremium ?? this.isPremium,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AudioContent(id: $id, title: $title, audioUrl: $audioUrl, sourceType: $sourceType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioContent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
