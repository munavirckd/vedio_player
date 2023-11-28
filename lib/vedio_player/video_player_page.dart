import 'dart:io';

import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vedio_player/vedio_player/app_drawe.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({super.key});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late CustomVideoPlayerController _customVideoPlayerController;
  late List<String> videoUrls;
  int currentIndex = 0;

  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Disable screenshots and screen recording
    FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    videoUrls = [
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"
    ];
    checkIfVideoIsLocal(videoUrls[currentIndex]);
  }

  Future<void> downloadFile(String url) async {
    Dio dio = Dio();
    var tempDir = await getTemporaryDirectory();
    String fullPath =
        tempDir.path + "/downloaded_video_${currentIndex + 1}.mp4";

    try {
      await dio.download(url, fullPath);
      encryptVideo(fullPath);
      playLocalVideo(fullPath);
      _showToast("Download completed");
      setState(() {});
    } catch (e) {
      print("Error downloading video: $e");
    }
  }

  Future<void> checkIfVideoIsLocal(String videoUrl) async {
    try {
      var tempDir = await getTemporaryDirectory();
      String fullPath =
          tempDir.path + "/downloaded_video_${currentIndex + 1}.mp4";

      bool fileExists = await File(fullPath).exists();

      if (fileExists) {
        playLocalVideo(fullPath);
      } else {
        initializeVideoPlayer(videoUrl);
      }
    } catch (e) {
      print("Error checking if video is local: $e");
    }
  }

  void playNextVideo() {
    currentIndex++;
    checkIfVideoIsLocal(videoUrls[currentIndex]);
  }

  void playPreviousVideo() {
    currentIndex--;
    checkIfVideoIsLocal(videoUrls[currentIndex]);
  }

  void playLocalVideo(String filePath) {
    initializeVideoPlayer(filePath);
  }

  void encryptVideo(String filePath) {
    try {
      File videoFile = File(filePath);
      List<int> videoBytes = videoFile.readAsBytesSync();
      List<int> encryptedBytes = videoBytes.map((byte) => byte ^ 255).toList();

      File(encryptedVideoPath()).writeAsBytesSync(encryptedBytes);
      print("Success encrypting video");
    } catch (e) {
      print("Error encrypting video: $e");
    }
  }

  String encryptedVideoPath() {
    var tempDir = Directory.systemTemp;
    return tempDir.path + "/encrypted_video.mp4";
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void initializeVideoPlayer(String url) {
    setState(() {
      isLoading = true;
    });
    VideoPlayerController _videoPlayerController;
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((value) {
        setState(() {
          isLoading = false;
        });
      });

    _customVideoPlayerController = CustomVideoPlayerController(
        context: context, videoPlayerController: _videoPlayerController);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AppDrawer(),
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 280,
                  child: CustomVideoPlayer(
                    customVideoPlayerController: _customVideoPlayerController,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                _sourceButtons(),
              ],
            ),
    );
  }

  Widget _sourceButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: () {
                setState(() {
                  playPreviousVideo();
                });
              },
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
            ),
          ),
          Material(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            clipBehavior: Clip.antiAlias,
            child: MaterialButton(
              elevation: 0,
              color: Colors.white,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.arrow_drop_down,
                    size: 50,
                    color: Colors.green,
                  ),
                  Text(
                    "Download",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                downloadFile(videoUrls[currentIndex]);
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: IconButton(
              color: Colors.black,
              onPressed: () {
                setState(() {
                  playNextVideo();
                });
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
  }
}
