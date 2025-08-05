import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/hive_service.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../../Services/qsscrapper.dart';

class Filterqs extends StatefulWidget {
   const Filterqs({
    super.key,
    required this.scraper,
    required this.onCategoryChanged,
    required this.onSubCategoryChanged,
    required this.currentCat, 
    required this.currentPS,
  });

  final Qsscrapper scraper;
  final Future<void> Function(String) onCategoryChanged;
  final void Function(String?, bool) onSubCategoryChanged;
  final String currentCat;
  final  String currentPS;

  @override
  State<Filterqs> createState() => _FilterqsState();
}

class _FilterqsState extends State<Filterqs> {
  late final int initialSource;
  late String _selectedCategory;
  late String _currentPS;
  HiveService? hiveManager;
  late List<String> playlist;
  bool _initialized = false;


  @override
  void initState() {
    super.initState();
    initialSource = widget.scraper.station.value;
    _selectedCategory = widget.currentCat;
    _currentPS = widget.currentCat;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      hiveManager = Provider.of<HiveService>(context, listen: false);
      playlist = hiveManager!.getAllPlaylists();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = List<String>.from(
      AppLocalizations.of(context)!.translateList("categories"),
    );
    const List<String> categoriesEn = [
      "All Categories",
      "Quran",
      "Tafseer",
      "Rewayat Warsh A'n Nafi'",
      "Rewayat Qalon A'n Nafi'",
      "Other Rewayat",
      "Roqyah",
      "Adhkar",
      "Fatwas",
      "Biography of the Prophet",
      "Translation"
    ];

    return ValueListenableBuilder<int>(
      valueListenable: widget.scraper.station,
      builder: (context, selectedIndex, child) {
        return Directionality(textDirection: TextDirection.ltr, child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  if (widget.scraper.station.value == 2) {
                    await widget.onCategoryChanged(_currentPS);
                  }
                  if (initialSource != widget.scraper.station.value) {
                    await widget.onCategoryChanged(_currentPS);
                  }
                  if (widget.scraper.station.value == 1) {
                    widget.onSubCategoryChanged(_selectedCategory, true);
                  }
                },
                child: Text(AppLocalizations.of(context)!.translate("Apply")),
              ),
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 20,
              indent: 10,
              endIndent: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: [
                        Alignment.centerLeft,
                        Alignment.center,
                        Alignment.centerRight
                      ][selectedIndex],
                      child: FractionallySizedBox(
                        widthFactor: 1 / 3,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildToggleButton(
                            context, "SahabaStories", 0, selectedIndex),
                        _buildToggleButton(
                            context, "Radio Stations", 1, selectedIndex),
                        _buildToggleButton(
                            context, "Playlists", 2, selectedIndex),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (selectedIndex == 1)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        AppLocalizations.of(context)!.translate("Category"),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedCategory,
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      items: categories.asMap().entries.map((entry) {
                        final int index = entry.key;
                        final String displayText = entry.value;
                        return DropdownMenuItem<String>(
                          value: categoriesEn[index],
                          child: Text(displayText,
                              style: const TextStyle(fontSize: 15)),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ),
              )
            else if (selectedIndex == 0)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Note: Sahaba Stories has no categories or English translations.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else if (selectedIndex == 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: playlist.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 3, horizontal: 10),
                        child: Material(
                          elevation: 2,
                          borderRadius: BorderRadius.circular(12),
                          color: playlist[index]!=_currentPS ? Colors.white:Colors.blue,
                          child: ListTile(
                            title: Text(
                              playlist[index],
                              style: TextStyle(color:playlist[index]!=_currentPS ? Colors.black:Colors.white),
                            ),
                            onTap: () async {
                              setState(() {
                                _currentPS=playlist[index];
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ));
      },
    );
  }

  Expanded _buildToggleButton(
      BuildContext context, String label, int index, int selectedIndex) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          widget.scraper.station.value = index;
        }),
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context)!.translate(label),
            style: TextStyle(
              color: selectedIndex == index ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
