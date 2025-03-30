import 'package:hive/hive.dart';

class Album {
  final String image;
  final String album;
  final String link;
  final List<String>? platform;
  final String? albumType;
  final String? year;

  Album({
    required this.image,
    required this.album,
    required this.link,
    this.platform,
    this.albumType,
    this.year,
  });
  
  }
@HiveType(typeId: 0)
class KhinAudio {
  @HiveField(0)
        final String audioname;
        @HiveField(0)
        final String audiolink;
        @HiveField(1)
        final String duration;
        @HiveField(2)
        final String id;
        @HiveField(3)
        final String albumImg;
        @HiveField(4)
         String? cat;
         @HiveField(5)
         String? catEx;
         @HiveField(6)
         String? audioNameEx;
  KhinAudio({required this.audioname, required this.audiolink, required this.duration, required this.id,required this.albumImg,this.cat, this.catEx, this.audioNameEx,});
    Map<String, dynamic> toMap() {
    return {
      'audiolink': audiolink,
      'audioname': audioname,
      'duration': duration,
      'id':id,
      "albumImg":albumImg,
      "cat":cat,
      "catEx":catEx,
      "audioNameEx":audioNameEx
    };
  }
    factory KhinAudio.fromMap(Map<dynamic, dynamic> map) {
    return KhinAudio(
      audiolink: map['audiolink'] ?? '',
      audioname: map['audioname'] ?? '',
      duration: map['duration'] ?? '',
      id: map['id'] ?? '',
      albumImg: map['albumImg'] ?? '',
      cat: map['cat'] ?? '',
      catEx: map['catEx'] ?? '',
      audioNameEx: map['audioNameEx'] ?? '',
    );
  }

  toList() {}
  
}
class KhinAudioAdapter extends TypeAdapter<KhinAudio> {
  @override
  final int typeId = 0; // Must match the typeId in @HiveType

  @override
  KhinAudio read(BinaryReader reader) {
    final audioname = reader.readString();
    final audiolink = reader.readString();
    final duration = reader.readString();
    final id = reader.readString();
    final albumImg = reader.readString();
    final cat = reader.readString();
    final catEx = reader.readString();
    final audioNameEx = reader.readString();

    return KhinAudio(
      audioname: audioname,
      audiolink: audiolink,
      duration: duration,
      id: id,
      albumImg: albumImg,
      cat: cat,
      catEx: catEx,
      audioNameEx: audioNameEx,
    );
  }

  @override
  void write(BinaryWriter writer, KhinAudio obj) {
    writer.writeString(obj.audioname);
    writer.writeString(obj.audiolink);
    writer.writeString(obj.duration);
    writer.writeString(obj.id);
    writer.writeString(obj.albumImg);
    writer.writeString(obj.cat ?? '');
    writer.writeString(obj.catEx ?? '');
    writer.writeString(obj.audioNameEx ?? '');
  }
}