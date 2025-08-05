import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';
import 'KhinsiderAlbums.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final _playlist = <MediaItem>[];
  List<KhinAudio> _khinAudios = [];
  int _currentIndex = 0;
  bool _isLoading = false;
  bool isShuffle = false;
  bool isRepeat = false;
  KhinAudio? _currentAudio;


  final _isPlayingStream = ValueNotifier<bool>(false);
  final _isLoadingStream = ValueNotifier<bool>(false);
  final _isBufferingStream = ValueNotifier<bool>(false);
  final _isError = ValueNotifier<String>("none");
  final _currentAudioStream = ValueNotifier<KhinAudio?>(null);

  ValueNotifier<bool> get isPlayingStream => _isPlayingStream;
  ValueNotifier<bool> get isLoadingStream => _isLoadingStream;
  ValueNotifier<bool> get isBufferingStream => _isBufferingStream;
   ValueNotifier<String> get isError => _isError;
  ValueNotifier<KhinAudio?> get currentAudioStream => _currentAudioStream;
  AudioPlayer get player => _player;
  KhinAudio? get currentAudio => _currentAudio;
  bool get isPlaying => _player.playing;
  bool get isLoading => _isLoading;

MyAudioHandler() {
  _init();
}

void _init() {
  _player.playbackEventStream.listen(_broadcastState, onError: (e) {
  });

  _player.playerStateStream.listen((state) {
    if (state.processingState == ProcessingState.completed) {
      handleSongEnd();
    }
    _isBufferingStream.value = state.processingState == ProcessingState.buffering;
    
    _isPlayingStream.value = state.playing;
  }, onError: (e) {
    print("Error from player state stream: $e");
  });
}

  Future<void> loadPlaylist(List<KhinAudio> audios) async {
    _khinAudios = audios;
    _playlist.clear();
    for (var audio in audios) {
      _playlist.add(MediaItem(
        id: audio.id,
        title: audio.audioname,
        extras: {'audiolink': audio.audiolink},
      ));
    }
    
    queue.add(_playlist);
    _currentIndex = 0;
    if (_playlist.isNotEmpty) {
      await playMediaItem(_playlist[_currentIndex]);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    _isLoadingStream.value = value;
  }

  @override
  Future<void> playMediaItem(MediaItem item) async {
     setError("none");
    setLoading(true);
    
    try {
      final audio = _khinAudios.firstWhere((e) => e.audioname == item.title);
      _currentAudio = audio;
      _currentAudioStream.value = audio;
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/${Uri.parse(audio.id).pathSegments.last}";
      final file = File(filePath);
      final url = audio.audiolink;

      if (file.existsSync()) {
        await _player.setFilePath(filePath);
      } else {
        await _player.setUrl(url);
        // Optional: Cache the file in the background
        // _cacheAudio(url, filePath);
      }
      mediaItem.add(item);
      _player.play();
      _isPlayingStream.value = true;
    } catch (e) {
      setError("Failed to play audio :$e ");
    
    } finally {
      setLoading(false);
    }
  }
Future<void> playAudio(KhinAudio? audio) async {
  setError("none");
  try {
    if (audio == null) return;
    if (_khinAudios.contains(audio)) {
      _currentIndex = _khinAudios.indexWhere((item) => item.audiolink == audio.audiolink);
      print("Playing from index: $_currentIndex");
    } else {
      _khinAudios.add(audio);
      _playlist.add(MediaItem(
        id: audio.id,
        title: audio.audioname,
        extras: {'audiolink': audio.audiolink},
      ));
      queue.add(_playlist);
      _currentIndex = _playlist.length - 1;
    }
    await playMediaItem(_playlist[_currentIndex]);
  } catch (e) {
    print('Error playing media item: $e');
  }
}

  Future<void> playNext() async {
    if (isShuffle) {
      _currentIndex = _getRandomIndex();
    } else if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }
    
    await playMediaItem(_playlist[_currentIndex]);
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
    } else {
      _currentIndex = _playlist.length - 1;
    }
    
    await playMediaItem(_playlist[_currentIndex]);
  }

  void toggleShuffle() {
    isShuffle = !isShuffle;
  }

  void toggleRepeat() {
    isRepeat = !isRepeat;
  }

  void handleSongEnd() {
    if (isRepeat) {
      _player.seek(Duration.zero);
      return;
    } else {
      if (_playlist.length == 1) {
        pauseAudio();
        return;
      }
      if (_player.processingState == ProcessingState.completed) {
        playNext();
        return;
      }
    }
  }

  void togglePlayPause() {
    if (_player.playing) {
      _player.pause();
      _isPlayingStream.value = false;
    } else {
      _player.play();
      _isPlayingStream.value = true;
    }
  }

  void pauseAudio() {
    _player.pause();
    _isPlayingStream.value = false;
  }

  void stopAudio() {
    _player.stop();
    _currentAudio = null;
    _currentAudioStream.value = null;
    _isPlayingStream.value = false;
  }
  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    
    int newIndex;
    do {
      newIndex = Random().nextInt(_playlist.length);
    } while (newIndex == _currentIndex);
    
    return newIndex;
  }
  bool checkPlaying(String audioId) {
    return _currentAudio?.id == audioId && _player.playing;
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex,
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => playNext();

  @override
  Future<void> skipToPrevious() => playPrevious();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    isRepeat = repeatMode == AudioServiceRepeatMode.one;
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    isShuffle = shuffleMode == AudioServiceShuffleMode.all;
  }

  @override
  Future<void> addQueueItem(MediaItem item) async {
    final newQueue = [...queue.value, item];
    queue.add(newQueue);
  }

  @override
  Future<void> removeQueueItem(MediaItem item) async {
    final newQueue = [...queue.value]..remove(item);
    queue.add(newQueue);
  }
  
  void setError(String string) {
    if(_isError.value=="none"){
      
    _isError.value=string;}
    else {
      _isError.value="none";
    }
    
  }

  // Method to cache audio files
  /*
  void _cacheAudio(String url, String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      print("Downloading and caching audio...");

      await Dio().download(url, filePath, onReceiveProgress: (received, total) {
        double progress = (received / total) * 100;
        print("Caching: $progress%");
      });

      print("Download complete: Cached at $filePath");

      // Switch to cached file without restarting playback if still playing same track
      if (_player.playing && _currentAudio?.audiolink == url) {
        final position = _player.position;
        await _player.setFilePath(filePath);
        _player.seek(position);
        print("Switched to cached file!");
      }
    }
  }
  */
}