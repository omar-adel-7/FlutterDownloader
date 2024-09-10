import 'dart:io';
import 'package:downloader/cubit/download_cubit.dart';
import 'package:downloader/cubit/download_state.dart';
import 'package:downloader/download_listener.dart';
import 'package:downloader/downloader_plugin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DownloadCubit downloadCubit = DownloadCubit();
  DownloaderPlugin.init(downloadCubit);
  runApp(MyApp(downloadCubit: downloadCubit));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key,  required this .downloadCubit});
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
    return  BlocProvider.value(
        value: widget.downloadCubit,
        child: getMaterialApp()
    );
    //or
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
                  // without downloadListener
                  // DownloaderPlugin.downloadFile(
                  //   id: url,
                  //   url: url,
                  //   destinationPath: destinationDirPath,
                  //   fileNameWithoutExtension: fileNameWithoutExtension,
                  //   extension: extension,
                  //   androidNotificationMessage: "test notification message",
                  //   androidNotificationProgressMessage: "downloading",
                  //   androidNotificationCompleteMessage: "complete download",
                  // );
                  // or with downloadListener
                  DownloaderPlugin.downloadFile(
                      id: url,
                      url: url,
                      destinationPath: destinationDirPath,
                      fileNameWithoutExtension: fileNameWithoutExtension,
                      extension: extension,
                      androidNotificationMessage: "test notification message",
                      androidNotificationProgressMessage: "downloading",
                      androidNotificationCompleteMessage: "complete download",
                      downloadListener: DownloadListener(
                        onProgress: ({String? id,required String url,required int progress})
                        {
                            print(
                                "downloadListener onProgress id=$id and url=$url and progress = $progress");
                            onProgress(url, progress);
                        },
                        onComplete: ({String? id,required String url}) {
                          print("downloadListener id=$id and onComplete url=$url");
                          onComplete(url);
                        },
                        onError: ({String? id,required String url,String? error}) {
                          print(
                              "downloadListener onError id=$id and url=$url , error=$error");
                          onError(url, error);
                        },
                      )
                  );
                  //or add downloadListener separately
                  // DownloaderPlugin.addDownloadListener(
                  //     id: url,
                  //     downloadListener: DownloadListener(
                  //         onProgress: ({String? id,required String url,required int progress})
                  //         {
                  //       print(
                  //           "separate downloadListener onProgress id=$id and url=$url and progress = $progress");
                  //       onProgress(url, progress);
                  //     }, onComplete: ({String? id,required String url}) {
                  //       print("separate downloadListener onComplete id=$id and url=$url");
                  //       onComplete(url);
                  //     }, onError: ({String? id,required String url,String? error}) {
                  //           print(
                  //               "separate downloadListener onError id=$id and url=$url , error=$error");
                  //           onError(url, error);
                  //         }));
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 100,
              color: Colors.yellow,
              child: BlocConsumer<DownloadCubit, DownloadStates>(
                listener: (context, downloadState) {
                  if (downloadState is DownloadProgressState) {
                    print(
                        "BlocConsumer listener onProgress id=${downloadState.id} and url=${downloadState.url} and progress = ${downloadState.progress}");
                    onProgress(downloadState.url,downloadState.progress);
                  }
                  if (downloadState is DownloadCompletedState) {
                    print("BlocConsumer listener onComplete id=${downloadState.id} and url=${downloadState.url}");
                    onComplete(downloadState.url);
                  }
                  if (downloadState is DownloadErrorState) {
                    print(
                        "BlocConsumer listener onError id=${downloadState.id} and url=${downloadState.url} , error=${downloadState.error}");
                    onError(downloadState.url, downloadState.error);
                  }
                },
                builder: (context, downloadState) {
                  if (downloadState is DownloadProgressState) {
                    print(
                        "BlocConsumer builder onProgress id=${downloadState.id} and url=${downloadState.url} and progress = ${downloadState.progress}");

                  }
                  else if (downloadState is DownloadCompletedState) {
                    print("BlocConsumer builder onComplete id=${downloadState.id} and url=${downloadState.url}");

                  }
                  else if (downloadState is DownloadErrorState) {
                    print(
                        "BlocConsumer builder onError id=${downloadState.id} and url=${downloadState.url} , error=${downloadState.error}");
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

