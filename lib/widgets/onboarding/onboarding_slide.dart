// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final Color? backgroundColor;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.backgroundColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Image
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.image,
                      size: 100,
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),

          const Spacer(flex: 1),

          // Title
          Text(
            title,
            style: AppTheme.headingLarge.copyWith(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

class OnboardingIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalSlides;
  final Color? activeColor;
  final Color? inactiveColor;

  const OnboardingIndicator({
    super.key,
    required this.currentIndex,
    required this.totalSlides,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalSlides,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: index == currentIndex ? 24 : 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? activeColor ?? AppTheme.primaryColor
                : inactiveColor ?? AppTheme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  static List<OnboardingData> get slides => [
    const OnboardingData(
      title: 'Welcome to SimpeltStop',
      description:
          'Your journey to quit nicotine starts here. We\'re here to support you every step of the way with proven methods and personalized guidance.',
      imagePath: 'assets/images/slide 1.png',
    ),
    const OnboardingData(
      title: 'Track Your Progress',
      description:
          'Monitor your journey with detailed progress tracking. See how many days you\'ve been smoke-free and celebrate your milestones.',
      imagePath: 'assets/images/slide 2.png',
    ),
    const OnboardingData(
      title: 'Audio Support & Education',
      description:
          'Access educational content and audio boosters to help you stay motivated. Listen to calming audio during cravings.',
      imagePath: 'assets/images/slide 3.png',
    ),
  ];
}
