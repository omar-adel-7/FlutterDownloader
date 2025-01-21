import 'dart:io';
import 'package:downloader/manager/download_manager.dart';

import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_file_util.dart';
import 'manager/download_model.dart';

class DownloaderPlugin {
  static bool defaultAllowCancel = true;

  static bool defaultSerial = true;

  static bool allowCancel = defaultAllowCancel;

  static bool isSerial = defaultSerial;

  static init(DownloadCubit downloadCubit,
      {bool? allow_cancel, bool? is_serial}) async {
    allowCancel = allow_cancel ?? defaultAllowCancel;
    isSerial = is_serial ?? defaultSerial;
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
    return isFileExist(
        destinationDirPath: destinationDirPath, fileName: fileName);
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
      cancelAndroidDownloadFile(url);
    } else if (isPlatformIos()) {
      cancelIosDownloadFile(url);
    }
  }

  static void cancelAndroidDownloadFile(String url) {
    AndroidDownloadMethodChannel.instance.cancelDownloadFile(url);
  }

  static void cancelIosDownloadFile(String url) {
    IOSDownloadMethodChannel.instance.cancelDownloadFile(url);
  }

  static void cancelAndroidDownloads() {
    AndroidDownloadMethodChannel.instance.cancelDownloads();
  }

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }
}
