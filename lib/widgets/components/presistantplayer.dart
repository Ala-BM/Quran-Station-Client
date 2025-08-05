import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../../screens/playerscreen.dart';
import '../../Providers/AudioPlayer.dart';
import '../../Providers/json_theme_provider.dart';

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
          return const SizedBox.shrink();
        }
        final String? audioName =
            Localizations.localeOf(context).languageCode == 'en' &&
                    audioManager.currentAudio?.audioNameEx != null
                ? audioManager.currentAudio!.audioNameEx
                : audioManager.currentAudio!.audioname;

        final statusText = audioManager.isLoading
            ? AppLocalizations.of(context)!.translate("Loading"):audioManager.AError!="none"
            ? AppLocalizations.of(context)!.translate("ErrorSrc")
            : AppLocalizations.of(context)!.translate("NowPlaying");

        if (audioManager.isLoading) {
          return _buildPlayerContainer(
            context,
            audioManager,
            audioName!,
            statusText,
            isLoading: true,
          );
        }
        return _buildPlayerContainer(
          context,
          audioManager,
          audioName!,
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
    return Consumer<JsonThemeProvider>(builder : (context , themeprovider,child){
            final currentThemeData = themeprovider.themeData;
      final colorScheme = currentThemeData.colorScheme;
    return  GestureDetector(
      onTap: isLoading||audioManager.AError!="none" ? null :() => _navigateToPlayerScreen(context),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isLoading
              ? colorScheme.inversePrimary
              : colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow,
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
                    :audioManager.AError!="none"?const SizedBox(
                        width: 60,
                        height: 60,
                        child: Icon(Icons.error,color: Colors.white),
                      ):
                    Image.network(
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
                    style:  TextStyle(
                      color: isLoading? colorScheme.inverseSurface :colorScheme.surface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: isLoading? colorScheme.inverseSurface.withOpacity(0.7) :colorScheme.surface.withOpacity(0.7),
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
                    color: isLoading? colorScheme.inverseSurface :colorScheme.surface,
                  ),
                  onPressed: isLoading||audioManager.AError!="none" ? null : audioManager.togglePlayPause,
                ),
                IconButton(
                  icon:  Icon(Icons.stop, color: isLoading? colorScheme.inverseSurface :colorScheme.surface),
                  onPressed: isLoading||audioManager.AError!="none" ? null : audioManager.stopAudio,
                ),
              ],
            ),
          ],
        ),
      ),
    );
    }) ;
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
