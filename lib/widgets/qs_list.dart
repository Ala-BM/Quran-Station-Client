import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theway/Providers/AudioPlayer.dart';
import 'package:theway/Providers/hive_service.dart';
import 'package:theway/Providers/cnx_plus_provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/l10n/app_localizations.dart';
import 'package:theway/widgets/error_handle.dart';
import '../Providers/KhinsiderAlbums.dart';
import '../Services/qsscrapper.dart';
import 'filterQS.dart';
import 'package:provider/provider.dart';

class Qslist extends StatefulWidget {
  const Qslist({super.key, required this.onLanguageChange});
  final void Function(Locale locale) onLanguageChange;
  @override
  State<Qslist> createState() => _QslistState();
}

class _QslistState extends State<Qslist> {
  VoidCallback? _stationListener;
  late Future<List<KhinAudio>> srcAudios;
  Qsscrapper scraper = Qsscrapper();
  late ConnectionProvider cnxProvider;
  int? playingIndex;
  List<KhinAudio> allAudios = [];
  late HiveService hiveManager;
  List<KhinAudio> filteredAudios = [];
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<PlayerState>? _audioSubscription;
  late String currentCat;
  String currentPS = "";
  Object? _lastError; 

  @override
  void initState() {
    super.initState();
    hiveManager = Provider.of<HiveService>(context, listen: false);
    currentCat = "All Categories";
  srcAudios = scraper.fetchDataQSstations().then((audios) {
    if (mounted) {
      setState(() {
        allAudios = audios;
        filteredAudios = List.from(allAudios);
      });
    }
    return audios;
  }).catchError((error) {
    print("Caught error, passing to FutureBuilder: $error");
    throw error; 
  });
    _stationListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    scraper.station.addListener(_stationListener!);
  }

  void _loadData() {
    setState(() {
      srcAudios = _safeLoadData();
          srcAudios.then((audios) {
      if (mounted) {
        setState(() {
          allAudios = audios;
          filteredAudios = List.from(allAudios);
        });
      }
    });
    });
  }
  
Future<List<KhinAudio>> _safeLoadData() async {
  try {
    return await scraper.fetchDataQSstations();
  } catch (e) {
    return Future.error(e);
  }
}

  Future<void> sourceChange(String plsn) async {
    if (scraper.station.value == 1) {
      srcAudios = scraper.fetchDataQSstations();
      currentPS = "";
    } else if (scraper.station.value == 0) {
      srcAudios = scraper.fetchDataQS();
      currentPS = "";
    } else if (scraper.station.value == 2) {
      var playlist = hiveManager.getPlaylist(plsn);
      srcAudios = Future.value(playlist);
      currentPS = plsn;
    }

    final audios = await srcAudios;
    if (!mounted) return;

    setState(() {
      allAudios = audios;
      filteredAudios = List.from(allAudios);
      if (scraper.station.value != 1) {
        currentCat = "All Categories";
      }
    });
  }

