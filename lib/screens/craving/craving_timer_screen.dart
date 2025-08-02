// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'dart:async';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/common/custom_button.dart';
import '../../routes/app_routes.dart';

// Audio model (same as in AudioListScreen)
class AudioContent {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? thumbnailUrl;
  final String audioUrl;
  final Duration duration;
  final bool isPremium;

  AudioContent({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.thumbnailUrl,
    required this.audioUrl,
    required this.duration,
    this.isPremium = false,
  });

  String get formattedDuration {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return duration.inHours > 0 
        ? '${twoDigits(duration.inHours)}:$minutes:$seconds' 
        : '$minutes:$seconds';
  }
}

class CravingTimerScreen extends StatefulWidget {
  const CravingTimerScreen({super.key});

  @override
  State<CravingTimerScreen> createState() => _CravingTimerScreenState();
}

class _CravingTimerScreenState extends State<CravingTimerScreen>
    with TickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _animation;

  int _remainingSeconds = AppConstants.cravingTimerDuration * 60;
  bool _isTimerRunning = false;
  bool _isTimerCompleted = false;
  bool _isLoadingAudio = false;
  List<AudioContent> _calmingAudios = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: AppConstants.cravingTimerDuration * 60),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
    _loadCalmingAudio();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCalmingAudio() async {
    setState(() {
      _isLoadingAudio = true;
    });

    // Mock calming audio data - replace with your actual data source
    await Future.delayed(const Duration(milliseconds: 300));
    
    _calmingAudios = [
      AudioContent(
        id: 'calm_1',
        title: 'Deep Breathing',
        description: 'Guided breathing exercise to reduce cravings',
        type: 'calming',
        audioUrl: 'assets/audio/deep_breathing.mp3',
        duration: const Duration(minutes: 5, seconds: 0),
        isPremium: false,
      ),
      AudioContent(
        id: 'calm_2',
        title: 'Mindful Meditation',
        description: 'Short meditation to overcome urges',
        type: 'calming',
        audioUrl: 'assets/audio/mindful_meditation.mp3',
        duration: const Duration(minutes: 10, seconds: 0),
        isPremium: false,
      ),
      AudioContent(
        id: 'calm_3',
        title: 'Progressive Relaxation',
        description: 'Full body relaxation technique',
        type: 'calming',
        audioUrl: 'assets/audio/progressive_relaxation.mp3',
        duration: const Duration(minutes: 15, seconds: 0),
        isPremium: true,
      ),
      AudioContent(
        id: 'calm_4',
        title: 'Ocean Waves',
        description: 'Calming ocean sounds for relaxation',
        type: 'calming',
        audioUrl: 'assets/audio/ocean_waves.mp3',
        duration: const Duration(minutes: 20, seconds: 0),
        isPremium: false,
      ),
    ];

    setState(() {
      _isLoadingAudio = false;
    });
  }

  List<AudioContent> _getCalmingAudio() {
    return _calmingAudios;
  }

  void _startTimer() {
    setState(() {
      _isTimerRunning = true;
      _isTimerCompleted = false;
    });

    _animationController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeTimer();
          timer.cancel();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isTimerRunning = false;
    });
    _timer?.cancel();
    _animationController.stop();
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = AppConstants.cravingTimerDuration * 60;
      _isTimerRunning = false;
      _isTimerCompleted = false;
    });
    _timer?.cancel();
    _animationController.reset();
  }

  void _completeTimer() {
    setState(() {
      _isTimerRunning = false;
      _isTimerCompleted = true;
    });
    _animationController.forward();

    // Save craving timer completion
    _saveCravingTimer();
  }

  void _saveCravingTimer() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      // TODO: Save craving timer completion to progress
      // This could be used for analytics and motivation
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Craving Timer'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              _buildHeader(),

              const SizedBox(height: 32),

              // Timer Display
              _buildTimerDisplay(),

              const SizedBox(height: 32),

              // Timer Controls
              _buildTimerControls(),

              const SizedBox(height: 32),

              // Calming Audio
              _buildCalmingAudio(),

              const SizedBox(height: 24),

              // Motivational Message
              _buildMotivationalMessage(),
              
              // Add some bottom padding to ensure content is never cut off
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: const Icon(
            Icons.psychology,
            color: AppTheme.warningColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text('Craving Timer', style: AppTheme.headingMedium),
        const SizedBox(height: 8),
        Text(
          'Take a moment to breathe and let the craving pass',
          style: AppTheme.bodyLarge.copyWith(color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Make timer responsive to screen size
        final screenWidth = MediaQuery.of(context).size.width;
        final timerSize = (screenWidth * 0.6).clamp(200.0, 250.0);
        final progressSize = timerSize - 50;
        
        return Container(
          width: timerSize,
          height: timerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isTimerCompleted
                ? AppTheme.successColor.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: progressSize,
                  height: progressSize,
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isTimerCompleted
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: AppTheme.headingLarge.copyWith(
                        fontSize: screenWidth < 400 ? 36 : 48,
                        fontWeight: FontWeight.bold,
                        color: _isTimerCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isTimerCompleted
                          ? 'Great job!'
                          : _isTimerRunning
                          ? 'Stay strong!'
                          : 'Ready to start?',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
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

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (!_isTimerCompleted)
          Expanded(
            child: _isTimerRunning
                ? PrimaryButton(
                    text: 'Pause',
                    onPressed: _pauseTimer,
                    icon: Icons.pause,
                  )
                : PrimaryButton(
                    text: 'Start Timer',
                    onPressed: _startTimer,
                    icon: Icons.play_arrow,
                  ),
          ),

        if (!_isTimerCompleted &&
            _remainingSeconds < AppConstants.cravingTimerDuration * 60)
          const SizedBox(width: 16),

        if (!_isTimerCompleted &&
            _remainingSeconds < AppConstants.cravingTimerDuration * 60)
          Expanded(
            child: OutlineButton(
              text: 'Reset',
              onPressed: _resetTimer,
              icon: Icons.refresh,
            ),
          ),

        if (_isTimerCompleted)
          Expanded(
            child: PrimaryButton(
              text: 'Start New Timer',
              onPressed: _resetTimer,
              icon: Icons.replay,
            ),
          ),
      ],
    );
  }

  Widget _buildCalmingAudio() {
    if (_isLoadingAudio) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final calmingAudios = _getCalmingAudio();

    if (calmingAudios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calming Audio', style: AppTheme.headingSmall),
            const SizedBox(height: 16),

            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: calmingAudios.length,
                itemBuilder: (context, index) {
                  final audio = calmingAudios[index];
                  final userIsPremium = authProvider.currentUser?.isPremium ?? false;
                  final canPlay = !audio.isPremium || userIsPremium;

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: canPlay ? () => _playCalmingAudio(audio) : () => _showPremiumDialog(),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.self_improvement,
                                    color: AppTheme.accentColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      audio.title,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (audio.isPremium)
                                    Icon(
                                      Icons.star,
                                      color: AppTheme.warningColor,
                                      size: 16,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                audio.description,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    audio.formattedDuration,
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    canPlay ? Icons.play_arrow : Icons.lock,
                                    color: canPlay ? AppTheme.accentColor : AppTheme.textSecondary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMotivationalMessage() {
    final messages = [
      'You\'re stronger than your cravings!',
      'Every minute you resist makes you stronger.',
      'Your health is worth more than a cigarette.',
      'You\'re building a better future for yourself.',
      'Stay focused on your goals!',
    ];

    final randomMessage =
        messages[DateTime.now().millisecond % messages.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: AppTheme.successColor, size: 32),
          const SizedBox(height: 12),
          Text(
            randomMessage,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playCalmingAudio(AudioContent audio) {
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Check if audio is premium and user is not premium
    if (audio.isPremium && !(user?.isPremium ?? false)) {
      _showPremiumDialog();
      return;
    }

    // Play the audio using AudioPlayerProvider
    if (audio.audioUrl.startsWith('assets/')) {
      // Asset audio
      audioPlayerProvider.playFromAsset(audio.audioUrl);
    } else if (audio.audioUrl.startsWith('http')) {
      // URL audio
      audioPlayerProvider.playFromUrl(audio.audioUrl);
    } else {
      // File path audio
      audioPlayerProvider.playFromFile(audio.audioUrl);
    }

    // Show a snackbar to indicate audio is playing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.play_arrow, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Playing: ${audio.title}'),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Open Player',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to full audio player if you have one
            AppRoutes.push(
              context,
              AppRoutes.audioPlayer,
              arguments: {'audio': audio},
            );
          },
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(
          'This calming audio is available exclusively to premium users. Upgrade to unlock all premium features and content.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppRoutes.push(context, AppRoutes.payment);
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}