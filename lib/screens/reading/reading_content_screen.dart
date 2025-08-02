// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import '../../utils/theme.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/app_routes.dart';

class ReadingContentScreen extends StatefulWidget {
  const ReadingContentScreen({super.key});

  @override
  State<ReadingContentScreen> createState() => _ReadingContentScreenState();
}

class _ReadingContentScreenState extends State<ReadingContentScreen> {
  int _currentPageIndex = 0;
  final PageController _pageController = PageController();

  final List<ReadingPage> _pages = ReadingPage.pages;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await progressProvider.loadProgress(authProvider.currentUser!.id);

      // Set current page to the next unread page
      final pagesRead = progressProvider.pagesRead;
      if (pagesRead < _pages.length) {
        setState(() {
          _currentPageIndex = pagesRead;
        });
        _pageController.jumpToPage(_currentPageIndex);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  Future<void> _markPageAsRead() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      await progressProvider.incrementPagesRead(authProvider.currentUser!.id);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Page ${_currentPageIndex + 1} completed!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }

      // Check if all pages are read
      if (_currentPageIndex + 1 >= _pages.length) {
        _showCompletionDialog();
      } else {
        // Move to next page
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Congratulations!'),
        content: const Text(
          'You\'ve completed all the reading content! You can now access the audio content and booster videos.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRoutes.pushAndRemoveUntil(context, AppRoutes.dashboard);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProgressProvider>(
      builder: (context, authProvider, progressProvider, child) {
        final user = authProvider.currentUser;
        // ignore: unused_local_variable
        final progress = progressProvider.progress;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            title: Text('Reading Content'),
            backgroundColor: AppTheme.surfaceColor,
            elevation: 0,
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    '${progressProvider.pagesRead}/${_pages.length}',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: progressProvider.pagesRead / _pages.length,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    final isRead = index < progressProvider.pagesRead;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Page header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isRead
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isRead ? Icons.check : Icons.book,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Page ${index + 1}',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      page.title,
                                      style: AppTheme.headingMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Page content
                          Text(
                            page.content,
                            style: AppTheme.bodyLarge.copyWith(height: 1.6),
                          ),

                          const SizedBox(height: 32),

                          // Action buttons
                          if (!isRead)
                            PrimaryButton(
                              text: 'Mark as Read',
                              onPressed: _markPageAsRead,
                              isFullWidth: true,
                              icon: Icons.check,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.successColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppTheme.successColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Page completed',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.successColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Previous button
                    if (_currentPageIndex > 0)
                      Expanded(
                        child: OutlineButton(
                          text: 'Previous',
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          isFullWidth: true,
                        ),
                      ),

                    if (_currentPageIndex > 0) const SizedBox(width: 16),

                    // Next button
                    if (_currentPageIndex < _pages.length - 1)
                      Expanded(
                        child: PrimaryButton(
                          text: 'Next',
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          isFullWidth: true,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReadingPage {
  final String title;
  final String content;

  const ReadingPage({required this.title, required this.content});

  static List<ReadingPage> get pages => [
    const ReadingPage(
      title: 'Understanding Nicotine Addiction',
      content: '''
Nicotine is a highly addictive substance found in tobacco products. When you smoke, nicotine reaches your brain within seconds, creating a powerful reward system that makes quitting extremely difficult.

The addiction works on multiple levels:
• Physical dependence: Your body becomes accustomed to nicotine
• Psychological dependence: Smoking becomes linked to daily activities
• Behavioral patterns: The act of smoking becomes a habit

Understanding this is the first step to breaking free. Remember, the withdrawal symptoms you experience are temporary, and your brain will gradually return to normal function.
      ''',
    ),
    const ReadingPage(
      title: 'The Benefits of Quitting',
      content: '''
Quitting smoking offers immediate and long-term benefits that improve every aspect of your life:

Immediate Benefits (within 20 minutes):
• Blood pressure and heart rate drop
• Carbon monoxide levels normalize
• Circulation improves

Within 24 hours:
• Risk of heart attack begins to decrease
• Oxygen levels return to normal
• Sense of taste and smell improve

Long-term Benefits:
• Reduced risk of cancer, heart disease, and stroke
• Improved lung function and breathing
• Better skin and appearance
• Financial savings
• Increased energy and stamina

Every day without smoking is a victory for your health.
      ''',
    ),
    const ReadingPage(
      title: 'Preparing for Your Quit Journey',
      content: '''
Success in quitting requires preparation and planning. Here's how to set yourself up for success:

1. Set a Quit Date: Choose a meaningful date and stick to it
2. Identify Triggers: Recognize situations that make you want to smoke
3. Build Support: Tell friends and family about your decision
4. Remove Temptations: Get rid of cigarettes, lighters, and ashtrays
5. Plan Alternatives: Have healthy activities ready for cravings
6. Track Your Progress: Use this app to monitor your journey

Remember: Relapse is not failure. It's part of the learning process. Each attempt brings you closer to permanent freedom.
      ''',
    ),
    const ReadingPage(
      title: 'Managing Withdrawal Symptoms',
      content: '''
Withdrawal symptoms are your body's way of adjusting to life without nicotine. They typically peak within 3-5 days and gradually improve over 2-4 weeks.

Common Symptoms:
• Irritability and mood swings
• Difficulty concentrating
• Increased appetite
• Sleep disturbances
• Coughing and throat clearing
• Mild depression or anxiety

Coping Strategies:
• Stay hydrated and exercise regularly
• Practice deep breathing and relaxation techniques
• Use nicotine replacement therapy if needed
• Keep busy with activities you enjoy
• Connect with support groups or counselors

Remember: These symptoms are temporary and a sign that your body is healing.
      ''',
    ),
    const ReadingPage(
      title: 'Building New Habits',
      content: '''
Breaking the smoking habit requires replacing old patterns with new, healthy behaviors. This process takes time and patience.

Identify Your Smoking Triggers:
• Stressful situations
• Social gatherings
• After meals
• While driving
• During breaks at work

Create New Routines:
• Replace smoking breaks with short walks
• Use stress-relief techniques instead of cigarettes
• Find new social activities that don't involve smoking
• Practice mindfulness and meditation
• Develop healthy hobbies and interests

The key is consistency. New habits take 21-66 days to form, so be patient with yourself.
      ''',
    ),
    const ReadingPage(
      title: 'Nutrition and Exercise',
      content: '''
A healthy lifestyle supports your quit journey and helps manage withdrawal symptoms.

Nutrition Tips:
• Eat regular, balanced meals to maintain stable blood sugar
• Include plenty of fruits, vegetables, and whole grains
• Stay hydrated with water throughout the day
• Limit caffeine and alcohol, which can trigger cravings
• Consider healthy snacks to manage increased appetite

Exercise Benefits:
• Reduces stress and anxiety
• Improves mood and energy levels
• Helps manage weight gain
• Distracts from cravings
• Strengthens your commitment to health

Start with gentle activities like walking, swimming, or yoga. Gradually increase intensity as your fitness improves.
      ''',
    ),
    const ReadingPage(
      title: 'Stress Management Techniques',
      content: '''
Stress is a major trigger for smoking. Learning to manage stress without cigarettes is crucial for long-term success.

Effective Stress Management:
• Deep breathing exercises
• Progressive muscle relaxation
• Meditation and mindfulness
• Regular physical activity
• Adequate sleep and rest
• Time management skills
• Setting healthy boundaries

Quick Stress Relief:
• Take 10 deep breaths
• Go for a 5-minute walk
• Listen to calming music
• Practice gratitude
• Connect with a supportive friend
• Use positive self-talk

Remember: Stress is temporary, but the benefits of not smoking are permanent.
      ''',
    ),
    const ReadingPage(
      title: 'Staying Motivated',
      content: '''
Maintaining motivation throughout your quit journey is essential for success. Here are strategies to keep you focused:

Track Your Progress:
• Celebrate each smoke-free day
• Monitor health improvements
• Calculate money saved
• Note increased energy levels
• Document better breathing

Set Meaningful Goals:
• Short-term: Get through today
• Medium-term: Reach milestones (1 week, 1 month)
• Long-term: Permanent freedom

Find Your "Why":
• Health for yourself and family
• Financial freedom
• Better quality of life
• Setting a positive example
• Personal achievement

Remember: You're stronger than your addiction. Every day without smoking is a victory.
      ''',
    ),
    const ReadingPage(
      title: 'Preventing Relapse',
      content: '''
Relapse prevention is about recognizing warning signs and having strategies ready when cravings strike.

Warning Signs:
• Romanticizing smoking
• Minimizing the risks
• Isolating from support
• Returning to old habits
• Increased stress without coping strategies

Prevention Strategies:
• Stay connected with support systems
• Continue using coping techniques
• Avoid high-risk situations initially
• Practice saying "no" to offers
• Keep your quit date and reasons visible
• Use the craving timer in this app

If You Relapse:
• Don't give up - it's not failure
• Learn from the experience
• Identify what triggered the relapse
• Strengthen your coping strategies
• Set a new quit date immediately

Remember: Most successful quitters have multiple attempts. Each one brings you closer to permanent freedom.
      ''',
    ),
  ];
}
