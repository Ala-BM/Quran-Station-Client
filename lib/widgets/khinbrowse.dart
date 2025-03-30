import 'package:flutter/material.dart';
import '../Classes/KhinsiderAlbums.dart';
import 'albumbrowse.dart';
import 'audiolist.dart';

class KhinBrowse extends StatelessWidget {
  const KhinBrowse({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(

      body: AlbumNavigator(),
    );
  }
}

class AlbumNavigator extends StatefulWidget {
  const AlbumNavigator({super.key});

  @override
  State<AlbumNavigator> createState() => _AlbumNavigatorState();
}

class _AlbumNavigatorState extends State<AlbumNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _onAlbumSelected(Album album) {
    _navigatorKey.currentState!.pushNamed(
      '/songs',
      arguments: album,
    );
  }

  void _goBackToAlbums() {
    _navigatorKey.currentState!.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: '/albums',
      onGenerateRoute: (settings) {
        Widget page;
        if (settings.name == '/albums' || settings.name == '/') {
          page = Albumbrowse(onAlbumSelected:_onAlbumSelected);
        } else if (settings.name == '/songs') {
          final album = settings.arguments as Album;
          page = Audiolist(source: album, onBack:_goBackToAlbums);
        } else {
          throw Exception('Unknown route: ${settings.name}');
        }

        return MaterialPageRoute(
          builder: (_) => page,
          settings: settings,
        );
      },
    );
  }
}
