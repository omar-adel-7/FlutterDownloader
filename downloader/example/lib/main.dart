import 'dart:io';
import 'package:downloader/cubit/download_result_cubit.dart';
import 'package:downloader/cubit/download_result_state.dart';
import 'package:downloader/download_listener.dart';
import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DownloadResultCubit downloadResultCubit = DownloadResultCubit();
  DownloaderPlugin.init(downloadResultCubit: downloadResultCubit);
  runApp(MyApp(downloadResultCubit: downloadResultCubit));
}

class MyApp extends StatefulWidget {
   const MyApp({super.key,  required this .downloadResultCubit});
   final DownloadResultCubit downloadResultCubit;

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
    return  BlocProvider.value(
       value: widget.downloadResultCubit,
         child: getMaterialApp()
     );
    //or
    // return  MultiBlocProvider(
    //   providers: [
    //     BlocProvider.value(
    //         value: widget.downloadResultCubit,
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
                  String fileNameWithoutExtension = "test File Name'with'apostrophe ' and comma, , 12";
                  String extension = "db";
                  //DownloaderPlugin.cancelAndClearAndroidDownloads();//to handle force stop in case of downloading one file
                  // without downloadListener
                  DownloaderPlugin.downloadFile(
                    url: url,
                    destinationDirPath: destinationDirPath,
                    fileNameWithoutExtension: fileNameWithoutExtension,
                    extension: extension,
                    androidNotificationMessage: "test notification message",
                    androidNotificationProgressMessage: "downloading",
                    androidNotificationCompleteMessage: "complete download",
                  );
                  // or with downloadListener
                  // DownloaderPlugin.downloadFile(
                  //     url: url,
                  //     destinationDirPath: destinationDirPath,
                  //     fileNameWithoutExtension: fileNameWithoutExtension,
                  //     extension: extension,
                  //     androidNotificationMessage: "test notification message",
                  //     androidNotificationProgressMessage: "downloading",
                  //     androidNotificationCompleteMessage: "complete download",
                  //     downloadListener: DownloadListener(
                  //       onProgress: (String url, int progress) {
                  //         print(
                  //             "downloadListener onProgress url=$url and progress = $progress");
                  //         onProgress(url, progress);
                  //       },
                  //       onComplete: (String url) {
                  //         print("downloadListener onComplete url=$url");
                  //         onComplete(url);
                  //       },
                  //       onError: (String url, {String? error}) {
                  //         print(
                  //             "downloadListener onError url=$url , error=$error");
                  //         onError(url, error);
                  //       },
                  //     ));
                  //or add downloadListener separately
                  // DownloaderPlugin.addDownloadListener(
                  //     url: url,
                  //     downloadListener: DownloadListener(
                  //         onProgress: (String url, int progress) {
                  //       print(
                  //           "separate downloadListener onProgress url=$url and progress = $progress");
                  //       onProgress(url, progress);
                  //     }, onComplete: (String url) {
                  //       print("separate downloadListener onComplete url=$url");
                  //       onComplete(url);
                  //     }, onError: (String url, {String? error}) {
                  //       print(
                  //           "separate downloadListener onError url=$url , error=$error");
                  //       onError(url, error);
                  //     }));
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              color: Colors.yellow,
              child: BlocConsumer<DownloadResultCubit, DownloadResultStates>(
                listener: (context, downloadState) {
                  if (downloadState is DownloadProgressState) {
                    print(
                        "BlocBuilder onProgress url=${downloadState.url} and progress = ${downloadState.progress}");
                    onProgress(downloadState.url,downloadState.progress);
                  }
                  if (downloadState is DownloadCompletedState) {
                    print("BlocBuilder onComplete url=${downloadState.url}");
                    onComplete(downloadState.url);
                  }
                  if (downloadState is DownloadErrorState) {
                    print(
                        "downloadListener onError url=${downloadState.url} , error=${downloadState.error}");
                    onError(downloadState.url, downloadState.error);
                  }
                },
                builder: (context, downloadState) {
                  // if (downloadState is DownloadProgressState) {
                  //
                  //  }
                  // else if (downloadState is DownloadCompletedState) {
                  //
                  // }
                  // else if (downloadState is DownloadErrorState) {
                  //
                  // }
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

  void onProgress(String url, int progress) {
    this.progress = progress;
    message = "downloading";
    // //in case of not using bloc
    // setState(() {});
    }

  void onComplete(String url) {
    progress = 100;
    message = "complete";
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

