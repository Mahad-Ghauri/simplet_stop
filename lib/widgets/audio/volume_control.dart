import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplet_stop/providers/audio/audio_provider.dart';

class VolumeControl extends StatelessWidget {
  const VolumeControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return Container(
          constraints: BoxConstraints(maxWidth: 120),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_down,
                color: Colors.white,
                size: 16,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: audioProvider.volume,
                    onChanged: (value) => audioProvider.setVolume(value),
                  ),
                ),
              ),
              Icon(
                Icons.volume_up,
                color: Colors.white,
                size: 16,
              ),
            ],
          ),
        );
      },
    );
  }
}