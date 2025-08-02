import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';

class VolumeControl extends StatelessWidget {
  const VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Row(
          children: [
            Icon(Icons.volume_down),
            Expanded(
              child: Slider(
                value: audioProvider.volume,
                onChanged: (value) => audioProvider.setVolume(value),
                activeColor: Colors.deepPurple,
              ),
            ),
            Icon(Icons.volume_up),
          ],
        );
      },
    );
  }
}
