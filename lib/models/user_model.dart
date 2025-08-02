import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final DateTime? quitDate;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.quitDate,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.preferences,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      quitDate: data['quitDate'] != null
          ? (data['quitDate'] as Timestamp).toDate()
          : null,
      isPremium: data['isPremium'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      profileImageUrl: data['profileImageUrl'],
      preferences: data['preferences'],
    );
  }

  // Factory constructor to create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      quitDate: map['quitDate'] != null
          ? DateTime.parse(map['quitDate'])
          : null,
      isPremium: map['isPremium'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      profileImageUrl: map['profileImageUrl'],
      preferences: map['preferences'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'quitDate': quitDate != null ? Timestamp.fromDate(quitDate!) : null,
      'isPremium': isPremium,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
    };
  }

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'quitDate': quitDate?.toIso8601String(),
      'isPremium': isPremium,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'profileImageUrl': profileImageUrl,
      'preferences': preferences,
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    DateTime? quitDate,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      quitDate: quitDate ?? this.quitDate,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
    );
  }

  // Calculate days since quit
  int get daysSinceQuit {
    if (quitDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(quitDate!);
    return difference.inDays;
  }

  // Calculate hours since quit
  int get hoursSinceQuit {
    if (quitDate == null) return 0;
    final now = DateTime.now();
    final difference = now.difference(quitDate!);
    return difference.inHours;
  }

  // Check if user has quit smoking
  bool get hasQuit => quitDate != null;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, quitDate: $quitDate, isPremium: $isPremium)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.quitDate == quitDate &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        name.hashCode ^
        quitDate.hashCode ^
        isPremium.hashCode;
  }
}
