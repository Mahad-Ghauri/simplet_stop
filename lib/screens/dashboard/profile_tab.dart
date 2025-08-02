import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/services/localization_service.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/language_selector.dart';
import '../../routes/app_routes.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, LocalizationService>(
      builder: (context, authProvider, localizationService, child) {
        final user = authProvider.currentUser;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, user, localizationService),

                  const SizedBox(height: 24),

                  // Profile Info
                  _buildProfileInfo(context, user, localizationService),

                  const SizedBox(height: 24),

                  // Settings
                  _buildSettings(context, localizationService),

                  const SizedBox(height: 24),

                  // Account Actions
                  _buildAccountActions(context, localizationService),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    user,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.tr('profile.title'),
          style: AppTheme.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your account and preferences',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(
    BuildContext context,
    user,
    LocalizationService localizationService,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: AppTheme.headingLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: AppTheme.headingSmall),
                      Text(
                        user.email,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: user.isPremium
                              ? AppTheme.warningColor.withValues(alpha: 0.1)
                              : AppTheme.textSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.isPremium
                              ? localizationService.tr('profile.premium')
                              : 'Free',
                          style: AppTheme.bodySmall.copyWith(
                            color: user.isPremium
                                ? AppTheme.warningColor
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Edit profile
                  },
                  icon: const Icon(Icons.edit),
                  color: AppTheme.textSecondary,
                ),
              ],
            ),

            if (user.hasQuit) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Quit Date Info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizationService.tr('profile.quit_date'),
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          Helpers.formatDate(user.quitDate!),
                          style: AppTheme.headingSmall,
                        ),
                        Text(
                          '${user.daysSinceQuit} days smoke-free',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettings(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizationService.tr('profile.settings'),
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Column(
            children: [
              _buildSettingItem(
                localizationService.tr('profile.language'),
                'Change app language',
                Icons.language_outlined,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LanguageSelector(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                localizationService.tr('profile.notifications'),
                'Manage notification preferences',
                Icons.notifications_outlined,
                () {
                  // TODO: Notification settings
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                localizationService.tr('profile.privacy'),
                'Manage your privacy settings',
                Icons.privacy_tip_outlined,
                () {
                  // TODO: Privacy settings
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'Data & Storage',
                'Manage your data and storage',
                Icons.storage_outlined,
                () {
                  // TODO: Data settings
                },
              ),
              const Divider(height: 1),
              _buildSettingItem(
                'Help & Support',
                'Get help and contact support',
                Icons.help_outline,
                () {
                  // TODO: Help and support
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildAccountActions(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: AppTheme.headingSmall),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Column(
            children: [
              _buildActionItem(
                localizationService.tr('profile.upgrade_to_premium'),
                'Unlock all features and content',
                Icons.star_outline,
                AppTheme.warningColor,
                () {
                  // TODO: Navigate to payment screen
                },
              ),
              const Divider(height: 1),
              _buildActionItem(
                'Export Data',
                'Download your data',
                Icons.download_outlined,
                AppTheme.primaryColor,
                () {
                  // TODO: Export data
                },
              ),
              const Divider(height: 1),
              _buildActionItem(
                localizationService.tr('profile.logout'),
                'Sign out of your account',
                Icons.logout,
                AppTheme.errorColor,
                () => _showSignOutDialog(context, localizationService),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(
    BuildContext context,
    LocalizationService localizationService,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizationService.tr('profile.logout')),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(localizationService.tr('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: Text(localizationService.tr('profile.logout')),
          ),
        ],
      ),
    );
  }

  void _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (context.mounted) {
      AppRoutes.pushAndRemoveUntil(context, AppRoutes.login);
    }
  }
}
