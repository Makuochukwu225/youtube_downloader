import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_downloader/constants/constants.dart';
import 'package:youtube_downloader/models/payload.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var controller = TextEditingController();
  bool loading = false;
  bool error = false;
  final dio = Dio();
  var selected = "360";
  var type = ["144", "240", "360", "480", "720", "1080"];
  Payload data = Payload();
  String progress = "";
  bool isDownloadingMp3 = false;
  bool isDownloadingMp4 = false;
  @override
  void initState() {
    super.initState();
  }

  Future<Payload> loadVideo(String url) async {
    setState(() {
      loading = true;
      error = false;
    });

    Payload? result;
    try {
      final response = await dio.get("${Constants.url}$url&type=$selected");
      var map = Map<String, dynamic>.from(response.data);
      result = Payload.fromMap(map);
      setState(() {
        loading = false;
        error = false;
      });
      return result;
    } catch (e, stacktrace) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Something went wrong')));
      setState(() {
        loading = false;
        error = true;
      });

      throw Exception("Exception occured: $e stackTrace: $stacktrace");
    }
  }

  Future<void> downloadVideo(
      String trackURL, String trackName, String format) async {
    setState(() {
      if (format.contains('mp3')) {
        isDownloadingMp3 = true;
      } else {
        isDownloadingMp4 = true;
      }
    });

    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }
      }
      final appStorage = await getDownloadsDirectory();
      var directory = Platform.isAndroid
          ? File(appStorage!.path)
          : File('/home/koln/Downloads');
      print(
          "${directory.path}/${trackName.replaceAll(RegExp(r'[^\w\s]+'), '').split(" ").join("")}$format");
      await dio.download(trackURL, "${directory.path}/$trackName$format",
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0,
          ), onReceiveProgress: (rec, total) {
        setState(() {
          progress = "${((rec / total) * 100).toStringAsFixed(0)}%";
          print(progress);
        });
      });

      setState(() {
        if (progress.contains('100')) {
          if (format.contains('mp3')) {
            isDownloadingMp3 = false;
          } else {
            isDownloadingMp4 = false;
          }
          progress = "Download Successful";
        }
      });
    } catch (e) {
      setState(() {
        if (format.contains('mp3')) {
          isDownloadingMp3 = false;
        } else {
          isDownloadingMp4 = false;
        }
        progress = "Download Failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Youtube downloader"),
      ),
      bottomSheet: SizedBox(
        height: 20,
        width: double.infinity,
        child: Center(child: Text(progress)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                SizedBox(
                  height: 64,
                  child: DropdownButton(
                      value: selected,
                      items: type
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selected = v ?? "360";
                        });
                      }),
                )
              ],
            ),
            const SizedBox(height: 10),
            loading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator()),
                      SizedBox(width: 10),
                      Text("Generating download link")
                    ],
                  )
                : ElevatedButton(
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Enter Link')));
                        return;
                      }
                      loadVideo(controller.text).then((value) {
                        setState(() {
                          data = value;
                        });
                        debugPrint(value.audio!.audio.toString());
                      });
                    },
                    child: const Text("Search"),
                  ),
            const SizedBox(height: 10),
            const SizedBox(height: 30),
            loading
                ? Container()
                : data.title == null
                    ? Container()
                    : Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              downloadVideo(
                                  data.audio!.audio!, data.title!, ".mp3");
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 90,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        data.thumbnail ?? ""))),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: const Text(
                                                'mp3',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )),
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.title ?? "",
                                              maxLines: 2,
                                            ),
                                            const Spacer(),
                                            Text(data.audio!.size ?? ""),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              downloadVideo(
                                  data.mp4!.download!, data.title!, ".mp4");
                            },
                            child: SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 90,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                        data.thumbnail ?? ""))),
                                          ),
                                          const SizedBox(height: 5),
                                          Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              child: const Text(
                                                'mp4',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              )),
                                          const SizedBox(height: 5),
                                          Text("${data.mp4!.type_download}p"),
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              data.title ?? "",
                                              maxLines: 2,
                                            ),
                                            const Spacer(),
                                            Text(data.mp4!.size ?? ""),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
          ],
        ),
      ),
    );
  }
}
