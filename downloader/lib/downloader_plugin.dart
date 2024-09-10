import 'dart:io';
import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_file_util.dart';

class DownloaderPlugin {
  static String extensionDot=".";
  static init({DownloadCubit? downloadCubit}) async {
    AndroidDownloadMethodChannel.instance.init(downloadCubit);
    IOSDownloadMethodChannel.instance.init(downloadCubit);
  }

  static downloadFile(
      {required String url,
      required String destinationDirPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage}) async {
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
          notificationCompleteMessage: androidNotificationCompleteMessage);
    } else if (isPlatformIos()) {
      String fileName = fileNameWithoutExtension + extension;
      IOSDownloadMethodChannel.instance.downloadFile(
          url: url,
          destinationDirPath: destinationDirPath,
          fileName: fileName);
    }
  }

  static void downloadFileByArgs(DownloadArgs downloadArgs) async {
    downloadFile(
      url: downloadArgs.downloadLink,
      destinationDirPath: downloadArgs.destinationDirPath,
      extension: downloadArgs.extension,
      fileNameWithoutExtension: downloadArgs.fileNameWithoutExtension,
      androidNotificationMessage: downloadArgs.androidNotificationTitle,
      androidNotificationProgressMessage:
      downloadArgs.androidNotificationProgressMessage,
      androidNotificationCompleteMessage:
      downloadArgs.androidNotificationCompleteMessage,
    );
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

  static bool isFileDownloadedByArgs(DownloadArgs downloadArgs) {
    return isFileDownloaded(
      destinationDirPath: downloadArgs.destinationDirPath,
      fileNameWithoutExtension: downloadArgs.fileNameWithoutExtension,
      extension: downloadArgs.extension,
    );
  }

  static void deleteFile(DownloadArgs downloadArgs) {
    File(downloadArgs.filePath).deleteSync();
  }

  static cancelAndClearAndroidDownloads() {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelAndClearDownloads();
    }
  }

  static bool isPlatformAndroid()  {
    return Platform.isAndroid;
  }

  static bool isPlatformIos()  {
    return Platform.isIOS;
  }

}
