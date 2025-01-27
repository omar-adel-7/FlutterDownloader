import 'dart:io';
import 'package:downloader/cubit/download_cubit.dart';
import 'package:downloader/cubit/download_state.dart';
import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DownloadCubit downloadCubit = DownloadCubit();
  DownloaderPlugin.init(downloadCubit, allow_cancel: false, is_serial: true,
    android_parallel_main_notification_message: "test parallel",//todo omar
    android_notification_progress_message: "downloading",
    android_notification_complete_message: "complete download",);
  runApp(MyApp(downloadCubit: downloadCubit));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.downloadCubit});

  final DownloadCubit downloadCubit;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int progress = 0;
  String message = "";

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;
    if (!status.isGranted) {
      // The permission is not granted, request it.
      status = await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
        value: widget.downloadCubit, child: getMaterialApp());
    // //or
    // return  MultiBlocProvider(
    //   providers: [
    //     BlocProvider.value(
    //         value: widget.downloadCubit,
    //     )
    //   ],
    //   child: getMaterialApp(),
    // );
  }

  getMaterialApp() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    color: Colors.cyan, child: const Text('Download url 1 now')),
              ),
              onTap: () async {
                String url = "https://server8.mp3quran.net/frs_a/014.mp3";
                String destinationDirPath = await getDestination();
                String fileName =
                    "test File 111 Name'with'apostrophe ' and comma, ,.mp3";
                DownloaderPlugin.downloadFile(
                  url: url,
                  destinationPath: destinationDirPath,
                  fileName: fileName,
                  androidNotificationMessage: "test 111 notification message",
                );
              },
            ),
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    color: Colors.cyan, child: const Text('Download url 2 now')),
              ),
              onTap: () async {
                String url = "https://server8.mp3quran.net/frs_a/018.mp3";
                String destinationDirPath = await getDestination();
                String fileName =
                    "test File 222 Name'with'apostrophe ' and comma, ,.mp3";
                DownloaderPlugin.downloadFile(
                  url: url,
                  destinationPath: destinationDirPath,
                  fileName: fileName,
                  androidNotificationMessage: "test 222 notification message",
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              color: Colors.yellow,
              child: BlocConsumer<DownloadCubit, DownloadStates>(
                listener: (context, downloadState) {
                  if (downloadState is DownloadAddedState) {
                    print(
                        "BlocConsumer listener onAdded url=${downloadState.url}");
                    onAdded(downloadState.url);
                  } else if (downloadState is DownloadProgressState) {
                    print(
                        "BlocConsumer listener onProgress url=${downloadState.url} and progress = ${downloadState.progress}");
                    onProgress(downloadState.url, downloadState.progress);
                  } else if (downloadState is DownloadCompletedState) {
                    print(
                        "BlocConsumer listener onCompleted url=${downloadState.url}");
                    onCompleted(downloadState.url);
                  } else if (downloadState is DownloadErrorState) {
                    print(
                        "BlocConsumer listener onError url=${downloadState.url} , error=${downloadState.error}");
                    onError(downloadState.url, downloadState.error);
                  }
                },
                builder: (context, downloadState) {
                  if (downloadState is DownloadAddedState) {
                    print(
                        "BlocConsumer builder onAdded url=${downloadState.url}");
                  } else if (downloadState is DownloadProgressState) {
                    print(
                        "BlocConsumer builder onProgress url=${downloadState.url} and progress = ${downloadState.progress}");
                  } else if (downloadState is DownloadCompletedState) {
                    print(
                        "BlocConsumer builder onCompleted url=${downloadState.url}");
                  } else if (downloadState is DownloadErrorState) {
                    print(
                        "BlocConsumer builder onError url=${downloadState.url} , error=${downloadState.error}");
                  }
                  return Column(
                    children: [
                      Text("message = $message"),
                      const SizedBox(
                        height: 15,
                      ),
                      Text("progress = $progress"),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<String> getDestination() async {
    return await getAppInternalFolderPath()
        //+Platform.pathSeparator // it is the same if with this line
        // or without it as it is handled internally in the plugin
        ;
  }

  Future<String> getAppInternalFolderPath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    return appDocumentsDirectory.path;
  }

  void onAdded(String url) {
    progress = 0;
    message = "added";
    // //in case of not using bloc
    // setState(() {});
  }

  void onProgress(String url, int progress) {
    this.progress = progress;
    message = "downloading";
    // //in case of not using bloc
    // setState(() {});
  }

  void onCompleted(String url) {
    progress = 100;
    message = "completed";
    // //in case of not using bloc
    // setState(() {});
  }

  void onError(String url, String? error) {
    progress = 0;
    message = error ?? "error";
    String errorMessage = message;
    Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
    // //in case of not using bloc
    // setState(() {});
  }
}
