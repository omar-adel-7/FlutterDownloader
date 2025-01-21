import 'dart:io';
import 'package:downloader/src/manager/download_manager.dart';
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
        androidNotificationProgressMessage:
        androidNotificationProgressMessage,
        androidNotificationCompleteMessage:
        androidNotificationCompleteMessage);
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

  static void startDownload(
      {required String url,
        required String destinationPath,
        required String fileName,
        required String androidNotificationMessage,
        required String androidNotificationProgressMessage,
        required String androidNotificationCompleteMessage}) async {
    String pathSeparator = Platform.pathSeparator;
    if (!destinationPath.endsWith(pathSeparator)) {
      destinationPath = destinationPath + pathSeparator;
    }
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadFile(
          url: url,
          destinationDirPath: destinationPath,
          fileName: fileName,
          notificationMessage: androidNotificationMessage,
          notificationProgressMessage: androidNotificationProgressMessage,
          notificationCompleteMessage: androidNotificationCompleteMessage);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance.downloadFile(
          url: url, destinationDirPath: destinationPath, fileName: fileName);
    }
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

  static void deleteFile(DownloadArgs downloadArgs) {
    File(downloadArgs.filePath).deleteSync();
  }

  static Future deleteFileAsync(DownloadArgs downloadArgs) async {
    return await File(downloadArgs.filePath).delete();
  }

  static cancelDownloadFile(String url) async {
    cancelUrlDownload(url);
    DownloadManager().cancelUrlDownload(url);
  }

  static cancelDownloadMultiFiles(List<String> urlsList) async {
    DownloadManager().cancelMultiUrlsDownload(urlsList);
  }


  static void cancelUrlDownload(String url) {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelDownloadFile(url);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance.cancelDownloadFile(url);
    }
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