  @override
  void dispose() {
    if (_stationListener != null) {
      scraper.station.removeListener(_stationListener!);
    }
    _audioSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAudios(String query) {
    setState(() {
      filteredAudios = allAudios //This reset filter should i keep it ?
          .where((audio) =>
              audio.audioname.toLowerCase().contains(query.toLowerCase()) ||
              audio.audioNameEx!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterAudiosByCat(String? cat, bool langAr) {
    if (scraper.station.value == 1) {
      if (cat != "All Categories") {
        setState(() {
          filteredAudios = allAudios
              .where(
                  (audio) => audio.catEx?.toLowerCase() == cat?.toLowerCase())
              .toList();
          currentCat = cat!;
        });
      } else {
        setState(() {
          filteredAudios = List.from(allAudios);
          currentCat = cat!;
        });
      }
    }
  }

  void _showFilterQs(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return SizedBox(
            child: Filterqs(
              scraper: scraper,
              onCategoryChanged: sourceChange,
              onSubCategoryChanged: _filterAudiosByCat,
              currentCat: currentCat,
              currentPS: currentPS,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<JsonThemeProvider>(
        builder: (context, themeprovider, child) {
      final currentThemeData = themeprovider.themeData;
      final colorScheme = currentThemeData.colorScheme;
      return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Stack(
            children: [
              Consumer<ConnectionProvider>(
                  builder: (context, cnxProvider, child) {
                return cnxProvider.isConnected
                    ? FutureBuilder<List<KhinAudio>>(
                        future: srcAudios,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                    if (snapshot.hasError) {
                      if (snapshot.error is QSScrapperException) {
                          return ErrorHandle(
                            error: _lastError,
                            onRetry: (){
                              _loadData();
                            }, 
                          );
                        }
                       else {
                        return ErrorHandle(
                          error: snapshot.error,
                          onRetry: (){
                            _loadData();
                          }, 
                        );
                      }
                    } else if (filteredAudios.isEmpty) {
                      return Center(
                          child: Text(AppLocalizations.of(context)!
                              .translate("Empty"),style:TextStyle(color: colorScheme.onSurface) ,));
                              
                    }

                          return Consumer<AudioManager>(
                              builder: (context, audioManager, child) {
                            return Scrollbar(
                                child: ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 120, bottom: 120),
                              itemCount: filteredAudios.length,
                              itemBuilder: (context, index) {
                                final currentUrl =
                                    audioManager.currentAudio?.audiolink;
                                final isPlayingIndex = currentUrl != null &&
                                    filteredAudios[index].audiolink ==
                                        currentUrl;
                                final isPlaying =
                                    isPlayingIndex && audioManager.isPlaying;
                                final isLoading =
                                    isPlayingIndex && audioManager.isLoading;
                                return GestureDetector(
                                  onTap: () {
                                    if (!isPlayingIndex) {
                                      audioManager
                                          .playAudio(filteredAudios[index]);
                                    } else {
                                      audioManager.togglePlayPause();
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
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
                                                colorScheme.primaryFixed
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colorScheme.inverseSurface
                                              .withOpacity(0.2),
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
                                                child:
                                                    CircularProgressIndicator(
                                                        color: Colors.white),
                                              )
                                            : Icon(
                                                (isPlaying)
                                                    ? Icons.pause_circle_filled
                                                    : Icons.play_circle_filled,
                                                size: 30,
                                                color: isPlayingIndex
                                                    ? colorScheme
                                                        .onInverseSurface
                                                    : colorScheme
                                                        .inverseSurface,
                                              ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Text(
                                            Localizations.localeOf(context)
                                                            .languageCode ==
                                                        'en' &&
                                                    filteredAudios[index]
                                                            .audioNameEx !=
                                                        null &&
                                                    filteredAudios[index]
                                                            .audioNameEx !=
                                                        ""
                                                ? filteredAudios[index]
                                                    .audioNameEx! // check for english
                                                : filteredAudios[index]
                                                    .audioname,
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
                            ));
                          });
                        },
                      )
                    :     ErrorHandle(
                          error:QSScrapperException(
        'No Internet Detected',
        QSErrorType.networkError
      ),
                          onRetry: (){
                            _loadData();
                          }, 
                        );
              }),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.surface,
                            colorScheme.surface.withOpacity(0.9),
                            colorScheme.surface.withOpacity(0.7),
                            colorScheme.surface.withOpacity(0.5),
                            colorScheme.surface.withOpacity(0.0),
                          ],
                          stops: const [
                            0.0,
                            0.3,
                            0.6,
                            0.8,
                            1.0
                          ], 
                        ),
                      ),
                      child: Row(children: [
                        Expanded(
                            child: Container(
                          margin: const EdgeInsets.only(
                              top: 60, bottom: 20, left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.inverseSurface.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            textDirection: Directionality.of(context),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!
                                  .translate("Search"),
                              hintTextDirection: Directionality.of(context),
                              border: InputBorder.none,
                            ),
                            onChanged: _filterAudios,
                          ),
                        )),
                        Container(
                            margin: const EdgeInsets.only(top: 40),
                            child: IconButton(
                              onPressed: () {
                                Locale newLocale =
                                    Localizations.localeOf(context)
                                                .languageCode ==
                                            'en'
                                        ? const Locale('ar')
                                        : const Locale('en');
                                widget.onLanguageChange(newLocale);
                              },
                              iconSize: 30,
                              icon: Image.asset(
                                'assets/icons/ar_en.png',
                                color: colorScheme.inverseSurface,
                                width: 30,
                                height: 30,
                              ),
                            )),
                        Container(
                            margin: const EdgeInsets.only(top: 40),
                            child: IconButton(
                              onPressed: () => _showFilterQs(context),
                              iconSize: 30,
                              icon: const Icon(Icons.more_vert),
                            ))
                      ])))
            ],
          ));
    });
  }
}
