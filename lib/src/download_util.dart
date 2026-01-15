import 'package:downloader/downloader_plugin.dart';
import 'method_channels/android_download_method_channel.dart';
import 'method_channels/ios_download_method_channel.dart';
import 'dart:io';

class DownloadUtil {

  static void startAndroidDownload(
      {required String url,
        required String destinationPath,
        required String fileName,
        String? notificationMessage,
        String? notificationProgressMessage ,String? notificationCompleteMessage
      }) async {
    String pathSeparator = Platform.pathSeparator;
    if (!destinationPath.endsWith(pathSeparator)) {
      destinationPath = destinationPath + pathSeparator;
    }
      AndroidDownloadMethodChannel.instance.downloadFile( url: url,
          destinationPath: destinationPath,
          fileName: fileName,
          notificationMessage: notificationMessage ,
          notificationProgressMessage: notificationProgressMessage ,
          notificationCompleteMessage: notificationCompleteMessage );
  }

  static void startIosDownload(
      {required String url,
        required String destinationPath,
        required String fileName}) async {
    String pathSeparator = Platform.pathSeparator;
    if (!destinationPath.endsWith(pathSeparator)) {
      destinationPath = destinationPath + pathSeparator;
    }
      IOSDownloadMethodChannel.instance.downloadFile(
          url: url, destinationPath: destinationPath, fileName: fileName);
  }

  static void cancelUrlDownload(String url) {
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelDownloadFile(url);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.cancelDownloadFile(url);
    }
  }

  static void sendIosCanceled(String url) {
      IOSDownloadMethodChannel.instance.downloadCubit.publishCanceled(url:url);
  }

  static void sendFileDeleted(String url) {
    if (DownloaderPlugin.isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadCubit.publishFileDeleted(url);
    } else if (DownloaderPlugin.isPlatformIos()) {
      IOSDownloadMethodChannel.instance.downloadCubit.publishFileDeleted(url);
    }
  }
}
