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
  DownloaderPlugin.init(downloadCubit,
      is_serial: true,
      //show_ios_notifications: false,
      //android_parallel_main_notification_message: "parallel download service running",
      notification_progress_message: "downloading",
      notification_complete_message: "completed download");
  // DownloaderPlugin.init(downloadCubit,is_serial: true,show_ios_notifications: false);
  runApp(MyApp(downloadCubit: downloadCubit));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.downloadCubit});

  final DownloadCubit downloadCubit;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int progress1 = 0;
  String message1 = "";
  int progress2 = 0;
  String message2 = "";

  @override
  void initState() {
    super.initState();
    // DownloaderPlugin.initNotificationStrings(
    //   //  android_parallel_main_notification_message: "initNotificationStrings parallel download service running",
    //     notification_progress_message: "initNotificationStrings downloading",
    //     notification_complete_message: "initNotificationStrings completed download");
    if(Platform.isAndroid){
      requestNotificationPermission();
    }
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

  MaterialApp getMaterialApp() {

    String url1 = "https://server8.mp3quran.net/frs_a/014.mp3";
    String url2 = "https://server8.mp3quran.net/frs_a/018.mp3";

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      color: Colors.cyan,
                      child: const Text('Download url 1 now')),
                ),
                onTap: () async {
                  String url = url1;
                  String destinationDirPath = await getDestination();
                  String fileName =
                      "test File 1 Name'with'apostrophe ' and comma, ,.mp3";
                  DownloaderPlugin.downloadFile(
                    url: url,
                    destinationPath: destinationDirPath,
                    fileName: fileName,
                    notificationMessage: "test 1 notificationMessage",
                    notificationProgressMessage:
                    "test 1 notificationProgressMessage",
                    notificationCompleteMessage:
                    "test 1 notificationCompleteMessage",
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              BlocConsumer<DownloadCubit, DownloadStates>(
                listener: (context, downloadState) {
                  if (downloadState is DownloadAddedState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer listener url1 onAdded url=${downloadState.url}");
                    onAdded(1, downloadState.url);
                  } else if (downloadState is DownloadProgressState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer listener url1 onProgress url=${downloadState.url} and progress = ${downloadState.progress}");
                    onProgress(1, downloadState.url, downloadState.progress);
                  } else if (downloadState is DownloadCompletedState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer listener url1 onCompleted url=${downloadState.url}");
                    onCompleted(1, downloadState.url);
                  } else if (downloadState is DownloadErrorState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer listener url1 onError url=${downloadState.url} , error=${downloadState.error}");
                    onError(1, downloadState.url, downloadState.error);
                  }
                },
                builder: (context, downloadState) {
                  int? progress = DownloaderPlugin.getUrlProgress(
                      url1, downloadState);
                  if (progress != null) {
                    print(
                        "BlocConsumer builder url1 progress url=$url1"
                            " and progress = $progress");
                  }
                  else if (downloadState is DownloadCompletedState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer builder url1 onCompleted url=$url1");
                  } else if (downloadState is DownloadErrorState &&
                      downloadState.url == url1) {
                    print(
                        "BlocConsumer builder url1 onError url=$url1 and error=${downloadState.error}");
                  }
                  return Column(
                    children: [
                      Text("message = $message1"),
                      const SizedBox(
                        height: 15,
                      ),
                      Text("progress = $progress1"),
                    ],
                  );
                },
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      color: Colors.cyan,
                      child: const Text('Download url 2 now')),
                ),
                onTap: () async {
                  String url = url2;
                  String destinationDirPath = await getDestination();
                  String fileName =
                      "test File 2 Name'with'apostrophe ' and comma, ,.mp3";
                  DownloaderPlugin.downloadFile(
                    url: url,
                    destinationPath: destinationDirPath,
                    fileName: fileName,
                    notificationMessage: "test 2 notificationMessage",
                    //  notificationProgressMessage:
                    //      "test 2 notificationProgressMessage",
                    // notificationCompleteMessage:
                    //     "test 2 notificationCompleteMessage",
                  );
                },
              ),
              const SizedBox(
                height: 10,
              ),
              BlocConsumer<DownloadCubit, DownloadStates>(
                listener: (context, downloadState) {
                  if (downloadState is DownloadAddedState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer listener url2 onAdded url=${downloadState.url}");
                    onAdded(2, downloadState.url);
                  } else if (downloadState is DownloadProgressState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer listener url2 onProgress url=${downloadState.url} and progress = ${downloadState.progress}");
                    onProgress(2, downloadState.url, downloadState.progress);
                  } else if (downloadState is DownloadCompletedState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer listener url2 onCompleted url=${downloadState.url}");
                    onCompleted(2, downloadState.url);
                  } else if (downloadState is DownloadErrorState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer listener url2 onError url=${downloadState.url} , error=${downloadState.error}");
                    onError(2, downloadState.url, downloadState.error);
                  }
                },
                builder: (context, downloadState) {
                  int? progress = DownloaderPlugin.getUrlProgress(
                      url2, downloadState);
                  if (progress != null) {
                    print(
                        "BlocConsumer builder url2 progress url=$url2"
                            " and progress = $progress");
                  }
                  else if (downloadState is DownloadCompletedState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer builder url2 onCompleted url=$url2");
                  } else if (downloadState is DownloadErrorState &&
                      downloadState.url == url2) {
                    print(
                        "BlocConsumer builder url2 onError url=$url2 and error=${downloadState.error}");
                  }
                  return Column(
                    children: [
                      Text("message = $message2"),
                      const SizedBox(
                        height: 15,
                      ),
                      Text("progress = $progress2"),
                    ],
                  );
                },
              )
            ],
          ),
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

  void onAdded(int id, String url) {
    int progress = 0;
    String message = "added";
    id == 1 ? progress1 = progress : progress2 = progress;
    id == 1 ? message1 = message : message2 = message;
  }

  void onProgress(int id, String url, int progress) {
    String message = "downloading";
    id == 1 ? progress1 = progress : progress2 = progress;
    id == 1 ? message1 = message : message2 = message;
  }

  void onCompleted(int id, String url) {
    int progress = 100;
    String message = "completed";
    id == 1 ? progress1 = progress : progress2 = progress;
    id == 1 ? message1 = message : message2 = message;
  }

  void onError(int id, String url, String? error) {
    int progress = 0;
    String message = error ?? "error";
    id == 1 ? progress1 = progress : progress2 = progress;
    id == 1 ? message1 = message : message2 = message;
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }
}
