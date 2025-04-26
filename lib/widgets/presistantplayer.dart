import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../screens/playerscreen.dart';
import '../Providers/AudioPlayer.dart';

class PersistentPlayer extends StatefulWidget {
  const PersistentPlayer({super.key});

  @override
  State<PersistentPlayer> createState() => _PersistentPlayerState();
}

class _PersistentPlayerState extends State<PersistentPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late AudioManager _audioManager;

  @override
  void initState() {
    super.initState();
    _audioManager = Provider.of<AudioManager>(context, listen: false);
    _audioManager.audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        //print("The Audio has ended");
        _audioManager.handleSongEnd();
      }
      if (playerState.processingState == ProcessingState.buffering ||
          playerState.processingState == ProcessingState.loading) {
        _audioManager.setLoading(true);
      } else {
        _audioManager.setLoading(false);
      }
    });

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _audioManager.addListener(_updateAnimationState);
  }

  @override
  void dispose() {
    _audioManager.removeListener(_updateAnimationState);
    _rotationController.dispose();
    super.dispose();
  }

  void _showPlaylists(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return SizedBox();
        });
  } //this for playlist managment from the presistant player

  void _updateAnimationState() {
    if (_audioManager.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioManager>(
      builder: (context, audioManager, child) {
        if (audioManager.currentAudio == null) {
          // Return empty if no audio is playing, no widget display
          return const SizedBox.shrink();
        }
        final audioName =
            Localizations.localeOf(context).languageCode == 'en' &&
                    audioManager.currentAudio?.audioNameEx != null
                ? audioManager.currentAudio!.audioNameEx!
                : audioManager.currentAudio!.audioname;

        final statusText = audioManager.isLoading
            ? AppLocalizations.of(context)!.translate("Loading")
            : AppLocalizations.of(context)!.translate("NowPlaying");

        // Loading state
        if (audioManager.isLoading) {
          return _buildPlayerContainer(
            context,
            audioManager,
            audioName,
            statusText,
            isLoading: true,
          );
        }

        // Loaded state
        return _buildPlayerContainer(
          context,
          audioManager,
          audioName,
          statusText,
          isLoading: false,
        );
      },
    );
  }

  Widget _buildPlayerContainer(
    BuildContext context,
    AudioManager audioManager,
    String audioName,
    String statusText, {
    required bool isLoading,
  }) {
    return GestureDetector(
      onTap: () => _navigateToPlayerScreen(context),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLoading
              ? const Color.fromARGB(255, 10, 19, 33)
              : Colors.blue[900],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipOval(
              child: RotationTransition(
                turns: _rotationController,
                child: isLoading
                    ? const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Image.network(
                        audioManager.currentAudio!.albumImg,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audioName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    audioManager.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: isLoading ? null : audioManager.togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white),
                  onPressed: isLoading ? null : audioManager.stopAudio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPlayerScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: context.read<AudioManager>(),
          child: const PlayerScreen(),
        ),
      ),
    );
  }
}
