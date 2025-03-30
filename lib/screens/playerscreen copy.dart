import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Classes/audioPlayer.dart'; // Import AudioManager
import '../Classes/KhinsiderAlbums.dart'; // Import KhinAudio
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class Playerscreen extends StatefulWidget {
  const Playerscreen({super.key});
  @override
  State<Playerscreen> createState() => _PlayerscreenState();
}

class _PlayerscreenState extends State<Playerscreen> {
  KhinAudio? currentAudio;
  late AudioManager audioManager;
  StreamSubscription? _positionSubscription;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Delay initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        audioManager = context.read<AudioManager>();
            currentAudio = audioManager.currentAudio;
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: StreamBuilder<Duration>(
              stream: audioManager.audioPlayer.positionStream,
              builder: (context, snapshot1) {
                final position = snapshot1.data ?? Duration.zero;
                return StreamBuilder<Duration>(
                  stream: audioManager.audioPlayer.bufferedPositionStream,
                  builder: (context, snapshot2) {
                    final buffered = snapshot2.data ?? Duration.zero;
                    return SizedBox(
                      height: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ProgressBar(
                          progress: position,
                          total: audioManager.audioPlayer.duration ?? Duration.zero,
                          buffered: buffered,
                          timeLabelPadding: -1,
                          timeLabelTextStyle: const TextStyle(fontSize: 14, color: Colors.black),
                          progressBarColor: const Color.fromARGB(255, 150, 84, 255),
                          baseBarColor: Colors.grey[200],
                          bufferedBarColor: Colors.grey[350],
                          thumbColor: const Color.fromARGB(255, 84, 42, 255),
                          onSeek: (duration) async {
                            await audioManager.audioPlayer.seek(duration);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  final currentPos = audioManager.audioPlayer.position.inSeconds;
                  if (currentPos >= 10) {
                    await audioManager.audioPlayer.seek(Duration(seconds: currentPos - 10));
                  } else {
                    await audioManager.audioPlayer.seek(Duration.zero);
                  }
                },
                icon: const Icon(Icons.fast_rewind_rounded),
              ),
              Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                child: IconButton(
                  onPressed: () async {
                    if (audioManager.isPlaying) {
                      audioManager.pauseAudio();
                    } else {
                      if (audioManager.audioPlayer.position >= (audioManager.audioPlayer.duration ?? Duration.zero)) {
                        await audioManager.audioPlayer.seek(Duration.zero);
                      }
                      audioManager.playAudio(currentAudio);
                    }
                  },
                  icon: Icon(
                    audioManager.isPlaying
                        ? Icons.pause
                        : (audioManager.audioPlayer.position >= (audioManager.audioPlayer.duration ?? Duration.zero)
                            ? Icons.replay
                            : Icons.play_arrow),
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () async {
                  final currentPos = audioManager.audioPlayer.position.inSeconds;
                  final duration = audioManager.audioPlayer.duration?.inSeconds ?? 0;
                  if (currentPos + 10 <= duration) {
                    await audioManager.audioPlayer.seek(Duration(seconds: currentPos + 10));
                  } else {
                    await audioManager.audioPlayer.seek(Duration.zero);
                  }
                },
                icon: const Icon(Icons.fast_forward_rounded),
              ),
            ],
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}