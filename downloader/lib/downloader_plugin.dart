import 'dart:io';
import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_file_util.dart';

class DownloaderPlugin {

  static init(DownloadCubit downloadCubit) async {
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
          url: url,
          destinationDirPath: destinationPath,
          fileName: fileName);
    }
  }

  static void downloadFileByArgs(
      {required DownloadArgs downloadArgs}) async {
    downloadFile(
        url: downloadArgs.downloadLink,
        destinationPath: downloadArgs.destinationDirPath,
        fileName: downloadArgs.fileName,
        androidNotificationMessage: downloadArgs.androidNotificationTitle,
        androidNotificationProgressMessage:
            downloadArgs.androidNotificationProgressMessage,
        androidNotificationCompleteMessage:
            downloadArgs.androidNotificationCompleteMessage);
  }

  static bool isFileDownloaded({
    required String destinationDirPath,
    required String fileName,
  }) {
    return isFileExist(
        destinationDirPath: destinationDirPath,
        fileName: fileName );
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

  static void cancelAndroidCurrentDownload() {
    AndroidDownloadMethodChannel.instance.cancelCurrentDownload();
  }

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }

}
