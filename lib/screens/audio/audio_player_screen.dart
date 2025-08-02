// lib/screens/audio/audio_player_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/audio/audio_provider.dart';
import '../../services/firestore_service.dart';
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

  int selectedTab = 0; // 0: Natur, 1: Regn, 2: Hav, 3: Musik

  @override
  void initState() {
    super.initState();
    
    // Breathing animation for the main circle
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _breathingAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for ripple effect
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void startAnimations() {
    _breathingController.repeat(reverse: true);
    _pulseController.repeat();
  }

  void stopAnimations() {
    _breathingController.stop();
    _pulseController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/background.png'),
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
                // Start/stop animations based on play state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (audioProvider.isPlaying) {
                    startAnimations();
                  } else {
                    stopAnimations();
                  }
                });

                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const Text(
                            'Stressfri Vejrtrækning',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
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

                    // Main breathing circle with animation
                    _buildBreathingCircle(audioProvider),

                    const Spacer(flex: 1),

                    // Instruction text or current song title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        audioProvider.currentSong ?? 'Tag en dyb indånding gennem næsen...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Error message
                    if (audioProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.5)),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Spacer(flex: 2),

                    // Progress bar (using your existing widget)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          sliderTheme: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            trackHeight: 2,
                          ),
                        ),
                        child: AudioProgressBar(),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Control buttons (modified to match design)
                    _buildControlButtons(audioProvider),

                    const SizedBox(height: 40),

                    // Bottom tabs
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBottomTab(0, Icons.nature, 'Natur'),
                          _buildBottomTab(1, Icons.grain, 'Regn'),
                          _buildBottomTab(2, Icons.waves, 'Hav'),
                          _buildBottomTab(3, Icons.music_note, 'Musik'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Debug section (only in debug mode)
                    if (kDebugMode) _buildDebugSection(audioProvider),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle(AudioPlayerProvider audioProvider) {
    String displayText = 'Indånd';
    if (audioProvider.isLoading) {
      displayText = 'Loading...';
    } else if (audioProvider.currentSong != null) {
      displayText = audioProvider.isPlaying ? 'Playing' : 'Paused';
    }

    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings (only show when playing)
            if (audioProvider.isPlaying)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(3, (index) {
                      double delay = index * 0.3;
                      double animationValue = (_pulseAnimation.value - delay).clamp(0.0, 1.0);
                      return Container(
                        width: 200 + (animationValue * 100) + (index * 30),
                        height: 200 + (animationValue * 100) + (index * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3 * (1 - animationValue)),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            
            // Main circle
            Transform.scale(
              scale: audioProvider.isPlaying ? _breathingAnimation.value : 1.0,
              child: Container(
                width: 200,
                height: 200,
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
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (audioProvider.currentAudioThumbnail != null)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    audioProvider.currentAudioThumbnail!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButtons(AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Settings/Equalizer
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.tune,
            color: Colors.white,
            size: 24,
          ),
        ),
        
        // Volume Control (using your existing widget but styled)
        Theme(
          data: Theme.of(context).copyWith(
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          child: VolumeControl(),
        ),
        
        // Play/Pause (using your existing widget but styled)
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.3),
          ),
          child: Center(
            child: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white, size: 32),
              ),
              child: AudioControlButtons(),
            ),
          ),
        ),
        
        // Timer - show total duration
        Text(
          audioProvider.formatDuration(audioProvider.duration),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomTab(int index, IconData icon, String label) {
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
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugSection(AudioPlayerProvider audioProvider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Add Sample Audio to Database (Debug only)
          ElevatedButton.icon(
            onPressed: () async {
              try {
                await FirestoreService.instance.addSampleAudioContent();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sample audio added to database successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Sample Audio to DB'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.withOpacity(0.8),
              foregroundColor: Colors.white,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Debug info card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Debug Info',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'State: ${audioProvider.playerState.name}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Is Playing: ${audioProvider.isPlaying}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                Text(
                  'Is Loading: ${audioProvider.isLoading}',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                if (audioProvider.currentAudio != null)
                  Text(
                    'Audio URL: ${audioProvider.currentAudio!.audioUrl}',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}