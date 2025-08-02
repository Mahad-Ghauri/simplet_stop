import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous Button (placeholder)
            IconButton(
              icon: Icon(Icons.skip_previous),
              iconSize: 40,
              onPressed: () {
                // Implement previous song logic
                audioProvider.seek(Duration.zero);
              },
            ),

            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: audioProvider.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        audioProvider.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                      ),
                iconSize: 40,
                onPressed: audioProvider.isLoading
                    ? null
                    : () {
                        if (audioProvider.isPlaying) {
                          audioProvider.pause();
                        } else {
                          audioProvider.resume();
                        }
                      },
              ),
            ),

            // Stop Button
            IconButton(
              icon: Icon(Icons.stop),
              iconSize: 40,
              onPressed: audioProvider.currentSong != null
                  ? () => audioProvider.stop()
                  : null,
            ),
          ],
        );
      },
    );
  }
}
