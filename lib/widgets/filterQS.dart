import 'package:flutter/material.dart';
import 'package:theway/l10n/app_localizations.dart';
import '../Services/qsscrapper.dart';

class Filterqs extends StatefulWidget {
  const Filterqs(
      {super.key,
      required this.scraper,
      required this.onCategoryChanged,
      required this.onSubCategoryChanged,
      required this.currentCat});
  final Qsscrapper scraper;
  final Future<void> Function() onCategoryChanged;
  final void Function(String?, bool) onSubCategoryChanged;
  final String currentCat;

  @override
  State<Filterqs> createState() => _FilterqsState();
}

class _FilterqsState extends State<Filterqs> {
  late final bool firstSrc;
  late String _selectedCategory;
  @override
  void initState() {
    super.initState();
    firstSrc = widget.scraper.station.value;
    _selectedCategory = widget.currentCat; 
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = List<String>.from(
        AppLocalizations.of(context)!.translateList("categories"));
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
    return ValueListenableBuilder<bool>(
        valueListenable: widget.scraper.station,
        builder: (context, value, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4))),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      if (firstSrc != widget.scraper.station.value) {
                        await widget.onCategoryChanged();
                      }
                      if (widget.scraper.station.value == true) {
                        widget.onSubCategoryChanged(_selectedCategory, true);
                      }
                    },
                    child:
                        Text(AppLocalizations.of(context)!.translate("Apply"))),
              ),
              const Divider(
                color: Colors.grey, 
                thickness: 1,
                height: 20, 
                indent: 10, 
                endIndent: 10, 
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 20, top: 10),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.scraper.station,
                    builder: (context, isStation, _) {
                      return Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: !isStation
                                          ? Colors.grey
                                          : Colors.grey[300],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        bottomLeft: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isStation
                                          ? Colors.grey
                                          : Colors.grey[300],
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Sliding blue box
                            AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              alignment: isStation
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: 0.5,
                                heightFactor: 1.0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.scraper.station.value = false,
                                    child: Container(
                                      color: Colors.transparent,
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate("SahabaStories"),
                                        style: TextStyle(
                                          color: isStation
                                              ? Colors.black
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        widget.scraper.station.value = true,
                                    child: Container(
                                      color: Colors
                                          .transparent, // Important to make sure the whole area is tappable
                                      alignment: Alignment.center,
                                      child: Text(
                                        AppLocalizations.of(context)!
                                            .translate("Radio Stations"),
                                        style: TextStyle(
                                          color: isStation
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              widget.scraper.station.value
                  ? Container(
                      padding: const EdgeInsets.only(
                          bottom: 20, left: 20, right: 20),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!
                              .translate("Category"),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    displayText,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
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
                  : Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: const Text(
                        "Note: Sahaba Stories has no categories or English translations.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
            ],
          );
        });
  }
}
