import 'dart:io';
import 'package:downloader/download_listener.dart';
import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DownloaderPlugin.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int progress = 0;
  String message = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      color: Colors.cyan, child: Text('Download now')),
                ),
                onTap: () async {
                  String url =
                      "https://books9.arabia-it-key.com/storage/app/public/bfdf117a-7885-41ba-8cab-6357150ffb05/4a2a98e9-997f-43b6-83a7-12d30f9ef2ca.db";
                  String destinationDirPath = await getDestination();
                  String errorMessage = "error in download";
                  //DownloaderPlugin.clearAndroidDownloads();to handle force stop in case of downloading one file
                  DownloaderPlugin.downloadFile(
                      url: url,
                      destinationDirPath: destinationDirPath,
                      fileNameWithoutExtension:
                          "test File Name'with'apostrophe ' and comma, , 12",
                      extension: ".db",
                      androidNotificationMessage: "test notification message",
                      androidNotificationProgressMessage: "downloading",
                      androidNotificationCompleteMessage: "complete download",
                      downloadListener: DownloadListener(
                          onProgress: (String url, int progress) {
                            print(
                                "downloadListener onProgress url=$url and progress = $progress");
                            this.progress = progress;
                            this.message = "downloading";
                            setState(() {});
                          },
                          onComplete: (String url) {
                            print("downloadListener onComplete url=$url");
                            this.progress = 100;
                            this.message = "complete";
                            setState(() {});
                          },
                          onError: (String url) {
                            print("downloadListener onError url=$url");
                            this.progress = 0;
                            this.message = "error";
                            setState(() {});
                          },
                          errorMessage: errorMessage));
                  //or add downloadListener separately
                  DownloaderPlugin.addDownloadListener(
                      url: url,
                      downloadListener: DownloadListener(
                          onProgress: (String url, int progress) {
                            print(
                                "separate downloadListener onProgress url=$url and progress = $progress");
                            this.progress = progress;
                            this.message = "downloading";
                            setState(() {});
                          },
                          onComplete: (String url) {
                            print(
                                "separate downloadListener onComplete url=$url");
                            this.progress = 100;
                            this.message = "complete";
                            setState(() {});
                          },
                          onError: (String url) {
                            print("separate downloadListener onError url=$url");
                            this.progress = 0;
                            this.message = "error";
                            setState(() {});
                          },
                          errorMessage: errorMessage));
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              color: Colors.yellow,
              child: Column(
                children: [
                  Text("message = $message"),
                  const SizedBox(
                    height: 15,
                  ),
                  Text("progress = $progress"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getDestination() async {
    var databasesPath = await getAppInternalFolderPath();
    return join(databasesPath) + Platform.pathSeparator;
  }

  Future<String> getAppInternalFolderPath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.path;
  }
}
