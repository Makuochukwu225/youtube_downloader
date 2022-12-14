import 'package:youtube_downloader/models/audio.dart';
import 'package:youtube_downloader/models/video.dart';

class Payload {
  String? creator;
  String? pilihan_type;
  String? id;
  String? thumbnail;
  String? title;
  Video? mp4;
  Audio? audio;
  Payload();

  Payload.fromMap(Map<String, dynamic> data) {
    creator = data['creator'];
    pilihan_type = data['pilihan_type'];
    id = data['id'];
    thumbnail = data['thumbnail'];
    title = data['title'];
    mp4 = Video.fromMap(data['mp4']);
    audio = Audio.fromMap(data['audio']);
  }
}
