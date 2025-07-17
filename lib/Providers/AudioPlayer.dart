import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'audio_handler.dart';
import '../Providers/KhinsiderAlbums.dart';

class AudioManager extends ChangeNotifier {
  MyAudioHandler? _audioHandler;
  bool _isInitialized = false;
  bool _isInitializing = false;

  AudioManager() {
    _initAudioService();
  }

  bool get isInitialized => _isInitialized;

  Future<void> _initAudioService() async {

    if (_isInitialized || _isInitializing) return;
    
    _isInitializing = true;
    print("Starting audio service initialization...");
    
    try {
      final handler = await AudioService.init(
        builder: () {
          print("Building audio handler...");
          return MyAudioHandler();
        },
        config:  const AudioServiceConfig(
          androidNotificationChannelId: 'com.example.theway.audio',
          androidNotificationChannelName: 'Audio Player',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
      
      print("Audio handler created successfully!");
      _audioHandler = handler;
      _audioHandler!.isPlayingStream.addListener(() {
        print("Play state changed: ${_audioHandler!.isPlayingStream.value}");
        notifyListeners();
      });
      
      _audioHandler!.isLoadingStream.addListener(() {
        print("Loading state changed: ${_audioHandler!.isLoadingStream.value}");
        notifyListeners();
      });
      
      _audioHandler!.isBufferingStream.addListener(() {
        print("Buffer state changed: ${_audioHandler!.isBufferingStream.value}");
        notifyListeners();
      });
      
      _audioHandler!.currentAudioStream.addListener(() {
        print("Current audio changed: ${_audioHandler!.currentAudioStream.value?.audioname}");
        notifyListeners();
      });
         _audioHandler!.currentAudioStream.addListener(() {
        print("Current audio changed: ${_audioHandler!.currentAudioStream.value?.audioname}");
        notifyListeners();
      });
       _audioHandler!.isError.addListener(() {
        print("Error: ${_audioHandler!.isError.value}");
        notifyListeners();
      });
      
      _isInitialized = true;
      _isInitializing = false;
      print("Audio service initialization complete!");
      notifyListeners();
    } catch (e) {
      _isInitializing = false;
      print("Error initializing audio service: $e");
      Future.delayed(const Duration(seconds: 2), _initAudioService);
    }
  }
  
  AudioPlayer get audioPlayer => _audioHandler?.player ?? AudioPlayer();
  KhinAudio? get currentAudio => _audioHandler?.currentAudio;
  String? get AError => _audioHandler?.isError.value ;
  bool get isPlaying => _audioHandler?.isPlaying ?? false;
  bool get isLoading => _audioHandler?.isLoading ?? false;
  bool get isBuffering => _audioHandler?.isBufferingStream.value ?? false;

  Future<void> loadPlaylist(List<KhinAudio> audios) async {
    await _ensureInitialized();
    return _audioHandler?.loadPlaylist(audios) ?? Future.value();
  }
  
  Future<void> playAudio(KhinAudio? audio) async {
    await _ensureInitialized();
    return _audioHandler?.playAudio(audio) ?? Future.value();
  }
  
  Future<void> playNextAudio() async {
    await _ensureInitialized();
    return _audioHandler?.playNext() ?? Future.value();
  }
  
  Future<void> playPrevAudio() async {
    await _ensureInitialized();
    return _audioHandler?.playPrevious() ?? Future.value();
  }
  
  Future<void> pauseAudio() async {
    await _ensureInitialized();
    _audioHandler?.pauseAudio();
  }
  
  Future<void> stopAudio() async {
    await _ensureInitialized();
    _audioHandler?.stopAudio();
  }
  
  Future<void> togglePlayPause() async {
    await _ensureInitialized();
    _audioHandler?.togglePlayPause();
  }

   Future<void> handleSongEnd() async {

 await _ensureInitialized();

_audioHandler?.handleSongEnd();

 }
  
  Future<bool> checkPlaying(String audioId) async {
    await _ensureInitialized();
    return _audioHandler?.checkPlaying(audioId) ?? false;
  }

<<<<<<< HEAD
  bool get isShuffle => _audioHandler?.isShuffle ?? false;
  bool get isRepeat => _audioHandler?.isRepeat ?? false;
  
  Future<bool> _ensureInitialized() async {
    if (_isInitialized) return true;
    
    print("Waiting for audio service to initialize...");

    if (!_isInitializing) {
      print("Triggering initialization...");
      await _initAudioService();
=======
      if (audioPlayer.playing) {
        final position = audioPlayer.position;
        await audioPlayer.setFilePath(filePath);
        audioPlayer.seek(position);
        print("Switched to cached file!");
      }
>>>>>>> 5c59ece3efbe65697d064afb7fdd737c96b084ce
    }
    
    final stopwatch = Stopwatch()..start();
    while (!_isInitialized && stopwatch.elapsed < const Duration(seconds: 10)) {
      await Future.delayed(const Duration(milliseconds: 200));
      print("Still waiting for initialization... ${stopwatch.elapsed.inMilliseconds}ms");
    }
    
    if (!_isInitialized) {
      print("Warning: AudioManager not initialized after waiting ${stopwatch.elapsed.inSeconds} seconds");
      _isInitializing = false;
      _initAudioService();
      return false;
    }
    
    print("Audio service initialized successfully!");
    return true;
  }
  
  Future<void> toggleShuffle() async {
    await _ensureInitialized();
    if (_audioHandler != null) {
      _audioHandler!.toggleShuffle();
      _audioHandler!.setShuffleMode(
        _audioHandler!.isShuffle ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none
      );
      notifyListeners();
    }
  }
  
  Future<void> toggleRepeat() async {
    await _ensureInitialized();
    if (_audioHandler != null) {
      _audioHandler!.toggleRepeat();
      _audioHandler!.setRepeatMode(
        _audioHandler!.isRepeat ? AudioServiceRepeatMode.one : AudioServiceRepeatMode.none
      );
      notifyListeners();
    }
  }
  
  Future<void> setLoading(bool value) async {
    await _ensureInitialized();
    _audioHandler?.setLoading(value);
    notifyListeners();
  }
  
  @override
  void dispose() {
    if (_audioHandler != null) {
      _audioHandler!.isPlayingStream.removeListener(notifyListeners);
      _audioHandler!.isLoadingStream.removeListener(notifyListeners);
      _audioHandler!.isBufferingStream.removeListener(notifyListeners);
      _audioHandler!.currentAudioStream.removeListener(notifyListeners);
      _audioHandler!.isError.removeListener(notifyListeners);
    }
    super.dispose();
  }
}