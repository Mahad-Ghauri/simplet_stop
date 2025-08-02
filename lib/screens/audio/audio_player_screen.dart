// lib/screens/audio/audio_player_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio/audio_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/audio/audio_control_buttons.dart';
import '../../widgets/audio/audio_progress_bar.dart';
import '../../widgets/audio/volume_control.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Current Audio Display
                Consumer<AudioPlayerProvider>(
                  builder: (context, audioProvider, child) {
                    return _buildCurrentAudioCard(audioProvider);
                  },
                ),

                const SizedBox(height: 30),

                // Progress Bar
                AudioProgressBar(),

                const SizedBox(height: 30),

                // Control Buttons
                AudioControlButtons(),

                const SizedBox(height: 30),

                // Volume Control
                VolumeControl(),

                const SizedBox(height: 30),

                // Debug Info (only in debug mode)

                // Debug Info (only in debug mode)
                if (kDebugMode)
                  Consumer<AudioPlayerProvider>(
                    builder: (context, audioProvider, child) {
                      return _buildDebugInfo(audioProvider);
                    },
                  ),

                const SizedBox(height: 20),

                // Add Sample Audio to Database (Debug only)
                if (kDebugMode)
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
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAudioCard(AudioPlayerProvider audioProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade100, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Audio thumbnail or icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: audioProvider.currentAudioThumbnail != null
                  ? ClipOval(
                      child: Image.network(
                        audioProvider.currentAudioThumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.music_note,
                            size: 60,
                            color: Colors.deepPurple.shade700,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.music_note,
                      size: 60,
                      color: Colors.deepPurple.shade700,
                    ),
            ),

            const SizedBox(height: 16),

            // Audio title
            Text(
              audioProvider.currentSong ?? 'No audio selected',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Audio description
            if (audioProvider.currentAudioDescription.isNotEmpty)
              Text(
                audioProvider.currentAudioDescription,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            const SizedBox(height: 12),

            // Loading indicator
            if (audioProvider.isLoading)
              Column(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepPurple.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading audio...',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),

            // Error message
            if (audioProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        audioProvider.errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Audio source indicator
            if (audioProvider.isFirestoreAudio)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'From Database',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo(AudioPlayerProvider audioProvider) {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Debug Info',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'State: ${audioProvider.playerState.name}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Is Playing: ${audioProvider.isPlaying}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Is Loading: ${audioProvider.isLoading}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Duration: ${audioProvider.formatDuration(audioProvider.duration)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Position: ${audioProvider.formatDuration(audioProvider.position)}',
              style: const TextStyle(fontSize: 12),
            ),
            if (audioProvider.currentAudio != null)
              Text(
                'Audio URL: ${audioProvider.currentAudio!.audioUrl}',
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
