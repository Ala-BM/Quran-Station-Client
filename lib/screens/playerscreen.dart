import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Classes/KhinsiderAlbums.dart';
import 'package:theway/widgets/playlist_mg.dart';
import '../Services/hive_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../Classes/AudioPlayer.dart';
import 'package:theway/widgets/live_indicator.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isSeeking = false;
  double _sliderValue = 0.0;

  void _showPlaylists(BuildContext context, KhinAudio selectedAudio) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: PlaylistMg(
            selectedAudio: selectedAudio,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    final hiveManager = Provider.of<HiveService>(context);
   final duration =
                  audioManager.audioPlayer.duration ?? Duration.zero;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("NowPlaying")),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
              icon: hiveManager.isFav(audioManager.currentAudio!)
                  ? const Icon(Icons.favorite)
                  : const Icon(Icons.favorite_outline),
              onPressed: !hiveManager.isFav(audioManager.currentAudio!)
                  ? () {
                      hiveManager.addFavorite(audioManager.currentAudio!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context)!.translate("AddNotif")} ${AppLocalizations.of(context)!.translate("Favourites")}',
                          ),
                        ),
                      );
                      print("Settings pressed");
                    }
                  : () {
                      hiveManager
                          .removeFavorite(audioManager.currentAudio!.audiolink);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${AppLocalizations.of(context)!.translate("DeleteNotif")} ${AppLocalizations.of(context)!.translate("Favourites")}',
                          ),
                        ),
                      );
                      print("Settings pressed");
                    }),
          IconButton(
            icon: const Icon(Icons.playlist_add),
            onPressed: () {
              _showPlaylists(context, audioManager.currentAudio!);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album Art
          Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3), // Shadow color
                    blurRadius: 10, // Spread of the shadow
                    spreadRadius: 2, // Extent of the shadow
                    offset: const Offset(4, 4), // Shadow offset
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      audioManager.currentAudio?.albumImg ?? '',
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                    if (audioManager.isLoading)
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5), // Dim the image
                        ),
                      ),
                    if (audioManager.isLoading)
                      const CircularProgressIndicator(), // Loading indicator
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Audio Title
          Text(
            Localizations.localeOf(context).languageCode == 'en' &&
                    audioManager.currentAudio?.audioNameEx != null
                ? audioManager.currentAudio!.audioNameEx!
                : audioManager.currentAudio!.audioname,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Artist Name
          /*Text(
            audioManager.currentAudio?.artist ?? "Unknown Artist",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),*/

          // Slider with StreamBuilder

          StreamBuilder<Duration>(
            stream: audioManager.audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final buffered = audioManager.audioPlayer.bufferedPosition;

              if (!_isSeeking) {
                _sliderValue = position.inMilliseconds.toDouble();
              }
              if (_sliderValue > duration.inMilliseconds.toDouble()) {
                _sliderValue = duration.inMilliseconds.toDouble();
              }

              return Column(
                children: [
                  duration != Duration.zero
                      ? SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4.0, // Thinner track
                            inactiveTrackColor:
                                Colors.grey.shade600, // Background color
                            activeTrackColor: Colors.blue, // Played progress
                            thumbColor: Colors.white, // Thumb color
                            overlayColor: Colors.blue.withOpacity(0.2),
                          ),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ProgressBar(
                                progress: Duration(
                                    milliseconds: _sliderValue
                                        .toInt()), // Current audio progress
                                buffered: buffered, // Buffered progress
                                total: duration, // Total duration
                                progressBarColor:
                                    Colors.blue, // Active audio progress
                                baseBarColor: Colors
                                    .grey.shade600, // Inactive background bar
                                bufferedBarColor: const Color.fromARGB(
                                    255, 214, 214, 214), // Buffered progress
                                thumbColor: Colors.blue, // Thumb color
                                thumbGlowColor: Colors.blue.withOpacity(0.2),
                                onSeek: (newDuration) {
                                  setState(() {
                                    _sliderValue =
                                        newDuration.inMilliseconds.toDouble();
                                  });
                                  audioManager.audioPlayer.seek(newDuration);
                                },
                              )))
                      : const LiveIndicator(),

                  // Time indicators
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Playback Controls
          Row(
            
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.shuffle,
                    color: audioManager.isShuffle
                        ? const Color.fromARGB(255, 125, 86, 254)
                        : const Color.fromARGB(255, 101, 101, 102)),
                onPressed: duration != Duration.zero ? audioManager.toggleShuffle :null,
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_previous,
                    color: Color.fromARGB(255, 125, 86, 254)),
                onPressed:  audioManager.playPrevAudio,
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 60,
                icon: Icon(
                  audioManager.isPlaying
                      ? Icons.pause_circle
                      : Icons.play_circle,
                  color: Colors.blue,
                ),
                onPressed: audioManager.togglePlayPause,
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 40,
                icon: const Icon(Icons.skip_next,
                    color: Color.fromARGB(255, 125, 86, 254)),
                onPressed: audioManager.playNextAudio,
              ),
              const SizedBox(width: 20),
              IconButton(
                iconSize: 30,
                icon: Icon(Icons.repeat_one,
                    color: audioManager.isRepeat
                        ? const Color.fromARGB(255, 125, 86, 254)
                        : const Color.fromARGB(255, 101, 101, 102)),
                onPressed:duration != Duration.zero ? audioManager.toggleRepeat : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
