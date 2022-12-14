class Audio {
  String? audio;
  String? size;

  Audio.fromMap(Map<String, dynamic> data) {
    audio = data['audio'];
    size = data['size'];
  }

  Map<String, dynamic> toMap() {
    return {
      'audio': audio,
      'size': size,
    };
  }
}
