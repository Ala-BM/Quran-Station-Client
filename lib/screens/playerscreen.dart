import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/KhinsiderAlbums.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/Providers/cnx_plus_provider.dart';
import 'package:theway/widgets/components/playlist_mg.dart';
import '../Providers/hive_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../Providers/AudioPlayer.dart';
import 'package:theway/widgets/components/live_indicator.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final bool _isSeeking = false;
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
    return Consumer3<AudioManager, HiveService, JsonThemeProvider>(
        builder: (context, audioManager, hiveManager, themeprovider, child) {
      final currentThemeData = themeprovider.themeData;
      final colorScheme = currentThemeData.colorScheme;
      final duration = audioManager.audioPlayer.duration ?? Duration.zero;
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.translate("NowPlaying"),
            style: TextStyle(color: colorScheme.secondary),
          ),
          backgroundColor: colorScheme.surface,
          actions: [
            IconButton(
                icon: hiveManager.isFav(audioManager.currentAudio!)
                    ? Icon(Icons.favorite, color: colorScheme.secondary)
                    : Icon(Icons.favorite_outline, color: colorScheme.secondary),
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
                        //print("Settings pressed");
                      }
                    : () {
                        hiveManager.removeFavorite(
                            audioManager.currentAudio!.audiolink);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${AppLocalizations.of(context)!.translate("DeleteNotif")} ${AppLocalizations.of(context)!.translate("Favourites")}',
                            ),
                          ),
                        );

                      }),
            IconButton(
              icon: Icon(Icons.playlist_add, color: colorScheme.secondary),
              onPressed: () {
                _showPlaylists(context, audioManager.currentAudio!);
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow
                              .withOpacity(0.3), // Shadow color
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
                          StreamBuilder<ProcessingState>(
                            stream:
                                audioManager.audioPlayer.processingStateStream,
                            builder: (context, snapshot) {
                              final state =
                                  snapshot.data ?? ProcessingState.idle;
                              if (state == ProcessingState.buffering ||
                                  state == ProcessingState.loading) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 250,
                                      height: 250,
                                      decoration: BoxDecoration(
                                        color:
                                            colorScheme.shadow.withOpacity(0.3),
                                      ),
                                    ),
                                    const CircularProgressIndicator()
                                  ],
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  Localizations.localeOf(context).languageCode == 'en' &&
                          audioManager.currentAudio?.audioNameEx != null
                      ? audioManager.currentAudio!.audioNameEx!
                      : audioManager.currentAudio!.audioname,
                  style: TextStyle(
                    color: colorScheme.primary,
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
                                  trackHeight: 4.0, 
                                  inactiveTrackColor: colorScheme.inversePrimary, 
                                  activeTrackColor:
                                      colorScheme.primary, 
                                  thumbColor:
                                      colorScheme.secondary, 
                                  overlayColor:
                                      colorScheme.primary.withOpacity(0.2),
                                ),
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: ProgressBar(
                                      progress: Duration(
                                          milliseconds: _sliderValue.toInt()),
                                      buffered: buffered,
                                      total: duration,
                                      progressBarColor: colorScheme.primary,
                                      baseBarColor:
                                          colorScheme.onInverseSurface,
                                      bufferedBarColor:
                                          colorScheme.inversePrimary,
                                      thumbColor: colorScheme.primary,
                                      thumbGlowColor:
                                          colorScheme.inversePrimary,
                                      onSeek: (newDuration) {
                                        setState(() {
                                          _sliderValue = newDuration
                                              .inMilliseconds
                                              .toDouble();
                                        });
                                        audioManager.audioPlayer
                                            .seek(newDuration);
                                      },
                                    )))
                            : audioManager.AError!="none" ? Text(AppLocalizations.of(context)!.translate("ErrorSrc")) : audioManager.isLoading ? Text(AppLocalizations.of(context)!.translate("Loading")) : const LiveIndicator(),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 30,
                          icon: Icon(Icons.shuffle,
                              color: audioManager.isShuffle
                                  ? colorScheme.secondary
                                  : colorScheme.primaryFixedDim),
                          onPressed: duration != Duration.zero
                              ? audioManager.toggleShuffle
                              : null,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.skip_previous,
                              color: colorScheme.secondary),
                          onPressed: audioManager.playPrevAudio,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 60,
                          icon: Icon(
                            audioManager.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            color: audioManager.AError!="none" ? colorScheme.primary.withOpacity(0.5):colorScheme.primary,
                          ),
                          onPressed:audioManager.AError!="none" ? null : audioManager.togglePlayPause,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 40,
                          icon:
                              Icon(Icons.skip_next, color: colorScheme.secondary),
                          onPressed: audioManager.playNextAudio,
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 30,
                          icon: Icon(Icons.repeat_one,
                              color: audioManager.isRepeat
                                  ? colorScheme.secondary
                                  : colorScheme.secondaryFixedDim),
                          onPressed: duration != Duration.zero
                              ? audioManager.toggleRepeat
                              : null,
                        ),
                      ],
                    )),
              ],
            ),
            Consumer<ConnectionProvider>(
              builder: (context, cnxProvider, child) {
                if (!cnxProvider.isConnected) {
                  return Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: colorScheme.primaryFixedDim,
                      padding: const EdgeInsets.all(8),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: Colors.white),
                          SizedBox(width: 8),
                          Text("You're offline",
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      );
    });
  }
}
