import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/AudioPlayer.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/Providers/KhinsiderAlbums.dart';
import 'package:theway/l10n/app_localizations.dart';

class AudioListWidget extends StatelessWidget {
  final List<KhinAudio> audios;
  final EdgeInsets? padding;

  const AudioListWidget({
    super.key,
    required this.audios,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JsonThemeProvider>(
      builder: (context, themeprovider, child) {
        final currentThemeData = themeprovider.themeData;
        final colorScheme = currentThemeData.colorScheme;

        if (audios.isEmpty) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.translate("Empty"),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          );
        }

        return Consumer<AudioManager>(
          builder: (context, audioManager, child) {
            return Scrollbar(
              child: ListView.builder(
                padding: padding ?? const EdgeInsets.only(top: 120, bottom: 120),
                itemCount: audios.length,
                itemBuilder: (context, index) {
                  final currentUrl = audioManager.currentAudio?.audiolink;
                  final isPlayingIndex = currentUrl != null &&
                      audios[index].audiolink == currentUrl;
                  final isPlaying = isPlayingIndex && audioManager.isPlaying;
                  final isLoading = isPlayingIndex && audioManager.isLoading;

                  return GestureDetector(
                    onTap: () {
                      if (!isPlayingIndex) {
                        audioManager.playAudio(audios[index]);
                      } else {
                        audioManager.togglePlayPause();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isPlayingIndex
                            ? LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primaryFixedDim,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  colorScheme.secondaryFixedDim,
                                  colorScheme.primaryFixed,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.inverseSurface.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          isLoading
                              ? const SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  (isPlaying)
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  size: 30,
                                  color: isPlayingIndex
                                      ? colorScheme.onInverseSurface
                                      : colorScheme.inverseSurface,
                                ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              Localizations.localeOf(context).languageCode == 'en' &&
                                      audios[index].audioNameEx != null &&
                                      audios[index].audioNameEx != ""
                                  ? audios[index].audioNameEx!
                                  : audios[index].audioname,
                              style: TextStyle(
                                fontSize: 16,
                                color: isPlayingIndex
                                    ? colorScheme.onInverseSurface
                                    : colorScheme.inverseSurface.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}