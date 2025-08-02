// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import '../../utils/theme.dart';
import '../../utils/localization_extension.dart';

import '../../widgets/common/progress_bar.dart';
import '../../routes/app_routes.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProgressProvider>(
      builder: (context, authProvider, progressProvider, child) {
        final user = authProvider.currentUser;
        final progress = progressProvider.progress;

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
                  _buildHeader(context, user),

                  const SizedBox(height: 24),

                  // Progress Cards
                  _buildProgressCards(context, progressProvider),

                  const SizedBox(height: 24),

                  // Reading Progress
                  _buildReadingProgress(context, progressProvider),

                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(context),

                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: AppTheme.headingMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.tr('overview.welcome_back')}, ${user.name}',
                style: AppTheme.headingSmall,
              ),
              Text(
                user.hasQuit
                    ? '${user.daysSinceQuit} ${context.tr('overview.days_smoke_free')}!'
                    : context.tr('overview.ready_to_start'),
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement settings
          },
          icon: const Icon(Icons.settings_outlined),
          color: AppTheme.textSecondary,
        ),
      ],
    );
  }

  Widget _buildProgressCards(
    BuildContext context,
    ProgressProvider progressProvider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('overview.your_progress'),
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                context,
                context.tr('overview.reading_progress'),
                progressProvider.readingProgress,
                '${progressProvider.pagesRead} ${context.tr('overview.pages_read')}',
                Icons.book_outlined,
                AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                context,
                context.tr('overview.audio_progress'),
                progressProvider.audioProgress,
                '${progressProvider.audiosListened} ${context.tr('overview.audios_completed')}',
                Icons.headphones_outlined,
                AppTheme.secondaryColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        _buildProgressCard(
          context,
          context.tr('overview.overall_progress'),
          progressProvider.overallProgress,
          '${(progressProvider.overallProgress * 100).toInt()}% ${context.tr('overview.complete')}',
          Icons.trending_up_outlined,
          AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    String title,
    double progress,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProgressBar(
              progress: progress,
              backgroundColor: color.withOpacity(0.2),
              progressColor: color,
              height: 8,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingProgress(
    BuildContext context,
    ProgressProvider progressProvider,
  ) {
    final pagesRead = progressProvider.pagesRead;
    final totalPages = 9; // Total reading pages
    final progress = pagesRead / totalPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('overview.reading_progress'),
              style: AppTheme.headingSmall,
            ),
            Text(
              '$pagesRead/$totalPages ${context.tr('overview.pages_read')}',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: InkWell(
            onTap: () => AppRoutes.push(context, AppRoutes.readingContent),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('overview.educational_content'),
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              pagesRead >= totalPages
                                  ? context.tr('overview.all_pages_completed')
                                  : context.tr('overview.continue_reading'),
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('overview.quick_actions'),
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                context.tr('overview.craving_timer'),
                context.tr('overview.start_timer_craving'),
                Icons.timer_outlined,
                AppTheme.warningColor,
                () => AppRoutes.push(context, AppRoutes.cravingTimer),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                context.tr('overview.audio_content'),
                context.tr('overview.listen_educational'),
                Icons.headphones_outlined,
                AppTheme.primaryColor,
                () => AppRoutes.push(context, AppRoutes.audioList),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                context.tr('overview.premium_upgrade'),
                context.tr('overview.unlock_features'),
                Icons.star_outlined,
                AppTheme.warningColor,
                () => AppRoutes.push(context, AppRoutes.payment),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                context.tr('overview.test_audio_player'),
                context.tr('overview.test_sample_file'),
                Icons.play_circle_outline,
                AppTheme.successColor,
                () => AppRoutes.push(context, AppRoutes.audioPlayer),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('overview.recent_activity'),
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  context.tr('overview.started_journey'),
                  '2 ${context.tr('overview.days_ago')}',
                  Icons.flag_outlined,
                  AppTheme.successColor,
                ),
                const Divider(),
                _buildActivityItem(
                  context.tr('overview.completed_first_audio'),
                  '1 ${context.tr('overview.day_ago')}',
                  Icons.headphones_outlined,
                  AppTheme.primaryColor,
                ),
                const Divider(),
                _buildActivityItem(
                  '${context.tr('overview.read_pages')} 5',
                  context.tr('overview.today'),
                  Icons.book_outlined,
                  AppTheme.secondaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyMedium),
                Text(
                  time,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
