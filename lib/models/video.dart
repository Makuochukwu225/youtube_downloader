class Video {
  String? download;
  String? size;
  String? type_download;


   Video.fromMap(Map<String, dynamic> data) {
    download = data['download'];
    size = data['size'];
    type_download = data['type_download'];
   ;
  }

  Map<String, dynamic> toMap() {
    return {
      'download': download,
      'size': size,
      'type_download': type_download,
    
    };
  }
}
