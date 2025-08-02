import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              ),
              child: Slider(
                value: audioProvider.progress.clamp(0.0, 1.0),
                onChanged: (value) {
                  final duration = audioProvider.duration;
                  if (duration.inMilliseconds > 0) {
                    final position = Duration(
                      milliseconds: (duration.inMilliseconds * value).round(),
                    );
                    audioProvider.seek(position);
                  }
                },
                activeColor: Colors.deepPurple,
                inactiveColor: Colors.grey[300],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    audioProvider.formatDuration(audioProvider.position),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    audioProvider.formatDuration(audioProvider.duration),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
