// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class PaymentProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService.instance;
  final StorageService _storageService = StorageService.instance;

  List<PaymentModel> _payments = [];
  PaymentModel? _currentPayment;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<PaymentModel> get payments => _payments;
  PaymentModel? get currentPayment => _currentPayment;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasPayments => _payments.isNotEmpty;

  // Payment status checks
  bool get hasActivePayment => _payments.any((payment) => payment.isCompleted);
  PaymentModel? get lastCompletedPayment =>
      _payments.where((payment) => payment.isCompleted).toList().isNotEmpty
      ? _payments.where((payment) => payment.isCompleted).toList().first
      : null;

  // Stream for payment updates
  Stream<List<PaymentModel>> getPaymentsStream(String userId) {
    return _firestoreService.getUserPaymentsStream(userId);
  }

  Future<void> loadUserPayments(String userId) async {
    try {
      _setLoading(true);
      _clearError();

      _payments = await _firestoreService.getUserPayments(userId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load payments: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createPayment({
    required String userId,
    required double amount,
    String currency = 'USD',
    String productType = 'premium_access',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final paymentId = DateTime.now().millisecondsSinceEpoch.toString();
      final stripeSessionId = 'stripe_session_$paymentId';

      final payment = PaymentModel(
        id: paymentId,
        userId: userId,
        stripeSessionId: stripeSessionId,
        status: 'pending',
        amount: amount,
        currency: currency,
        productType: productType,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createPayment(payment);
      _currentPayment = payment;
      _payments.add(payment);

      notifyListeners();
    } catch (e) {
      _setError('Failed to create payment: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> initiateStripeCheckout({
    required String userId,
    required double amount,
    String currency = 'USD',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Create payment record
      await createPayment(userId: userId, amount: amount, currency: currency);

      // Launch Stripe checkout URL
      final checkoutUrl = Uri.parse(AppConstants.stripeCheckoutUrl);
      final canLaunch = await canLaunchUrl(checkoutUrl);

      if (canLaunch) {
        await launchUrl(checkoutUrl, mode: LaunchMode.externalApplication);
        return true;
      } else {
        _setError('Unable to launch payment page');
        return false;
      }
    } catch (e) {
      _setError('Failed to initiate payment: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    DateTime? completedAt,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final updates = <String, dynamic>{'status': status};

      if (completedAt != null) {
        updates['completedAt'] = completedAt;
      }

      await _firestoreService.updatePayment(paymentId, updates);

      // Update local payment
      final paymentIndex = _payments.indexWhere((p) => p.id == paymentId);
      if (paymentIndex != -1) {
        _payments[paymentIndex] = _payments[paymentIndex].copyWith(
          status: status,
          completedAt: completedAt,
        );
      }

      // Update current payment if it's the same
      if (_currentPayment?.id == paymentId) {
        _currentPayment = _currentPayment!.copyWith(
          status: status,
          completedAt: completedAt,
        );
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to update payment status: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markPaymentCompleted(String paymentId) async {
    await updatePaymentStatus(
      paymentId: paymentId,
      status: 'completed',
      completedAt: DateTime.now(),
    );
  }

  Future<void> markPaymentFailed(String paymentId) async {
    await updatePaymentStatus(paymentId: paymentId, status: 'failed');
  }

  Future<void> checkPaymentStatus(String paymentId) async {
    try {
      _setLoading(true);
      _clearError();

      final payment = await _firestoreService.getPayment(paymentId);
      if (payment != null) {
        _currentPayment = payment;

        // Update in local list
        final index = _payments.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _payments[index] = payment;
        } else {
          _payments.add(payment);
        }

        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to check payment status: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshPayments(String userId) async {
    await loadUserPayments(userId);
  }

  PaymentModel? getPaymentById(String paymentId) {
    try {
      return _payments.firstWhere((payment) => payment.id == paymentId);
    } catch (e) {
      return null;
    }
  }

  List<PaymentModel> getPaymentsByStatus(String status) {
    return _payments.where((payment) => payment.status == status).toList();
  }

  List<PaymentModel> getCompletedPayments() {
    return getPaymentsByStatus('completed');
  }

  List<PaymentModel> getPendingPayments() {
    return getPaymentsByStatus('pending');
  }

  List<PaymentModel> getFailedPayments() {
    return getPaymentsByStatus('failed');
  }

  double getTotalSpent() {
    return _payments
        .where((payment) => payment.isCompleted)
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  int getTotalPayments() {
    return _payments.length;
  }

  int getCompletedPaymentsCount() {
    return getCompletedPayments().length;
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

  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }
}
