import 'dart:io';
import 'package:downloader/cubit/download_state.dart';
import 'package:downloader/src/download_manager.dart';
import 'package:downloader/src/download_model.dart';
import 'package:downloader/src/download_util.dart';
import 'package:downloader/src/method_channels/android_download_method_channel.dart';
import 'package:downloader/src/method_channels/ios_download_method_channel.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubit/download_cubit.dart';
import 'download_args.dart';

class DownloaderPlugin {
  static bool defaultIsSerial = true;
  static bool isSerial = defaultIsSerial;
  static bool defaultShowIosNotifications = false;
  static bool showIosNotifications = defaultShowIosNotifications;
  static String defaultAndroidParallelMainNotificationMessage =
      "download service working now";
  static String androidParallelMainNotificationMessage =
      defaultAndroidParallelMainNotificationMessage;
  static String defaultNotificationProgressMessage = "downloading : ";
  static String notificationProgressMessage =
      defaultNotificationProgressMessage;
  static String defaultNotificationCompleteMessage = "completed download of : ";
  static String notificationCompleteMessage =
      defaultNotificationCompleteMessage;
  static SharedPreferences? androidSharedPreferences;
  static const String ANDROID_DOWNLOADER_LIST_ITEM_INTERNAL_KEY =
      "downloader-internal";
  static const String ANDROID_DOWNLOADER_LIST_DIVIDER_KEY =
      "downloader-divider";

  static init(DownloadCubit downloadCubit,
      {bool? is_serial,
      bool? show_ios_notifications,
      String? android_parallel_main_notification_message,
      String? notification_progress_message,
      String? notification_complete_message}) async {
    isSerial = is_serial ?? defaultIsSerial;
    showIosNotifications =
        show_ios_notifications ?? defaultShowIosNotifications;
    if (isPlatformAndroid()) {
      androidSharedPreferences = await SharedPreferences.getInstance();
      androidSharedPreferences?.setBool('isSerial', isSerial);
    }
    if (android_parallel_main_notification_message != null ||
        notification_progress_message != null ||
        notification_complete_message != null) {
      initNotificationStrings(
          android_parallel_main_notification_message:
              android_parallel_main_notification_message,
          notification_progress_message: notification_progress_message,
          notification_complete_message: notification_complete_message);
    }
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.init(downloadCubit);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance.init(downloadCubit);
    }
  }

  static initNotificationStrings(
      {String? android_parallel_main_notification_message,
      String? notification_progress_message,
      String? notification_complete_message}) async {
    androidParallelMainNotificationMessage =
        android_parallel_main_notification_message ??
            androidParallelMainNotificationMessage;
    notificationProgressMessage =
        notification_progress_message ?? notificationProgressMessage;
    notificationCompleteMessage =
        notification_complete_message ?? notificationCompleteMessage;
    if (isPlatformAndroid()) {
      androidSharedPreferences = await SharedPreferences.getInstance();
      androidSharedPreferences?.setString('parallelMainNotificationMessage',
          androidParallelMainNotificationMessage);
      androidSharedPreferences?.setString(
          'defaultNotificationProgressMessage', notificationProgressMessage);
      androidSharedPreferences?.setString(
          'defaultNotificationCompleteMessage', notificationCompleteMessage);
    }
  }

  static downloadFile({
    required String url,
    required String destinationPath,
    required String fileName,
    String? notificationMessage,
    String? notificationProgressMessage,
    String? notificationCompleteMessage,
    bool? androidCancel,
  }) {
    if (url.isNotEmpty) {
      DownloadManager().downloadFile(
        url: url,
        destinationPath: destinationPath,
        fileName: fileName,
        notificationMessage: notificationMessage,
        notificationProgressMessage: notificationProgressMessage,
        notificationCompleteMessage: notificationCompleteMessage,
        androidCancel: androidCancel
      );
    }
  }

  static void downloadFileByArgs(DownloadArgs downloadArgs) {
    downloadFile(
        url: downloadArgs.downloadLink,
        destinationPath: downloadArgs.destinationDirPath,
        fileName: downloadArgs.fileName,
        notificationMessage: downloadArgs.notificationMessage,
        notificationProgressMessage: downloadArgs.notificationProgressMessage,
        notificationCompleteMessage: downloadArgs.notificationCompleteMessage);
  }

  static bool isFileExist({
    required String destinationDirPath,
    required String fileName,
  }) {
    String path = join(destinationDirPath, fileName);
    return File(path).existsSync();
  }

  static bool isFileByArgsExist(DownloadArgs downloadArgs) {
    return isFileExist(
      destinationDirPath: downloadArgs.destinationDirPath,
      fileName: downloadArgs.fileName,
    );
  }

  static void deleteDownloadedFile(String filePath, {String? downloadLink}) {
    File(filePath).deleteSync();
    if (downloadLink != null) {
      DownloadUtil.sendFileDeleted(downloadLink);
    }
  }

  static void deleteDownloadedFileByArgs(DownloadArgs downloadArgs) {
    downloadArgs.deleteDownloadedFile();
  }

  static Future deleteDownloadedFileAsync(String filePath,
      {String? downloadLink}) async {
    await File(filePath).delete();
    if (downloadLink != null) {
      DownloadUtil.sendFileDeleted(downloadLink);
    }
  }

  static Future deleteDownloadedFileAsyncByArgs(
      DownloadArgs downloadArgs) async {
    downloadArgs.deleteDownloadedFileAsync();
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

  static void cancelIosDownloads() {
    IOSDownloadMethodChannel.instance.cancelDownloads();
  }

  static bool isDownloadsNotEmpty() {
    return DownloadManager().isDownloadsNotEmpty();
  }

  static clearDownloadsList() {
    DownloadManager().clearDownloadsList();
  }

  static bool isInDownloadList(String url) {
    return DownloadManager().isInDownloadList(url);
  }

  static int? getUrlProgress(String url, DownloadStates downloadState) {
    if (downloadState is DownloadProgressState && downloadState.url == url) {
      return downloadState.progress;
    } else {
      DownloadModel? downloadModel = _getDownloadIfExist(url);
      if (downloadModel != null) {
        return downloadModel.progress;
      }
      return null;
    }
  }

  static bool isUrlDownloaded(String url, DownloadStates downloadState,
      {String? destinationDirPath, String? fileName}) {
    bool checkFile = (destinationDirPath != null) && (fileName != null);
    if (checkFile) {
      bool checkFileResult = isFileExist(
          destinationDirPath: destinationDirPath, fileName: fileName);
      if (checkFileResult &&
          downloadState is DownloadCompletedState &&
          downloadState.url == url) {
        return true;
      }
    } else {
      if (downloadState is DownloadCompletedState && downloadState.url == url) {
        return true;
      }
    }
    return false;
  }

  static bool isToBuildByUrl(String url, DownloadStates downloadState) {
     return  downloadState is DownloadInitialState ||
         (downloadState is DownloadAddedState && downloadState.url == url) ||
         (downloadState is DownloadProgressState && downloadState.url == url) ||
         (downloadState is DownloadCompletedState && downloadState.url == url) ||
         (downloadState is DownloadFileDeletedState && downloadState.url == url) ||
         (downloadState is DownloadErrorState && downloadState.url == url);
  }

  static DownloadModel? _getDownloadIfExist(String url) {
    return DownloadManager().getDownloadIfExist(url);
  }

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }
}
