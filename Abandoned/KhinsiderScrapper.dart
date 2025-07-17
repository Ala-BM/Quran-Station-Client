import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:theway/Providers/KhinsiderAlbums.dart';

Future<List<Album>> fetchAlbums() async {
  const url = 'https://downloads.khinsider.com/game-soundtracks';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = html_parser.parse(response.body);
    final table = document.querySelector('table.albumList');
    final rows = table?.querySelectorAll('tr').skip(1) ?? [];

    List<Album> albums = [];

    for (var row in rows) {
      final cells = row.querySelectorAll('td');

      final image = cells[0].querySelector('img')?.attributes['src'] ?? 'No image available';
      final albumInfo = cells[1].querySelector('a');
      final album = albumInfo?.text.trim() ?? 'Unknown album';
      final link = albumInfo?.attributes['href'] ?? 'No link available';
      final platforms = cells[2].querySelectorAll('a').map((e) => e.text.trim()).toList();
      final albumType = cells[3].text.trim();
      final year = cells[4].text.trim();

      albums.add(Album(
        image: image,
        album: album,
        link: link,
        platform: platforms,
        albumType: albumType,
        year: year.isNotEmpty ? year : 'Unknown',
      ));
    }
    print (albums[0].album);
    return albums;
  } else {
    throw Exception('Failed to load albums');
  }
}

Future<List<KhinAudio>> fetchAudio(Album albuml) async {
  final url = albuml.link;
  print (url);
  final response = await http.get(Uri.parse('https://downloads.khinsider.com/$url'));

  if (response.statusCode == 200) {
    final document = html_parser.parse(response.body);
    final table = document.querySelector('#songlist');
    final rows = table?.querySelectorAll('tr').skip(1) ?? [];

    List<KhinAudio> audios = [];
    print(rows);
    for (var row in rows) {
      final cells = row.querySelectorAll('td');
              if (cells.isEmpty || cells.length < 8) {
          print('Skipping invalid row: $row');
          continue; // Skip rows without enough data
  }
      final audio = cells[2].querySelector('a');

      final audioname = audio?.text.trim() ?? 'Unknown album';
      print(audioname);
      final audiolink = audio?.attributes['href'] ?? 'No link available';
      final duration = cells[3].querySelector('a')?.text.trim() ?? 'Unknown aDuration';
      final id = cells[7].querySelector('div.playlistAddTo')?.attributes['songid'] ?? 'Unknown';

      audios.add(KhinAudio (
        audioname: audioname,
        audiolink: 'https://downloads.khinsider.com$audiolink',
        duration: duration,
        id: id,
        albumImg:albuml.image//.replaceAll("thumbs_small/", "") Enhance Pic _Consume data (T_T)
      ));
      
    }
        print("ffffffffffffffffffffffffffffffffffffffffffffffffffffffff");
    return audios;
  } else {
    throw Exception('Failed to load audios');
  }
}
Future<String> fetchLink(String audioUrl) async {
  final response = await http.get(Uri.parse(audioUrl));
  if (response.statusCode == 200) {
    final document = html_parser.parse(response.body);
    final audio = document.querySelector('audio')?.attributes['src'] ?? 'No Audio available';
    return audio;
   } else {
    throw Exception('Failed to load audio');
  }
  }