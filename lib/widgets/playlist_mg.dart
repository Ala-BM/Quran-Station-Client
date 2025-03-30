import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Classes/KhinsiderAlbums.dart';
import 'package:theway/Services/hive_service.dart';
import 'package:theway/widgets/add_playlist.dart';

class PlaylistMg extends StatefulWidget {
  final KhinAudio selectedAudio;
  const PlaylistMg({super.key, required this.selectedAudio});

  @override
  State<PlaylistMg> createState() => _PlaylistMgState();
}

class _PlaylistMgState extends State<PlaylistMg> {
  late List<String> playlist;

  @override
  void didChangeDependencies() {
    final hiveManager = Provider.of<HiveService>(context);
    playlist = hiveManager.getAllPlaylists();
    print(playlist);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final hiveManager = Provider.of<HiveService>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Prevents unnecessary space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manage Playlist",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          playlist.isEmpty
              ? SizedBox(
                  width: double.infinity, // Takes full width of the modal
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.do_disturb, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text(
                        "No playlists found",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : SizedBox(
                  height: 200, // Limit height
                  child: ListView.builder(
  shrinkWrap: true,
  itemCount: playlist.length,
  itemBuilder: (context, index) {
    bool isSelected = hiveManager
        .returnPlaylist(widget.selectedAudio.audioname)
        .contains(playlist[index]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
      child: Material(
        elevation: isSelected ? 4 : 2, // Elevation for depth
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.blue : Colors.white,
        child: ListTile(
          title: Text(
            playlist[index],
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onTap: () {
            hiveManager.addToPlaylist(playlist[index], widget.selectedAudio);
            Navigator.pop(context);
          },
          trailing: Icon(
            Icons.add,
            color: isSelected ? Colors.white : Colors.blue,
          ),
        ),
      ),
    );
  },
)
,
                ),

          const SizedBox(height: 10),

          // Add New Button
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const AddPlaylist());
                },
              );
              // Show input field to add a new playlist
            },
            icon: const Icon(Icons.add, color: Colors.blue),
            label: const Text("Create New Playlist",
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
