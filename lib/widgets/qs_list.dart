import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theway/Providers/hive_service.dart';
import 'package:theway/Providers/cnx_plus_provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/widgets/error_handle.dart';
import '../Providers/KhinsiderAlbums.dart';
import '../Services/qsscrapper.dart';
import 'filterQS.dart';
import 'search_bar.dart';
import 'audio_list.dart';
import 'package:provider/provider.dart';

class Qslist extends StatefulWidget {
  const Qslist({super.key, required this.onLanguageChange});
  final VoidCallback onLanguageChange;
  
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
      filteredAudios = allAudios
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
              .where((audio) => audio.catEx?.toLowerCase() == cat?.toLowerCase())
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
      },
    );
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
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            
                            if (snapshot.hasError) {
                              if (snapshot.error is QSScrapperException) {
                                return ErrorHandle(
                                  error: _lastError,
                                  onRetry: _loadData,
                                );
                              } else {
                                return ErrorHandle(
                                  error: snapshot.error,
                                  onRetry: _loadData,
                                );
                              }
                            }
                            
                            return AudioListWidget(audios: filteredAudios);
                          },
                        )
                      : ErrorHandle(
                          error: QSScrapperException(
                            'No Internet Detected',
                            QSErrorType.networkError,
                          ),
                          onRetry: _loadData,
                        );
                },
              ),
              SearchBarWidget(
                controller: _searchController,
                onChanged: _filterAudios,
                onLanguageToggle: widget.onLanguageChange,
                onFilterPressed: () => _showFilterQs(context),
              ),
            ],
          ),
        );
      },
    );
  }
}