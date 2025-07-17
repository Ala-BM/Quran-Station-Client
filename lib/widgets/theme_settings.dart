import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:theway/Providers/json_theme_provider.dart';
import 'package:theway/l10n/app_localizations.dart';


class ThemeSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("Settings")),
      ),
      body: Consumer<JsonThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                AppLocalizations.of(context)!.translate("Theme Settings"),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.translate("Select Theme:"),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: themeProvider.availableThemes.length,
                        itemBuilder: (context, index) {
                          final themeName = themeProvider.availableThemes[index];
                          final isSelected = themeName == themeProvider.currentTheme;
                          final themeColors = themeProvider.getThemeColors(themeName);
                          
                          return GestureDetector(
                            onTap: () => themeProvider.setTheme(themeName),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: themeColors['primary'] ?? Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: themeColors['secondary'] ?? Colors.grey,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            themeName,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          if (isSelected)
                                            Text(
                                              AppLocalizations.of(context)!.translate("Active"),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Consumer<JsonThemeProvider>(
                builder: (context, previewThemeProvider, child) {

                  final currentThemeData = previewThemeProvider.themeData;
                  final colorScheme = currentThemeData.colorScheme;
                  
                  return Card(
                    color:colorScheme.surface ,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                AppLocalizations.of(context)!.translate("Theme Preview: "),
                                style:Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                )
                              ),
                              Text(
                                previewThemeProvider.currentTheme,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: colorScheme.onPrimary,
                                    backgroundColor: colorScheme.primary,
                                  ),
                                  child: Text(AppLocalizations.of(context)!.translate("Primary Button")),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    side: BorderSide(color: colorScheme.primary),
                                  ),
                                  child: Text(AppLocalizations.of(context)!.translate("Outlined Button")),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildColorPreviewWithColor(
                                  context,
                                  AppLocalizations.of(context)!.translate("Primary"),
                                  colorScheme.primary,
                                  colorScheme.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildColorPreviewWithColor(
                                  context,
                                  AppLocalizations.of(context)!.translate("Secondary"),
                                  colorScheme.secondary,
                                  colorScheme.primary,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: _buildColorPreviewWithColor(
                                  context,
                                  AppLocalizations.of(context)!.translate("Surface"),
                                  colorScheme.surface,
                                  colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.translate("Sample Card with") + " ${previewThemeProvider.currentTheme} " + AppLocalizations.of(context)!.translate("Theme"),
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.translate("This preview updates when you select different themes above."),
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColorPreview(BuildContext context, String label, Color color,Color textC) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textC,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildColorPreviewWithColor(BuildContext context, String label, Color color,Color textC) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textC
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}