import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';

class SampleAudioButtons extends StatelessWidget {
  const SampleAudioButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    
    return Column(
      children: [
        Text(
          'Sample Audio Sources:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.folder),
              label: Text('Asset Audio'),
              onPressed: () {
                // Make sure to add an audio file to assets/audio/sample.mp3
                audioProvider.playFromAsset('audio/sample.mp3');
              },
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.cloud),
              label: Text('Network Audio'),
              onPressed: () {
                // Example URL - replace with a valid audio URL
                audioProvider.playFromUrl(
                  'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}