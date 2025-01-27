import 'dart:io';
import 'package:downloader/src/download_manager.dart';
import 'package:downloader/src/download_util.dart';
import 'package:downloader/src/method_channels/android_download_method_channel.dart';
import 'package:downloader/src/method_channels/ios_download_method_channel.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_model.dart';

class DownloaderPlugin {
  static bool defaultAllowCancel = false;
  static bool defaultIsSerial = true;
  static String defaultAndroidParallelMainNotificationMessage =
      "download service working now";
  static bool allowCancel = defaultAllowCancel;
  static bool isSerial = defaultIsSerial;
  static String androidParallelMainNotificationMessage =
      defaultAndroidParallelMainNotificationMessage;
  static String defaultAdroidNotificationProgressMessage = "downloading : ";
  static String defaultAndroidNotificationCompleteMessage =
      "completed download of : ";
  static String androidNotificationProgressMessage =
      defaultAdroidNotificationProgressMessage;
  static String androidNotificationCompleteMessage =
      defaultAndroidNotificationCompleteMessage;
  static SharedPreferences? androidSharedPreferences;

  static const String DOWNLOADER_LIST_ITEM_INTERNAL_KEY = "downloader-internal";
  static const String DOWNLOADER_LIST_DIVIDER_KEY = "downloader-divider";

  static init(DownloadCubit downloadCubit,
      {bool? allow_cancel,
      bool? is_serial,
      String? android_parallel_main_notification_message,
      String? android_notification_progress_message,
      String? android_notification_complete_message}) async {
    allowCancel = allow_cancel ?? defaultAllowCancel;
    isSerial = is_serial ?? defaultIsSerial;
    androidParallelMainNotificationMessage =
        android_parallel_main_notification_message ??
            defaultAndroidParallelMainNotificationMessage;
    androidNotificationProgressMessage =
        android_notification_progress_message ??
            defaultAdroidNotificationProgressMessage;
    androidNotificationCompleteMessage =
        android_notification_complete_message ??
            defaultAndroidNotificationCompleteMessage;

    if (isPlatformAndroid()) {
      androidSharedPreferences = await SharedPreferences.getInstance();
      androidSharedPreferences?.setBool('isSerial', isSerial);
      androidSharedPreferences?.setString('parallelMainNotificationMessage',
          androidParallelMainNotificationMessage);
      androidSharedPreferences?.setString(
          'notificationProgressMessage', androidNotificationProgressMessage);
      androidSharedPreferences?.setString(
          'notificationCompleteMessage', androidNotificationCompleteMessage);
    }
    AndroidDownloadMethodChannel.instance.init(downloadCubit);
    IOSDownloadMethodChannel.instance.init(downloadCubit);
  }

  static downloadFile(
      {required String url,
      required String destinationPath,
      required String fileName,
      required String androidNotificationMessage}) {
    DownloadManager().downloadFile(
        url: url,
        destinationPath: destinationPath,
        fileName: fileName,
        androidNotificationMessage: androidNotificationMessage);
  }

  static void downloadFileByArgs(DownloadArgs downloadArgs) {
    downloadFile(
        url: downloadArgs.downloadLink,
        destinationPath: downloadArgs.destinationDirPath,
        fileName: downloadArgs.fileName,
        androidNotificationMessage: downloadArgs.androidNotificationMessage);
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

  static cancelDownloadFile(String url) {
    DownloadManager().cancelUrlDownload(url);
  }

  static cancelDownloadMultiFiles(List<String> urlsList) {
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

  static clearDownloadsList() {
    DownloadManager().clearDownloadsList();
  }

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }
}
