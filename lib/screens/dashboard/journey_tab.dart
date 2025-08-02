// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';


class JourneyTab extends StatelessWidget {
  const JourneyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProgressProvider>(
      builder: (context, authProvider, progressProvider, child) {
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
                  _buildHeader(context, user),
                  
                  const SizedBox(height: 24),

                  // Quit Date Card
                  if (user.hasQuit) _buildQuitDateCard(context, user),
                  
                  const SizedBox(height: 24),

                  // Milestones
                  _buildMilestones(context, user),
                  
                  const SizedBox(height: 24),

                  // Achievements
                  _buildAchievements(context, progressProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Journey',
          style: AppTheme.headingMedium,
        ),
        const SizedBox(height: 8),
        Text(
          user.hasQuit 
              ? 'Keep going! You\'re doing great!'
              : 'Set your quit date to start tracking your progress',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuitDateCard(BuildContext context, user) {
    return Card(
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
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.flag,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quit Date',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        Helpers.formatDate(user.quitDate!),
                        style: AppTheme.headingSmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.daysSinceQuit}',
                        style: AppTheme.headingLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Days Smoke-Free',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${user.hoursSinceQuit}',
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hours',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestones(BuildContext context, user) {
    final milestones = AppConstants.progressMilestones;
    final currentDays = user.daysSinceQuit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Milestones',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final isAchieved = currentDays >= milestone;
            final isNext = !isAchieved && (index == 0 || currentDays >= milestones[index - 1]);

            return _buildMilestoneItem(
              context,
              milestone,
              isAchieved,
              isNext,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context,
    int days,
    bool isAchieved,
    bool isNext,
  ) {
    return Card(
      elevation: isAchieved ? 2 : 1,
      color: isAchieved 
          ? AppTheme.successColor.withOpacity(0.1)
          : isNext 
              ? AppTheme.primaryColor.withOpacity(0.05)
              : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAchieved 
                    ? AppTheme.successColor
                    : isNext 
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isAchieved ? Icons.check : Icons.flag,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$days Days',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isAchieved 
                          ? AppTheme.successColor
                          : isNext 
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    isAchieved 
                        ? 'Achieved!'
                        : isNext 
                            ? 'Next milestone'
                            : 'Keep going!',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isAchieved)
              const Icon(
                Icons.celebration,
                color: AppTheme.successColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements(BuildContext context, ProgressProvider progressProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                context,
                'First Step',
                'Started your journey',
                Icons.first_page,
                progressProvider.pagesRead > 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                context,
                'Listener',
                'Completed first audio',
                Icons.headphones,
                progressProvider.audiosListened > 0,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildAchievementCard(
                context,
                'Consistent',
                '7 days in a row',
                Icons.calendar_today,
                progressProvider.pagesRead >= 7,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAchievementCard(
                context,
                'Dedicated',
                '30 days smoke-free',
                Icons.emoji_events,
                false, // TODO: Check actual quit date
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    bool isUnlocked,
  ) {
    return Card(
      elevation: isUnlocked ? 2 : 1,
      color: isUnlocked 
          ? AppTheme.successColor.withOpacity(0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: isUnlocked 
                  ? AppTheme.successColor
                  : AppTheme.textSecondary.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isUnlocked 
                    ? AppTheme.successColor
                    : AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 