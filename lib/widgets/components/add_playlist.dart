import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/KhinsiderAlbums.dart';
import 'package:theway/Providers/hive_service.dart';
import 'package:theway/l10n/app_localizations.dart';
import 'package:theway/widgets/playlist_mg.dart';

class AddPlaylist extends StatelessWidget {
  final KhinAudio selectedAudio;
  const AddPlaylist({super.key, required this.selectedAudio});

  @override
  Widget build(BuildContext context) {
     final inputController = TextEditingController();
    final hiveManager =Provider.of<HiveService>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
      
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.translate("inputMsg"),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: inputController,
            decoration: InputDecoration(
              hintText: "...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              hiveManager.createPlaylist(inputController.text);
              Navigator.pop(context);
                showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: PlaylistMg(selectedAudio: selectedAudio));//add the selected audio from teh first input
                },
              );
            },
            icon: const Icon(Icons.check),
            label: Text(AppLocalizations.of(context)!.translate("Apply")),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}