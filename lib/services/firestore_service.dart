// lib/services/firestore_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user_model.dart';
import '../models/audio_content_model.dart';
import '../models/progress_model.dart';
import '../models/payment_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  static FirestoreService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirestoreService._internal();

  static FirestoreService get instance {
    _instance ??= FirestoreService._internal();
    return _instance!;
  }

  // User operations
  Future<void> createUser(UserModel user) async {
    try {
      debugPrint('Creating user: ${user.id}');
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
    } catch (e) {
      debugPrint('Error creating user: $e');
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  Future<UserModel?> getUser(String userId) async {
    try {
      debugPrint('Getting user: $userId');
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting user: $e');
      throw Exception('Failed to get user: ${e.toString()}');
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      debugPrint('Error updating user: $e');
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      // Delete user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();

      // Delete related progress data
      await deleteUserProgress(userId);

      // Delete related payment data
      await deleteUserPayments(userId);
    } catch (e) {
      debugPrint('Error deleting user: $e');
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // Progress operations
  Future<void> createProgress(ProgressModel progress) async {
    try {
      await _firestore
          .collection(AppConstants.progressCollection)
          .doc(progress.id)
          .set(progress.toFirestore());
    } catch (e) {
      debugPrint('Error creating progress: $e');
      throw Exception('Failed to create progress: ${e.toString()}');
    }
  }

  Future<ProgressModel?> getProgress(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.progressCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return ProgressModel.fromFirestore(query.docs.first);
      }
    } catch (e) {
      debugPrint('Error getting progress: $e');
      throw Exception('Failed to get progress: ${e.toString()}');
    }
    return null;
  }

  Future<void> updateProgress(String userId, Map<String, dynamic> data) async {
    try {
      data['lastUpdated'] = Timestamp.now();

      final query = await _firestore
          .collection(AppConstants.progressCollection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(data);
      } else {
        // Create new progress document if it doesn't exist
        final progressId = _firestore
            .collection(AppConstants.progressCollection)
            .doc()
            .id;
        final progress = ProgressModel(
          id: progressId,
          userId: userId,
          lastUpdated: DateTime.now(),
        );
        await createProgress(
          progress.copyWith(
            pagesRead: data['pagesRead'],
            totalPages: data['totalPages'],
            audiosListened: data['audiosListened'],
            totalAudios: data['totalAudios'],
            completedAudioIds: data['completedAudioIds'],
            unlockedAudioIds: data['unlockedAudioIds'],
            milestones: data['milestones'],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating progress: $e');
      throw Exception('Failed to update progress: ${e.toString()}');
    }
  }

  Future<void> deleteUserProgress(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.progressCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user progress: $e');
      throw Exception('Failed to delete user progress: ${e.toString()}');
    }
  }

  Stream<ProgressModel?> getProgressStream(String userId) {
    return _firestore
        .collection(AppConstants.progressCollection)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map(
          (query) => query.docs.isNotEmpty
              ? ProgressModel.fromFirestore(query.docs.first)
              : null,
        );
  }

  // Audio content operations - ENHANCED FOR BETTER DEBUGGING
  Future<List<AudioContent>> getAudioContent({
    String? type,
    bool? isPremium,
    bool activeOnly = true,
  }) async {
    try {
      debugPrint(
        'Getting audio content - type: $type, isPremium: $isPremium, activeOnly: $activeOnly',
      );

      Query query = _firestore.collection(AppConstants.audioContentCollection);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (isPremium != null) {
        query = query.where('isPremium', isEqualTo: isPremium);
      }

      if (activeOnly) {
        query = query.where('isActive', isEqualTo: true);
      }

      query = query.orderBy('order');

      final querySnapshot = await query.get();
      final audioList = querySnapshot.docs
          .map((doc) => AudioContent.fromFirestore(doc))
          .toList();

      debugPrint('Found ${audioList.length} audio content items');
      return audioList;
    } catch (e) {
      debugPrint('Error getting audio content: $e');
      throw Exception('Failed to get audio content: ${e.toString()}');
    }
  }

  Future<AudioContent?> getAudioContentById(String audioId) async {
    try {
      debugPrint('Getting audio content by ID: $audioId');

      final doc = await _firestore
          .collection(AppConstants.audioContentCollection)
          .doc(audioId)
          .get();

      if (doc.exists) {
        final audioContent = AudioContent.fromFirestore(doc);
        debugPrint(
          'Found audio: ${audioContent.title} - ${audioContent.audioUrl}',
        );
        return audioContent;
      } else {
        debugPrint('Audio content not found for ID: $audioId');
      }
    } catch (e) {
      debugPrint('Error getting audio content by ID: $e');
      throw Exception('Failed to get audio content: ${e.toString()}');
    }
    return null;
  }

  Stream<List<AudioContent>> getAudioContentStream({
    String? type,
    bool? isPremium,
    bool activeOnly = true,
  }) {
    Query query = _firestore.collection(AppConstants.audioContentCollection);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (isPremium != null) {
      query = query.where('isPremium', isEqualTo: isPremium);
    }

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    query = query.orderBy('order');

    return query.snapshots().map(
      (querySnapshot) => querySnapshot.docs
          .map((doc) => AudioContent.fromFirestore(doc))
          .toList(),
    );
  }

  // Create audio content (for admin use)
  Future<void> createAudioContent(AudioContent audioContent) async {
    try {
      debugPrint('Creating audio content: ${audioContent.title}');
      await _firestore
          .collection(AppConstants.audioContentCollection)
          .doc(audioContent.id)
          .set(audioContent.toFirestore());
      debugPrint('Audio content created successfully');
    } catch (e) {
      debugPrint('Error creating audio content: $e');
      throw Exception('Failed to create audio content: ${e.toString()}');
    }
  }

  // Add sample audio content to database
  Future<void> addSampleAudioContent() async {
    try {
      debugPrint('Adding sample audio content to database');
      
      // Verify the audio file exists in the assets
      final audioPath = 'assets/audio/sample.mp3';
      
      // Check if the asset exists using Flutter's asset bundle
      try {
        await rootBundle.load(audioPath);
      } catch (e) {
        debugPrint('Error loading audio file: $e');
        throw Exception('Audio file not found at $audioPath. Please make sure the file exists in the assets/audio/ directory and is declared in pubspec.yaml');
      }
      
      final sampleAudio = AudioContent(
        id: 'sample_audio_001',
        title: 'Sample Audio Test',
        description: 'A test audio file for demonstration purposes',
        type: 'test',
        audioUrl: audioPath, // This will be correctly handled by the AudioContent.sourceType getter
        duration: const Duration(minutes: 2, seconds: 30), // Approximate duration
        isPremium: false,
        isActive: true,
        order: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await createAudioContent(sampleAudio);
      debugPrint('Sample audio content added successfully');
    } on Exception catch (e) {
      debugPrint('Error adding sample audio content: $e');
      rethrow; // Re-throw to preserve the original error
    } catch (e) {
      debugPrint('Unexpected error adding sample audio content: $e');
      throw Exception('Failed to add sample audio content: ${e.toString()}');
    }
  }

  Future<void> updateAudioContent(
    String audioId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _firestore
          .collection(AppConstants.audioContentCollection)
          .doc(audioId)
          .update(data);
    } catch (e) {
      debugPrint('Error updating audio content: $e');
      throw Exception('Failed to update audio content: ${e.toString()}');
    }
  }

  Future<void> deleteAudioContent(String audioId) async {
    try {
      await _firestore
          .collection(AppConstants.audioContentCollection)
          .doc(audioId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting audio content: $e');
      throw Exception('Failed to delete audio content: ${e.toString()}');
    }
  }

  // Payment operations
  Future<void> createPayment(PaymentModel payment) async {
    try {
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(payment.id)
          .set(payment.toFirestore());
    } catch (e) {
      debugPrint('Error creating payment: $e');
      throw Exception('Failed to create payment: ${e.toString()}');
    }
  }

  Future<PaymentModel?> getPayment(String paymentId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .get();

      if (doc.exists) {
        return PaymentModel.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint('Error getting payment: $e');
      throw Exception('Failed to get payment: ${e.toString()}');
    }
    return null;
  }

  Future<List<PaymentModel>> getUserPayments(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => PaymentModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error getting user payments: $e');
      throw Exception('Failed to get user payments: ${e.toString()}');
    }
  }

  Future<void> updatePayment(
    String paymentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.paymentsCollection)
          .doc(paymentId)
          .update(data);
    } catch (e) {
      debugPrint('Error updating payment: $e');
      throw Exception('Failed to update payment: ${e.toString()}');
    }
  }

  Future<void> deleteUserPayments(String userId) async {
    try {
      final query = await _firestore
          .collection(AppConstants.paymentsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting user payments: $e');
      throw Exception('Failed to delete user payments: ${e.toString()}');
    }
  }

  Stream<List<PaymentModel>> getUserPaymentsStream(String userId) {
    return _firestore
        .collection(AppConstants.paymentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => PaymentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // Utility methods
  Future<bool> documentExists(String collection, String documentId) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking document existence: $e');
      return false;
    }
  }

  Future<int> getCollectionCount(String collection) async {
    try {
      final query = await _firestore.collection(collection).count().get();
      return query.count ?? 0;
    } catch (e) {
      debugPrint('Error getting collection count: $e');
      return 0;
    }
  }

  // Batch operations
  WriteBatch batch() {
    return _firestore.batch();
  }

  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      debugPrint('Error committing batch: $e');
      throw Exception('Failed to commit batch: ${e.toString()}');
    }
  }
}
