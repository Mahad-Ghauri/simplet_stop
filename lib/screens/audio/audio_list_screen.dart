// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';
import 'package:simplet_stop/providers/authentication/auth_provider.dart';
import 'package:simplet_stop/providers/progress/progress_provider.dart';
import '../../utils/theme.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';

// Audio model to represent audio content
class AudioContent {
  final String id;
  final String title;
  final String description;
  final String type;
  final String? thumbnailUrl;
  final String audioUrl; // URL or asset path for the audio file
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

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _AudioListScreenState();
}

class _AudioListScreenState extends State<AudioListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  // Sample audio content - replace with your actual data source
  List<AudioContent> _audioContent = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAudioContent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAudioContent() async {
    setState(() {
      _isLoading = true;
    });

    // Mock data - replace with your actual data loading logic
    await Future.delayed(const Duration(milliseconds: 500));

    _audioContent = [
      // Educational content
      AudioContent(
        id: 'edu_1',
        title: 'Bird Chirping sound',
        description: 'Relax by listening to the sound of birds chirping',
        type: 'educational',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: false,
      ),
      AudioContent(
        id: 'edu_2',
        title: 'Memory Enhancement',
        description: 'Boost your memory with these exercises',
        type: 'educational',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: true,
      ),

      // Booster content
      AudioContent(
        id: 'boost_1',
        title: 'Confidence Booster',
        description: 'Build unshakeable confidence',
        type: 'booster',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: false,
      ),
      AudioContent(
        id: 'boost_2',
        title: 'Energy Boost',
        description: 'Increase your energy levels naturally',
        type: 'booster',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: true,
      ),

      // Calming content
      AudioContent(
        id: 'calm_1',
        title: 'Deep Relaxation',
        description: 'Achieve deep relaxation and peace',
        type: 'calming',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: false,
      ),
      AudioContent(
        id: 'calm_2',
        title: 'Sleep Meditation',
        description: 'Fall asleep peacefully with guided meditation',
        type: 'calming',
        audioUrl: 'assets/audio/sample.mp3',
        duration: const Duration(minutes: 2, seconds: 30),
        isPremium: true,
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<AudioContent> _getAudioByType(String type) {
    return _audioContent.where((audio) => audio.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Audio Content'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Educational'),
            Tab(text: 'Boosters'),
            Tab(text: 'Calming'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchTextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Audio Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAudioList('educational'),
                _buildAudioList('booster'),
                _buildAudioList('calming'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioList(String type) {
    return Consumer2<AuthProvider, ProgressProvider>(
      builder: (context, authProvider, progressProvider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<AudioContent> audioList = _getAudioByType(type);

        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          audioList = audioList
              .where(
                (audio) =>
                    audio.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    audio.description.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
        }

        if (audioList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headphones, size: 64, color: AppTheme.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No audio content found',
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or check back later',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: audioList.length,
          itemBuilder: (context, index) {
            final audio = audioList[index];
            final isUnlocked = progressProvider.isAudioUnlocked(audio.id);
            final isCompleted = _isAudioCompleted(
              audio.id,
            ); // You'll need to implement this
            final isPremium = audio.isPremium;
            final userIsPremium = authProvider.currentUser?.isPremium ?? false;

            return _buildAudioCard(
              context,
              audio,
              isUnlocked,
              isCompleted,
              isPremium,
              userIsPremium,
            );
          },
        );
      },
    );
  }

  // Helper method - implement based on your needs
  bool _isAudioCompleted(String audioId) {
    // This should check if the audio has been completed by the user
    // You might store this in SharedPreferences, database, or progress provider
    return false; // Placeholder
  }

  Widget _buildAudioCard(
    BuildContext context,
    AudioContent audio,
    bool isUnlocked,
    bool isCompleted,
    bool isPremium,
    bool userIsPremium,
  ) {
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );
    final pagesRead = progressProvider.pagesRead;

    // Check if user has read enough pages to unlock this audio
    final requiredPages = _getRequiredPagesForAudio(audio.id);
    final canUnlock = pagesRead >= requiredPages;
    final canPlay = (isUnlocked || canUnlock) && (!isPremium || userIsPremium);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: canPlay ? () => _playAudio(context, audio) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: audio.thumbnailUrl != null
                      ? null
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  image: audio.thumbnailUrl != null
                      ? DecorationImage(
                          image: NetworkImage(audio.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: audio.thumbnailUrl == null
                    ? Icon(
                        _getAudioIcon(audio.type),
                        color: AppTheme.primaryColor,
                        size: 24,
                      )
                    : null,
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            audio.title,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPremium)
                          Icon(
                            Icons.star,
                            color: AppTheme.warningColor,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audio.description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
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
                        if (isCompleted)
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Action Button
              if (canPlay)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.play_arrow, color: Colors.white, size: 20),
                )
              else if (canUnlock)
                InkWell(
                  onTap: () => _unlockAudio(context, audio),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.successColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.lock_open, color: Colors.white, size: 20),
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.lock, color: Colors.white, size: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAudioIcon(String type) {
    switch (type) {
      case 'educational':
        return Icons.school;
      case 'booster':
        return Icons.psychology;
      case 'calming':
        return Icons.self_improvement;
      default:
        return Icons.headphones;
    }
  }

  int _getRequiredPagesForAudio(String audioId) {
    // Define unlock thresholds for different audio content
    // First audio unlocks after reading 1 page, then every 2 pages
    final audioIndex =
        int.tryParse(audioId.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (audioIndex == 0) return 1; // First audio
    return 1 + (audioIndex * 2); // Subsequent audios
  }

  void _playAudio(BuildContext context, AudioContent audio) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final audioPlayerProvider = Provider.of<AudioPlayerProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;

    // Check if audio is premium and user is not premium
    if (audio.isPremium && !(user?.isPremium ?? false)) {
      _showPremiumUpgradeDialog(context);
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

    // Navigate to audio player screen
    AppRoutes.push(context, AppRoutes.audioPlayer, arguments: {'audio': audio});
  }

  void _showPremiumUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Content'),
        content: const Text(
          'This audio content is available exclusively to premium users. Upgrade to unlock all premium features and content.',
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

  Future<void> _unlockAudio(BuildContext context, AudioContent audio) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final progressProvider = Provider.of<ProgressProvider>(
      context,
      listen: false,
    );

    if (authProvider.currentUser != null) {
      try {
        await progressProvider.unlockAudio(
          authProvider.currentUser!.id,
          audio.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${audio.title} unlocked!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to unlock audio: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }
  }
}
