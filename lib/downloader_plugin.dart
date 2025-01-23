import 'dart:io';
import 'package:downloader/src/download_manager.dart';
import 'package:downloader/src/download_util.dart';
import 'package:downloader/src/method_channels/android_download_method_channel.dart';
import 'package:downloader/src/method_channels/ios_download_method_channel.dart';
import 'package:path/path.dart';

import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_model.dart';

class DownloaderPlugin {
  static bool defaultAllowCancel = false;

  static bool defaultIsSerial = true;

  static bool allowCancel = defaultAllowCancel;

  static bool isSerial = defaultIsSerial;

  static init(DownloadCubit downloadCubit,
      {bool? allow_cancel, bool? is_serial}) async {
    allowCancel = allow_cancel ?? defaultAllowCancel;
    isSerial = is_serial ?? defaultIsSerial;
    AndroidDownloadMethodChannel.instance.init(downloadCubit);
    IOSDownloadMethodChannel.instance.init(downloadCubit);
  }

  static downloadFile(
      {required String url,
      required String destinationPath,
      required String fileName,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage}) async {
    DownloadManager().downloadFile(
        url: url,
        destinationPath: destinationPath,
        fileName: fileName,
        androidNotificationMessage: androidNotificationMessage,
        androidNotificationProgressMessage: androidNotificationProgressMessage,
        androidNotificationCompleteMessage: androidNotificationCompleteMessage);
  }

  static void downloadFileByArgs({required DownloadArgs downloadArgs}) async {
    downloadFile(
        url: downloadArgs.downloadLink,
        destinationPath: downloadArgs.destinationDirPath,
        fileName: downloadArgs.fileName,
        androidNotificationMessage: downloadArgs.androidNotificationMessage,
        androidNotificationProgressMessage:
            downloadArgs.androidNotificationProgressMessage,
        androidNotificationCompleteMessage:
            downloadArgs.androidNotificationCompleteMessage);
  }

  static bool isFileDownloaded({
    required String destinationDirPath,
    required String fileName,
  }) {
    String path = join(destinationDirPath, fileName);
    return File(path).existsSync();
  }

  static bool isFileDownloadedByArgs(DownloadArgs downloadArgs) {
    return isFileDownloaded(
      destinationDirPath: downloadArgs.destinationDirPath,
      fileName: downloadArgs.fileName,
    );
  }

  static void deleteDownloadedFile(DownloadArgs downloadArgs) {
    File(downloadArgs.filePath).deleteSync();
    DownloadUtil.sendFileDeleted(downloadArgs.downloadLink);
  }

  static Future deleteDownloadedFileAsync(DownloadArgs downloadArgs) async {
      await File(downloadArgs.filePath).delete();
      DownloadUtil.sendFileDeleted(downloadArgs.downloadLink);
  }

  static cancelDownloadFile(String url) async {
    DownloadUtil.cancelUrlDownload(url);
    DownloadManager().cancelUrlDownload(url);
  }

  static cancelDownloadMultiFiles(List<String> urlsList) async {
    DownloadManager().cancelMultiUrlsDownload(urlsList);
  }

  static void cancelAndroidDownloads() {
    AndroidDownloadMethodChannel.instance.cancelDownloads();
  }

  static bool isInDownloadList(String url) {
    return DownloadManager().isInDownloadList(url);
  }

  static DownloadModel? getDownloadIfExist(String url) {
    return DownloadManager().getDownloadIfExist(url);
  }

  static bool isDownloadsNotEmpty() {
    return DownloadManager().isDownloadsNotEmpty();
  }

  static clearDownloads() {
    DownloadManager().clearDownloads();
  }

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }
}
