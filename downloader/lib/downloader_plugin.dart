import 'dart:io';
import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'cubit/download_cubit.dart';
import 'download_args.dart';
import 'download_file_util.dart';
import 'download_listener.dart';

class DownloaderPlugin {
  static String extensionDot = ".";

  static init(DownloadCubit downloadCubit) async {
    AndroidDownloadMethodChannel.instance.init(downloadCubit);
    IOSDownloadMethodChannel.instance.init(downloadCubit);
  }

  static downloadFile(
      {String? id,
      required String url,
      required String destinationPath,
      required String fileNameWithoutExtension,
      required String extension,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage,
      DownloadListener? downloadListener}) async {
    String pathSeparator = Platform.pathSeparator;
    if (!destinationPath.endsWith(pathSeparator)) {
      destinationPath = destinationPath + pathSeparator;
    }
    extension = extensionDot + extension;
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadFile(
          id: id ?? url,
          url: url,
          destinationDirPath: destinationPath,
          fileNameWithoutExtension: fileNameWithoutExtension,
          extension: extension,
          notificationMessage: androidNotificationMessage,
          notificationProgressMessage: androidNotificationProgressMessage,
          notificationCompleteMessage: androidNotificationCompleteMessage,
          downloadListener: downloadListener);
    } else if (isPlatformIos()) {
      String fileName = fileNameWithoutExtension + extension;
      IOSDownloadMethodChannel.instance.downloadFile(
          id: id ?? url,
          url: url,
          destinationDirPath: destinationPath,
          fileName: fileName,
          downloadListener: downloadListener);
    }
  }

  static void downloadFileByArgs(
      {required DownloadArgs downloadArgs,
      DownloadListener? downloadListener}) async {
    downloadFile(
        id: downloadArgs.id,
        url: downloadArgs.downloadLink,
        destinationPath: downloadArgs.destinationDirPath,
        extension: downloadArgs.extension,
        fileNameWithoutExtension: downloadArgs.fileNameWithoutExtension,
        androidNotificationMessage: downloadArgs.androidNotificationTitle,
        androidNotificationProgressMessage:
            downloadArgs.androidNotificationProgressMessage,
        androidNotificationCompleteMessage:
            downloadArgs.androidNotificationCompleteMessage,
        downloadListener: downloadListener);
  }

  static addDownloadListener(
      {required String id, required DownloadListener downloadListener}) {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance
          .addDownloadListener(id: id, downloadListener: downloadListener);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance
          .addDownloadListener(id: id, downloadListener: downloadListener);
    }
  }

  static bool isFileDownloaded({
    required String destinationDirPath,
    required String fileNameWithoutExtension,
    required String extension,
  }) {
    extension = extensionDot + extension;
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

  static bool isPlatformAndroid() {
    return Platform.isAndroid;
  }

  static bool isPlatformIos() {
    return Platform.isIOS;
  }
}
