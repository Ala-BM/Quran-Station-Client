import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../Classes/KhinsiderAlbums.dart';

class HiveService extends ChangeNotifier {
  static late Box<dynamic> playlistBox; // Changed to dynamic
  static late Box<Map<dynamic, dynamic>> fav;
static Future<void> initBox() async {
  await Hive.initFlutter();  // Ensure Hive is initialized
  playlistBox = await Hive.openBox<dynamic>('playlists');
  fav = await Hive.openBox<Map<dynamic, dynamic>>('favorites');

  print("✅ Hive Loaded Successfully");
  print("📦 Existing Playlists: ${playlistBox.keys.toList()}");

  for (var key in playlistBox.keys) {
    print("📂 Playlist '$key' contents: ${playlistBox.get(key)}");
  }
}

  void addFavorite(KhinAudio audio) {
    fav.put(audio.audiolink, audio.toMap());
    notifyListeners();
  }

  void removeFavorite(String url) {
    debugPrint("PLEASE WORK FOR EVERYONE'S SAKE");
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

    await playlistBox.put(playlistName, mappedList); // 🔄 Force save to Hive
    await playlistBox.flush(); // 🔄 Ensure it's written to disk

    print("Saved Playlist Content: ${playlistBox.get(playlistName)}"); // ✅ Debugging stored data
    notifyListeners();
  }
}

List<KhinAudio>? getPlaylist(String playlistName) {
  if (!playlistBox.isOpen) return [];

  try {
    final storedData = playlistBox.get(playlistName);
    if (storedData == null) return [];

    if (storedData is List) {
      // Explicitly convert to List<KhinAudio>
      return storedData
          .whereType<Map>()
          .map((item) => KhinAudio.fromMap(Map<String, dynamic>.from(item)))
          .toList(); // Add .toList() to convert Iterable to List
    }
    
    return [];
  } catch (e) {
    print("Error reading playlist '$playlistName': $e");
    return [];
  }
}
  
List<String> returnPlaylist(String audio) {
  List<String> plList = [];
  print('1. Searching for audio: $audio'); // First print

  for (String name in getAllPlaylists()) {
    final playlist = getPlaylist(name);
    print('2. Playlist "$name": $playlist'); // Debug playlist contents
    
    if (playlist != null && playlist.any((item) {
      final match = item.audioname.trim() == audio.trim();
      print('3. Comparing "${item.audioname}" with "$audio": $match');
      return match;
    })) {
      plList.add(name);
    }
  }

  print('4. Audio exists in: $plList'); // Last print
  return plList;
}
  
}
