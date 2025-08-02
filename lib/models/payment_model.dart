import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String stripeSessionId;
  final String status; // 'pending', 'completed', 'failed'
  final double amount;
  final String currency;
  final String productType; // 'premium_access'
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.stripeSessionId,
    required this.status,
    required this.amount,
    this.currency = 'USD',
    this.productType = 'premium_access',
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  // Factory constructor to create PaymentModel from Firestore document
  factory PaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      stripeSessionId: data['stripeSessionId'] ?? '',
      status: data['status'] ?? 'pending',
      amount: (data['amount'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'USD',
      productType: data['productType'] ?? 'premium_access',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
      metadata: data['metadata'],
    );
  }

  // Factory constructor to create PaymentModel from Map
  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      stripeSessionId: map['stripeSessionId'] ?? '',
      status: map['status'] ?? 'pending',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'USD',
      productType: map['productType'] ?? 'premium_access',
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      metadata: map['metadata'],
    );
  }

  // Convert PaymentModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'stripeSessionId': stripeSessionId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'productType': productType,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'metadata': metadata,
    };
  }

  // Convert PaymentModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'stripeSessionId': stripeSessionId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'productType': productType,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  // Copy with method for updating payment data
  PaymentModel copyWith({
    String? id,
    String? userId,
    String? stripeSessionId,
    String? status,
    double? amount,
    String? currency,
    String? productType,
    DateTime? createdAt,
    DateTime? completedAt,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stripeSessionId: stripeSessionId ?? this.stripeSessionId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      productType: productType ?? this.productType,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // Check if payment is pending
  bool get isPending => status == 'pending';

  // Check if payment is completed
  bool get isCompleted => status == 'completed';

  // Check if payment is failed
  bool get isFailed => status == 'failed';

  // Format amount with currency
  String get formattedAmount {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Get status display text
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }

  // Get product display name
  String get productDisplayName {
    switch (productType) {
      case 'premium_access':
        return 'Premium Access';
      default:
        return 'Product';
    }
  }

  @override
  String toString() {
    return 'PaymentModel(id: $id, userId: $userId, status: $status, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentModel &&
        other.id == id &&
        other.userId == userId &&
        other.stripeSessionId == stripeSessionId &&
        other.status == status &&
        other.amount == amount;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        stripeSessionId.hashCode ^
        status.hashCode ^
        amount.hashCode;
  }
}
