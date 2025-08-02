import 'package:flutter/material.dart';
import '../../widgets/onboarding/onboarding_slide.dart';
import '../../widgets/common/custom_button.dart';
import '../../utils/theme.dart';
import '../../routes/app_routes.dart';
import '../../services/storage_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final StorageService _storageService = StorageService.instance;
  int _currentIndex = 0;
  final List<OnboardingData> _slides = OnboardingData.slides;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextSlide() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousSlide() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      // Mark onboarding as completed
      await _storageService.setFirstTime(false);

      // Navigate to login screen
      if (mounted) {
        AppRoutes.pushAndRemoveUntil(context, AppRoutes.login);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentIndex < _slides.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    title: slide.title,
                    description: slide.description,
                    imagePath: slide.imagePath,
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicator
                  OnboardingIndicator(
                    currentIndex: _currentIndex,
                    totalSlides: _slides.length,
                  ),

                  const SizedBox(height: 32),

                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentIndex > 0)
                        Expanded(
                          child: OutlineButton(
                            text: 'Previous',
                            onPressed: _previousSlide,
                            isFullWidth: true,
                          ),
                        ),

                      if (_currentIndex > 0) const SizedBox(width: 16),

                      // Next/Get Started button
                      Expanded(
                        flex: _currentIndex > 0 ? 1 : 2,
                        child: PrimaryButton(
                          text: _currentIndex == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _nextSlide,
                          isFullWidth: true,
                          icon: _currentIndex == _slides.length - 1
                              ? Icons.arrow_forward
                              : null,
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
}

// Alternative onboarding page widget for individual pages
class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return OnboardingSlide(
      title: data.title,
      description: data.description,
      imagePath: data.imagePath,
    );
  }
}
