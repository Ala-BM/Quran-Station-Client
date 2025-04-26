import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import '../Providers/KhinsiderAlbums.dart';

class AudioManager extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  KhinAudio? _currentAudio;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;

  KhinAudio? get currentAudio => _currentAudio;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  List<KhinAudio> _playlist = [];
  int _currentIndex = 0;
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  bool isShuffle = false;
  bool isRepeat = false;



  void toggleShuffle() {
    isShuffle = !isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    isRepeat = !isRepeat;
    notifyListeners();
  }

  Future<void> loadPlaylist(List<KhinAudio> audios) async {
    _playlist = audios;
    _currentIndex = 0;
    if (_playlist.isNotEmpty) {
      await playAudio(_playlist[_currentIndex]);
    }
  }
  //Play Next Audio
  Future<void> playNextAudio  () async{
    if(isShuffle){
// Repeat if it's the same as the current one
      _currentIndex = randomShuffle(_currentIndex);

    }
    if(_currentIndex <_playlist.length -1){
      _currentIndex++;
      await playAudio(_playlist[_currentIndex]);
    }
     else   if(_currentIndex ==_playlist.length -1){
      _currentIndex=0;
      await playAudio(_playlist[_currentIndex]);
    } 
  }
    Future<void> playPrevAudio  () async{
    if(_currentIndex > 0){
      _currentIndex--;
      await playAudio(_playlist[_currentIndex]);
    }
     else   if(_currentIndex ==0 && _playlist.isNotEmpty){
      _currentIndex=_playlist.length -1;
      await playAudio(_playlist[_currentIndex]);
    } 
  }
  // Play a new audio
  Future<void> playAudio(KhinAudio? audio) async {
    if (_playlist.contains(audio)){//change index to the current audio
    print("IndexBEFORE£$_currentIndex");//THIS IS NOT WORKING
    _currentIndex=_playlist.indexWhere((item)=>item==audio);
    print("IndexAfter$_currentIndex");}
    else {
      //add audio to playlist
      _playlist.add(audio!);
      _currentIndex=_playlist.length-1;
    }
    try {
      final _url;
      //print("yeah so this is the link ${audio?.audiolink}");
      setLoading(true);
      /*if(audio!.audiolink.contains("khinsider")){
        _url = await fetchLink(audio.audiolink);
      } else {*/
        _url=audio?.audiolink;
     // used to track khinsider audio ,abandoned for now }
      
      _currentAudio = audio;
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          "${directory.path}/${Uri.parse(audio!.id).pathSegments.last}";
      final file = File(filePath);
      if (file.existsSync()) {
        await audioPlayer.setFilePath(filePath);
        audioPlayer.play();
        _isPlaying = true;
        notifyListeners();
      } else {
        print("Streaming while caching...");
        await audioPlayer.setUrl(_url);
        audioPlayer.play();
        _isPlaying = true;
        notifyListeners();
        //cacheAudio(_url, filePath); // Start caching in the background , need condition on live audio
      }
    } catch (e) {
      print("Error playing audio: $e");
    } finally {
      setLoading(false);
    }
  }

  /*void cacheAudio(String url, String filePath) async {
    final file = File(filePath);

    if (!file.existsSync()) {
      print("Downloading and caching audio...");

      await Dio().download(url, filePath, onReceiveProgress: (received, total) {
        double progress = (received / total) * 100;
        print("Caching: $progress%");
      });

      print("Download complete: Cached at $filePath");

      if (audioPlayer.playing) {
        final position = audioPlayer.position;
        await audioPlayer.setFilePath(filePath);
        audioPlayer.seek(position);
        print("Switched to cached file!");
      }
    }
  }*/

  void pauseAudio() {
    audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void stopAudio() {
    audioPlayer.stop();
    _currentAudio = null;
    _isPlaying = false;
    notifyListeners();
  }

  bool checkPlaying(String audio) {
    final currentPlaying = audioPlayer.sequenceState?.currentSource;
    if (currentPlaying is ProgressiveAudioSource) {
      String? currentUrl = currentPlaying.uri.toString();
      if (currentUrl == audio) {
        return true;
      }
    }
    return false;
  }

  void togglePlayPause() {
    if (_isPlaying) {
      pauseAudio();
    } else {
      audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

void handleSongEnd() {
  if(isRepeat){
      audioPlayer.seek(Duration.zero);
      return;
    }else {
  if (_playlist.length == 1) {
    pauseAudio(); 
    return; 
  }

  // Ensure we only play next if the player is actually done
 else if (audioPlayer.processingState == ProcessingState.completed) {
    playNextAudio();
    return;
  }}
}
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  int randomShuffle (int _currentIndex)
  {
    int newIndex;
  do {
    newIndex = Random().nextInt(_playlist.length);
  } while (newIndex == _currentIndex); 

  return newIndex;
  }
}
