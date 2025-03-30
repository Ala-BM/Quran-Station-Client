import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:theway/Classes/AudioPlayer.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../Classes/KhinsiderAlbums.dart';
import '../Services/qsscrapper.dart';
import 'filterQS.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class Qslist extends StatefulWidget {
  const Qslist({super.key, required this.onLanguageChange});
  final void Function(Locale locale) onLanguageChange;
  @override
  State<Qslist> createState() => _QslistState();
}

class _QslistState extends State<Qslist> {
  late Future<List<KhinAudio>> srcAudios;
  Qsscrapper scraper = Qsscrapper();
  late AudioManager _audioManager;
  int? playingIndex;
  List<KhinAudio> allAudios = [];
  List<KhinAudio> filteredAudios = [];
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<PlayerState>? _audioSubscription;
  late String currentCat;

  @override
  void initState() {
    super.initState();
    currentCat ="All Categories";
    srcAudios = scraper.fetchDataQSstations();
    srcAudios.then((audios) {
      setState(() {
        allAudios = audios;
        filteredAudios = List.from(allAudios);
      });
    });
    scraper.station.addListener(() {
      setState(() {}); // Forces UI to update when category changes
    });
  }

Future<void> sourceChange() async {
  if (scraper.station.value == true) {
    srcAudios = Qsscrapper().fetchDataQSstations();
    await srcAudios.then((audios) { // Ensure `await` before proceeding
      setState(() {
        allAudios = audios;
        filteredAudios = List.from(allAudios);
      });
    });
  } else {
    srcAudios = Qsscrapper().fetchDataQS();
    await srcAudios.then((audios) { // Ensure `await` before proceeding
      setState(() {
        currentCat = "All Categories";
        allAudios = audios;
        filteredAudios = List.from(allAudios);
      });
    });
  }
}


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
   
    _audioManager = Provider.of<AudioManager>(context, listen: false);

    _audioSubscription?.cancel();
    _audioSubscription =
        _audioManager.audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        final currentUrl = _audioManager.currentAudio?.audiolink;
        playingIndex = _findPlayingIndex(currentUrl);
      });
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAudios(String query) {
    setState(() {
      filteredAudios = allAudios//This reset filter should i keep it ?
          .where((audio) =>
              audio.audioname.toLowerCase().contains(query.toLowerCase())||audio.audioNameEx!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterAudiosByCat(String? cat, bool langAr) {
    if(scraper.station.value==true){
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
    }}
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
            ),
          );
        });
  }

  int? _findPlayingIndex(String? currentUrl) {
    if (currentUrl == null) return null;
    int index =
        filteredAudios.indexWhere((audio) => audio.audiolink == currentUrl);
    return index != -1 ? index : null;
  }

  @override
  Widget build(BuildContext context) {
    final audioManager = Provider.of<AudioManager>(context);
    return Scaffold(
        body: Stack(
      children: [
        FutureBuilder<List<KhinAudio>>(
          future: srcAudios,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (filteredAudios.isEmpty) {
              return Center(child: Text(AppLocalizations.of(context)!.translate("Empty")));
            }

            return Scrollbar(
                child: ListView.builder(
              padding: const EdgeInsets.only(top: 120, bottom: 120),
              itemCount: filteredAudios.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (playingIndex != index) {
                      audioManager.playAudio(filteredAudios[index]);
                    } else {
                      audioManager.togglePlayPause();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: playingIndex == index
                          ? LinearGradient(
                              colors: [
                                Colors.blue.shade700,
                                Colors.blue.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade300,
                                Colors.grey.shade100
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                            audioManager.isLoading && playingIndex == index ?        const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(color: Colors.white),
                ):
                        Icon(
                         
                          
                          (playingIndex == index && _audioManager.isPlaying)
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          size: 30,
                          color: playingIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            Localizations.localeOf(context).languageCode ==
                                        'en' &&
                                    filteredAudios[index].audioNameEx != null
                                ? filteredAudios[index]
                                    .audioNameEx! // Use audioNameEx if conditions are met
                                : filteredAudios[index].audioname,
                            style: TextStyle(
                              fontSize: 16,
                              color: playingIndex == index
                                  ? Colors.white
                                  : Colors.black,
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
          },
        ),
        Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                      Colors.white.withOpacity(0.5),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [
                      0.0,
                      0.3,
                      0.6,
                      0.8,
                      1.0
                    ], // Control the transition points
                  ),
                ),
                child: Row(children: [
                  Expanded(
                      child: Container(
                    margin:
                        const EdgeInsets.only(top: 60, bottom: 20, left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      textDirection: Directionality.of(context),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.translate("Search"),
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
                              Localizations.localeOf(context).languageCode ==
                                      'en'
                                  ? const Locale('ar')
                                  : const Locale('en');
                          widget.onLanguageChange(newLocale);
                        },
                        iconSize: 30,
                        icon: SvgPicture.asset(
                          'assets/icons/ar_en.svg',
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
  }
}
