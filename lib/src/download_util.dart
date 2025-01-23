import 'package:downloader/downloader_plugin.dart';
import 'method_channels/android_download_method_channel.dart';
import 'method_channels/ios_download_method_channel.dart';
import 'dart:io';

class DownloadUtil {

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
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadFile(
          url: url,
          destinationDirPath: destinationPath,
          fileName: fileName,
          notificationMessage: androidNotificationMessage,
          notificationProgressMessage: androidNotificationProgressMessage,
          notificationCompleteMessage: androidNotificationCompleteMessage);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.downloadFile(
          url: url, destinationDirPath: destinationPath, fileName: fileName);
    }
  }

  static void cancelUrlDownload(String url) {
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelDownloadFile(url);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.cancelDownloadFile(url);
    }
  }

  static void sendCanceled(String url) {
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadCubit.publishCanceled(url);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.downloadCubit.publishCanceled(url);
    }
  }

  static void sendFileDeleted(String url) {
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadCubit.publishFileDeleted(url);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.downloadCubit.publishFileDeleted(url);
    }
  }
}
