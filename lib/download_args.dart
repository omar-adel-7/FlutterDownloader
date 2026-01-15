import 'dart:io';

import 'package:downloader/downloader_plugin.dart';
import 'package:downloader/src/download_util.dart';
import 'package:path/path.dart';

import 'cubit/download_state.dart';

class DownloadArgs {
  final String downloadLink;
  final String destinationPath;
  final String fileName;
  String? notificationMessage;
  String? notificationProgressMessage;
  String? notificationCompleteMessage;
  void Function(bool)? updateIsDownloaded;
  void Function(String)? onCompleted;
  void Function()? onDeleted;

  String get filePath => join(destinationPath, fileName);

  DownloadArgs({
    required this.downloadLink,
    required this.destinationPath,
    required this.fileName,
    this.notificationMessage,
    this.notificationProgressMessage,
    this.notificationCompleteMessage,
    this.updateIsDownloaded,
    this.onCompleted,
    this.onDeleted,
  });

  void updateIsDownloadedWork([bool? value]) {
    if (updateIsDownloaded != null) {
      value = value ?? DownloaderPlugin.isFileByArgsExist(this);
      updateIsDownloaded!(value);
    }
  }

  void baseCompletedListen(String url, DownloadStates downloadState) {
    if(downloadState is DownloadCompletedState &&
        downloadState.url == url &&
        DownloaderPlugin.isFileByArgsExist(this))
      {
        updateIsDownloadedWork(true);
        if (onCompleted != null) {
          onCompleted!(filePath);
        }
      }
  }

  void deleteDownloadedFile() {
    File(filePath).deleteSync();
    _deleteFileWork();
  }

  Future deleteDownloadedFileAsync() async {
    await File(filePath).delete();
    _deleteFileWork();
  }

  void _deleteFileWork() {
    DownloadUtil.sendFileDeleted(downloadLink);
    updateIsDownloadedWork(false);
    if (onDeleted != null) {
      onDeleted!();
    }
  }
}
