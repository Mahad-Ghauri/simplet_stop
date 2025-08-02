class AppConstants {
  // App Info
  static const String appName = 'SimpeltStop';
  static const String appVersion = '1.0.0';

  // SharedPreferences Keys
  static const String isFirstTimeKey = 'is_first_time';
  static const String userIdKey = 'user_id';
  static const String quitDateKey = 'quit_date';
  static const String isPremiumKey = 'is_premium';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String progressCollection = 'progress';
  static const String audioContentCollection = 'audio_content';
  static const String paymentsCollection = 'payments';

  // Audio Content Types
  static const String audioTypeEducational = 'educational';
  static const String audioTypeBooster = 'booster';
  static const String audioTypeCalming = 'calming';

  // Payment Status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';

  // Craving Timer Duration (in minutes)
  static const int cravingTimerDuration = 5;

  // Progress Milestones
  static const List<int> progressMilestones = [
    1,
    3,
    7,
    14,
    30,
    60,
    90,
    180,
    365,
  ];

  // Stripe Configuration
  static const String stripePublishableKey = 'pk_test_your_stripe_key_here';
  static const String stripeCheckoutUrl =
      'https://your-stripe-checkout-url.com';
}
