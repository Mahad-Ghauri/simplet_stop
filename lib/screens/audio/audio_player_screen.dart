// lib/screens/audio/audio_player_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/audio/audio_provider.dart';
import '../../widgets/audio/audio_control_buttons.dart';
import '../../widgets/audio/audio_progress_bar.dart';
import '../../widgets/audio/volume_control.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _pulseController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _pulseAnimation;

  int selectedTab = 0; // 0: Nature, 1: Rain, 2: Ocean, 3: Music

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startAnimations() {
    if (mounted) {
      _breathingController.repeat(reverse: true);
      _pulseController.repeat();
    }
  }

  void stopAnimations() {
    if (mounted) {
      _breathingController.stop();
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF8B5FBF).withOpacity(0.8),
                const Color(0xFF6B46C1).withOpacity(0.9),
                const Color(0xFF553C9A).withOpacity(0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<AudioPlayerProvider>(
              builder: (context, audioProvider, child) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 16 : 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              audioProvider.stop();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Stress-Free Breathing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              audioProvider.stop();
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    _buildBreathingCircle(audioProvider, screenSize),

                    const Spacer(flex: 1),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 40,
                      ),
                      child: Text(
                        audioProvider.currentSong ??
                            'Take a deep breath in through your nose...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    if (audioProvider.errorMessage != null)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 20 : 40,
                          vertical: 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  audioProvider.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(flex: 2),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 30,
                      ),
                      child: const AudioProgressBar(),
                    ),

                    const SizedBox(height: 30),

                    _buildControlButtons(audioProvider, isSmallScreen),

                    const SizedBox(height: 40),

                    _buildBottomTabs(isSmallScreen),

                    const SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle(
    AudioPlayerProvider audioProvider,
    Size screenSize,
  ) {
    String displayText = 'Inhale';
    if (audioProvider.isLoading) {
      displayText = 'Loading...';
    } else if (audioProvider.currentSong != null) {
      displayText = audioProvider.isPlaying ? 'Playing' : 'Paused';
    }

    if (audioProvider.isPlaying && !_breathingController.isAnimating) {
      startAnimations();
    } else if (!audioProvider.isPlaying && _breathingController.isAnimating) {
      stopAnimations();
    }

    // Calculate responsive sizes
    final maxCircleSize = screenSize.width * 0.75;
    final circleSize = maxCircleSize.clamp(200.0, 300.0);
    final basePulseSize = circleSize * 0.67; // 200/300 ratio
    final maxPulseSize = circleSize * 1.1; // Limit pulse expansion

    return Center(
      child: SizedBox(
        width: circleSize,
        height: circleSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (audioProvider.isPlaying)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      double delay = index * 0.3;
                      double animationValue = (_pulseAnimation.value - delay)
                          .clamp(0.0, 1.0);
                      final pulseSize =
                          basePulseSize +
                          (animationValue * (maxPulseSize - basePulseSize)) +
                          (index * 20);
                      return Container(
                        width: pulseSize,
                        height: pulseSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              0.3 * (1 - animationValue),
                            ),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: audioProvider.isPlaying
                      ? _breathingAnimation.value
                      : 1.0,
                  child: Container(
                    width: basePulseSize,
                    height: basePulseSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        stops: const [0.3, 0.7, 1.0],
                      ),
                    ),
                    child: Center(
                      child: audioProvider.isLoading
                          ? const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  displayText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        circleSize *
                                        0.09, // Responsive font size
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (audioProvider.currentAudioThumbnail != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: Image.network(
                                        audioProvider.currentAudioThumbnail!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.music_note,
                                                size: 20,
                                                color: Colors.white,
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

Widget _buildControlButtons(
  AudioPlayerProvider audioProvider,
  bool isSmallScreen,
) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
    child: Column(
      children: [
        // Volume Control - placed above the buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 40),
          child: const VolumeControl(),
        ),
        
        const SizedBox(height: 20),
        
        // Control buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Settings/Tune button
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune, color: Colors.white, size: 24),
            ),
            
            // Audio control buttons (play/pause/etc)
            const AudioControlButtons(),
            
            // Duration text
            SizedBox(
              width: isSmallScreen ? 50 : 60,
              child: Text(
                audioProvider.formatDuration(audioProvider.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
  Widget _buildBottomTabs(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomTab(0, Icons.nature, 'Nature', isSmallScreen),
          _buildBottomTab(1, Icons.grain, 'Rain', isSmallScreen),
          _buildBottomTab(2, Icons.waves, 'Ocean', isSmallScreen),
          _buildBottomTab(3, Icons.music_note, 'Music', isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildBottomTab(
    int index,
    IconData icon,
    String label,
    bool isSmallScreen,
  ) {
    bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
        HapticFeedback.lightImpact();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
