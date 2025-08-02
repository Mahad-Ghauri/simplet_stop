// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/common/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserPayments();
  }

  void _loadUserPayments() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    final user = authProvider.currentUser;
    if (user != null) {
      paymentProvider.loadUserPayments(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Consumer2<AuthProvider, PaymentProvider>(
          builder: (context, authProvider, paymentProvider, child) {
            final user = authProvider.currentUser;

            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(user),

                  const SizedBox(height: 32),

                  // Premium Features
                  _buildPremiumFeatures(),

                  const SizedBox(height: 32),

                  // Pricing Plans
                  _buildPricingPlans(paymentProvider, user),

                  const SizedBox(height: 32),

                  // Payment History
                  if (paymentProvider.hasPayments)
                    _buildPaymentHistory(paymentProvider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.star, color: AppTheme.warningColor, size: 40),
        ),
        const SizedBox(height: 16),
        Text('Upgrade to Premium', style: AppTheme.headingMedium),
        const SizedBox(height: 8),
        Text(
          user.isPremium
              ? 'You already have premium access!'
              : 'Unlock all features and accelerate your journey',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPremiumFeatures() {
    final features = [
      {
        'title': 'Unlimited Audio Content',
        'description': 'Access all educational and booster content',
        'icon': Icons.headphones,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Advanced Progress Tracking',
        'description': 'Detailed analytics and insights',
        'icon': Icons.analytics,
        'color': AppTheme.secondaryColor,
      },
      {
        'title': 'Personalized Coaching',
        'description': 'AI-powered recommendations',
        'icon': Icons.psychology,
        'color': AppTheme.accentColor,
      },
      {
        'title': 'Priority Support',
        'description': 'Get help when you need it most',
        'icon': Icons.support_agent,
        'color': AppTheme.successColor,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Premium Features', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        color: feature['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feature['title'] as String,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feature['description'] as String,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPricingPlans(PaymentProvider paymentProvider, user) {
    if (user.isPremium) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.successColor),
        ),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor, size: 48),
            const SizedBox(height: 16),
            Text(
              'Premium Active',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have access to all premium features',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Choose Your Plan', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: AppTheme.warningColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Premium Access', style: AppTheme.headingSmall),
                          Text(
                            'Lifetime access to all features',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(
                      '\$29.99',
                      style: AppTheme.headingLarge.copyWith(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'one-time',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Upgrade Now',
                    onPressed: () => _initiatePayment(paymentProvider, user),
                    isLoading: paymentProvider.isLoading,
                    icon: Icons.payment,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Secure payment powered by Stripe',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentHistory(PaymentProvider paymentProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment History', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: paymentProvider.payments.length,
            itemBuilder: (context, index) {
              final payment = paymentProvider.payments[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(
                      payment.status,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPaymentStatusIcon(payment.status),
                    color: _getPaymentStatusColor(payment.status),
                    size: 20,
                  ),
                ),
                title: Text(
                  payment.productDisplayName,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${payment.formattedAmount} • ${payment.statusDisplayText}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                trailing: Text(
                  Helpers.formatDate(payment.createdAt),
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      default:
        return Icons.payment;
    }
  }

  void _initiatePayment(PaymentProvider paymentProvider, user) async {
    final success = await paymentProvider.initiateStripeCheckout(
      userId: user.id,
      amount: 29.99,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Redirecting to payment page...'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else if (mounted && paymentProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(paymentProvider.error!),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
