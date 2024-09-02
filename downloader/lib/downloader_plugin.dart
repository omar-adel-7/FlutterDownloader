import 'dart:io';
import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'download_file_util.dart';
import 'download_listener.dart';
import 'download_util.dart';

class DownloaderPlugin {
  static String extensionDot=".";
  static init() async {
    AndroidDownloadMethodChannel.instance.init();
    IOSDownloadMethodChannel.instance.init();
  }

  static downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage,
        DownloadListener? downloadListener}) async {
    String pathSeparator = Platform.pathSeparator ;
    if(!destinationDirPath.endsWith(pathSeparator))
      {
        destinationDirPath=destinationDirPath+pathSeparator;
      }
    extension=extensionDot+extension;
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadFile(
          url: url,
          destinationDirPath: destinationDirPath,
          fileNameWithoutExtension: fileNameWithoutExtension,
          extension: extension,
          notificationMessage: androidNotificationMessage,
          notificationProgressMessage: androidNotificationProgressMessage,
          notificationCompleteMessage: androidNotificationCompleteMessage,
          downloadListener: downloadListener);
    } else if (isPlatformIos()) {
      String fileName = fileNameWithoutExtension + extension;
      IOSDownloadMethodChannel.instance.downloadFile(
          url: url,
          destinationDirPath: destinationDirPath,
          fileName: fileName,
          downloadListener: downloadListener);
    }
  }

  static addDownloadListener(
      {required String url,
      required DownloadListener downloadListener}) {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance
          .addDownloadListener(url: url, downloadListener: downloadListener);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance
          .addDownloadListener(url: url, downloadListener: downloadListener);
    }
  }

  static Future<bool> isFileDownloading(String url) async {
    if (isPlatformAndroid()) {
      return await AndroidDownloadMethodChannel.instance.isFileDownloading(url);
    }
    return false ;
  }

  static bool isFileDownloaded({
    required String destinationDirPath,
    required String fileNameWithoutExtension,
    required String extension,
  }) {
    extension=extensionDot+extension;
    return isFileExist(
        destinationDirPath: destinationDirPath,
        fileName: fileNameWithoutExtension + extension);
  }


  static cancelAndClearAndroidDownloads() {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelAndClearDownloads();
    }
  }
}
