import 'package:flutter/material.dart';
import 'package:theway/widgets/presistantplayer.dart';
import '../widgets/switchscreen.dart';
import '../widgets/qsList.dart';

class Sources extends StatefulWidget {
  const Sources({super.key, required this.onLanguageChange});
final void Function(Locale locale) onLanguageChange;
  @override
  State<Sources> createState() => _SourcesState();
}

class _SourcesState extends State<Sources> {
  final GlobalKey _switchScreenKey = GlobalKey();
  double _switchScreenHeight = 0;

  @override
  void initState() {
    super.initState();
    // Wait until the layout is built before measuring
    WidgetsBinding.instance.addPostFrameCallback((_) => _getSwitchScreenHeight());
  }

  void _getSwitchScreenHeight() {
    final renderBox = _switchScreenKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        _switchScreenHeight = renderBox.size.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // KhinBrowse takes available space
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child:  Qslist(onLanguageChange :widget.onLanguageChange),
                ),
              ),

              // Switchscreen - wrapped in a Key to measure its height
              Container(
                key: _switchScreenKey,
                child: const Switchscreen(),
              ),
            ],
          ),

          // Persistent Player positioned above Switchscreen
          Positioned(
            left: 0,
            right: 0,
            bottom: _switchScreenHeight, // Dynamically positions it above Switchscreen
            child: const PersistentPlayer(),
          ),
        ],
      ),
    );
  }
}
