import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'KhinsiderAlbums.dart';

class HiveService extends ChangeNotifier {
  static late Box<dynamic> playlistBox; 
  static late Box<Map<dynamic, dynamic>> fav;
static Future<void> initBox() async {
  await Hive.initFlutter();  
  playlistBox = await Hive.openBox<dynamic>('playlists');
  fav = await Hive.openBox<Map<dynamic, dynamic>>('favorites');



}

  void addFavorite(KhinAudio audio) {
    fav.put(audio.audiolink, audio.toMap());
    notifyListeners();
  }

  void removeFavorite(String url) {
    fav.delete(url);
    notifyListeners();
  }

  bool isFav(KhinAudio item) {
    return fav.containsKey(item.audiolink);
  }

  List<KhinAudio>? getFavorites() {
    if (fav.isEmpty) {
      return [];
    } else {
      return fav.values.map((item) {
        return KhinAudio.fromMap(item);
      }).toList();
    }
  }

  void createPlaylist(String playlistName) {
    if (!playlistBox.containsKey(playlistName)) {
      playlistBox.put(playlistName, <Map<String, dynamic>>[]);
    }
    notifyListeners();
  }

  List<String> getAllPlaylists() {
    return playlistBox.keys.cast<String>().toList();
  }

void addToPlaylist(String playlistName, KhinAudio audio) async {
  List<KhinAudio>? playlist = getPlaylist(playlistName);

  if (playlist != null && !playlist.any((item) => item.audiolink == audio.audiolink)) {
    playlist.add(audio);
    List<Map<String, dynamic>> mappedList =
        playlist.map((item) => item.toMap()).toList();

    await playlistBox.put(playlistName, mappedList); 
    await playlistBox.flush(); 
    notifyListeners();
  }
}

List<KhinAudio>? getPlaylist(String playlistName) {
  if (!playlistBox.isOpen) return [];

  try {
    final storedData = playlistBox.get(playlistName);
    if (storedData == null) return [];

    if (storedData is List) {
      return storedData
          .whereType<Map>()
          .map((item) => KhinAudio.fromMap(Map<String, dynamic>.from(item)))
          .toList(); 
    }
    
    return [];
  } catch (e) {
    print("Error reading playlist '$playlistName': $e");
    return [];
  }
}
  
List<String> returnPlaylist(String audio) {
  List<String> plList = [];

  for (String name in getAllPlaylists()) {
    final playlist = getPlaylist(name);
    
    if (playlist != null && playlist.any((item) {
      final match = item.audioname.trim() == audio.trim();
      return match;
    })) {
      plList.add(name);
    }
  }
  return plList;
}
  
}
