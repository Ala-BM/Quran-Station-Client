import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/l10n/app_localizations.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onLanguageToggle;
  final VoidCallback onFilterPressed;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onLanguageToggle,
    required this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<JsonThemeProvider>(
      builder: (context, themeprovider, child) {
        final currentThemeData = themeprovider.themeData;
        final colorScheme = currentThemeData.colorScheme;
        
        return Directionality(
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
                stops: const [0.0, 0.3, 0.6, 0.8, 1.0],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 60,
                      bottom: 20,
                      left: 10,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.inverseSurface.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      textDirection: Directionality.of(context),
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.translate("Search"),
                        hintTextDirection: Directionality.of(context),
                        border: InputBorder.none,
                      ),
                      onChanged: onChanged,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: IconButton(
                    onPressed: onLanguageToggle,
                    iconSize: 30,
                    icon: Image.asset(
                      'assets/icons/ar_en.png',
                      color: colorScheme.inverseSurface,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: IconButton(
                    onPressed: onFilterPressed,
                    iconSize: 30,
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}