import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theway/Classes/AudioPlayer.dart';
import '../Classes/KhinsiderAlbums.dart';
import '../Services/KhinsiderScrapper.dart';
import 'package:provider/provider.dart';

class Audiolist extends StatefulWidget {
  final Album source;
  final VoidCallback onBack;
  const Audiolist({super.key, required this.source, required this.onBack});

  @override
  State<Audiolist> createState() => _AudiolistState();
}

class _AudiolistState extends State<Audiolist> {
  late Future<List<KhinAudio>> srcAudios;
  late AudioManager _audioManager;
  int? playingIndex;

  @override
  void initState() {
    super.initState();
    srcAudios = fetchAudio(widget.source);
  }

  StreamSubscription<PlayerState>? _audioSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioManager = Provider.of<AudioManager>(context, listen: false);

    // Cancel previous subscription if exists
    _audioSubscription?.cancel();

    _audioSubscription =
        _audioManager.audioPlayer.playerStateStream.listen((state) async {
      if (!mounted) return; // Prevent setState() on disposed widget

      List<KhinAudio>? audioList;
      try {
        audioList = await srcAudios; // Wait for the audio list to be available
      } catch (e) {
        print("Error fetching audio list: $e");
      }

      if (mounted) {
        // Check again before calling setState
        setState(() {
          final currentUrl = _audioManager.currentAudio?.audiolink;

          if (currentUrl == null) {
            playingIndex = null; // Reset only when the audio is fully stopped
          } else {
            playingIndex = _findPlayingIndex(currentUrl, audioList);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel(); // Cancel stream listener to prevent errors
    super.dispose();
  }

  int? _findPlayingIndex(String? currentUrl, List<KhinAudio>? audioList) {
    print("Checking currently playing URL: $currentUrl");
    if (currentUrl == null || audioList == null) return null;

    int index = audioList.indexWhere((audio) => audio.audiolink == currentUrl);
    print("Found playing index: $index");
    return index != -1 ? index : null; // Return null if not found
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    return FutureBuilder(
      future: srcAudios,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBack,
              ),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final List<KhinAudio> audios = snapshot.data ?? [];
          if (audios.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
              ),
              body: const Center(child: Text('No audio found for this album.')),
            );
          }

          return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Album Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.source
                                .image, // Replace with your album art URL
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Album Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.source.album, // Album name
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Platform: ${widget.source.platform}', // Album platform
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Released: ${widget.source.year}', // Release date
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              srcAudios.then((audioList) {
                                audioManager.loadPlaylist(audioList);
                              }).catchError((error) {
                                print("Error loading playlist: $error");
                              });
                            },
                            icon: const Icon(Icons.add))
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                      child: ListView.builder(
                    itemCount: audios.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          if (playingIndex != index) {
                            audioManager.playAudio(audios[index]);
                          } // Play Another Audio
                          else {
                            audioManager.togglePlayPause();
                          } // Pause Current Audio
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: playingIndex == index
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                (playingIndex == index &&
                                        _audioManager.isPlaying)
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: playingIndex == index
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  audios[index].audioname,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: playingIndex == index
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ))
                ],
              ));
        } else {
          return const Center(child: Text("Failed To Fetch Data"));
        }
      },
    );
  }
}
