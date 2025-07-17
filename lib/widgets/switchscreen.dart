import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/l10n/app_localizations.dart';

class Switchscreen extends StatefulWidget {
  final Function(int) onTabChanged;
  final int currentIndex;
  
  const Switchscreen({
    super.key, 
    required this.onTabChanged,
    required this.currentIndex,
  });
  
  @override
  _SwitchState createState() => _SwitchState();
}

class _SwitchState extends State<Switchscreen> {
  @override
  Widget build(BuildContext context) {
   return Consumer<JsonThemeProvider>(builder:(context, themeprovider, child) {
          final currentThemeData = themeprovider.themeData;
      final colorScheme = currentThemeData.colorScheme;
      return
      Container(
      color:colorScheme.surface,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: BottomNavigationBar(
          backgroundColor:colorScheme.surface ,
          currentIndex: widget.currentIndex,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.inverseSurface.withOpacity(0.7),
          onTap: widget.onTabChanged,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_rounded),
              label: AppLocalizations.of(context)!.translate("Fav"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.compass_calibration),
              label: AppLocalizations.of(context)!.translate("Browse"),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: AppLocalizations.of(context)!.translate("Settings"),
            ),
          ],
        ),
      ),
    );
    },);
    
  }
}