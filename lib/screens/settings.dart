import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/l10n/app_localizations.dart';
import 'package:theway/screens/theme_settings.dart';

class Settings extends StatefulWidget {
  final void Function([String]) onLanguageChange;
  const Settings({super.key, required this.onLanguageChange});
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String selectedLanguage ;

  @override
  Widget build(BuildContext context) {
        final locale = Localizations.localeOf(context);
    var selectedLanguage = locale.languageCode == 'ar' ? 'Arabic' : 'English';
        
    return       Consumer<JsonThemeProvider>(
      builder: (context, themeprovider, child) {
        final currentThemeData = themeprovider.themeData;
        final colorScheme = currentThemeData.colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            backgroundColor: colorScheme.surface,
            title: Text(
              AppLocalizations.of(context)!.translate("Settings")
            ,style: TextStyle(color: colorScheme.inverseSurface),),
          ),
          body: Column(
            children: [
              Card(
                color: colorScheme.surfaceBright,
                margin: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/icons/logo.png',
                  color: colorScheme.inverseSurface,
                ),
              ),
              Card(
                color: colorScheme.surfaceBright,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ThemeSettingsScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.color_lens,
                          color: colorScheme.inverseSurface,
                        ),
                        const SizedBox(width: 12.0),
                        Text(
                          AppLocalizations.of(context)!.translate("Theme Options"),
                          style: TextStyle(
                            color: colorScheme.inverseSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: colorScheme.surfaceBright,
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
             
                  child: Container(
                  
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: colorScheme.inverseSurface,
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              AppLocalizations.of(context)!.translate("Language"),
                              style: TextStyle(
                                color: colorScheme.inverseSurface,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                              Directionality(textDirection: TextDirection.ltr, child: Column(
                          children: [
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(AppLocalizations.of(context)!.translate("English"),style: TextStyle(color: colorScheme.inverseSurface)),
                              leading: Radio(
                                value: 'English',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                    widget.onLanguageChange("en");
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(AppLocalizations.of(context)!.translate("Arabic"),style: TextStyle(color: colorScheme.inverseSurface)),
                              leading: Radio(
                                value: 'Arabic',
                                groupValue: selectedLanguage,
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                   widget.onLanguageChange("ar");
                                  });
                                },
                              ),
                            ),
                          ],
                        ),),
                      ],
                    ),
                  ),
                
              )
            ],
          ),
        );
      },
    );
  }
}