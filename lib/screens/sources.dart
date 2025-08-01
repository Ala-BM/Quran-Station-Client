import 'package:flutter/material.dart';
import 'package:theway/screens/settings.dart';
import 'package:theway/widgets/blur_ani.dart';
import 'package:theway/widgets/fade_ani.dart';
import 'package:theway/widgets/presistantplayer.dart';
import '../widgets/switchscreen.dart';
import '../widgets/qs_list.dart';
import '../widgets/qs_list_fav.dart';

class Sources extends StatefulWidget {
  const Sources({super.key, required this.onLanguageChange});
  final void Function(Locale locale) onLanguageChange;
 
  @override
  State<Sources> createState() => _SourcesState();
}

class _SourcesState extends State<Sources> {

  final GlobalKey _switchScreenKey = GlobalKey();
  double _switchScreenHeight = 0;
  int _currentIndex = 1;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSwitchScreenHeight());
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _getSwitchScreenHeight() {
    final renderBox = _switchScreenKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _switchScreenHeight = renderBox.size.height;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_pageController == null) return;
   
    setState(() {
      _currentIndex = index;
    });
    _pageController!.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  void _handleLanguageToggle([String? lang]) {
    final blurAni = BlurAni.of(context);
    blurAni?.blurTransition(() {
      widget.onLanguageChange(
        lang != null?  Locale(lang): Localizations.localeOf(context).languageCode == 'en'?
            const Locale('ar'):
             const Locale('en')
      );
    });
  }
  List<Widget> _getScreens() {
    return [
      QsListFav(onLanguageChange: _handleLanguageToggle), 
      Qslist(onLanguageChange: _handleLanguageToggle),    
      Settings(onLanguageChange: _handleLanguageToggle),                            
    ];
  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: _pageController == null
                        ? Qslist(onLanguageChange: _handleLanguageToggle)
                        : PageView(
                            controller: _pageController!,
                            onPageChanged: _onPageChanged,
                            children: _getScreens(),
                            reverse: Directionality.of(context) == TextDirection.rtl,
                          )
                  ),
                ),
                Container(
                  key: _switchScreenKey,
                  child: Switchscreen(
                    onTabChanged: _onTabChanged,
                    currentIndex: _currentIndex,
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: _switchScreenHeight,
              child: const PersistentPlayer(),
            ),
          ],
        ),
      );
  
  }
}