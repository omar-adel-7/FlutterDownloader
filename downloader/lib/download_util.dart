import 'dart:io';

import 'download_args.dart';
import 'downloader_plugin.dart';

class DownloadUtil {

  static void downloadFile(DownloadArgs downloadArgs) async {
    DownloaderPlugin.downloadFile(
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

  static bool isFileExist(DownloadArgs downloadArgs) {
    return DownloaderPlugin.isFileDownloaded(
      destinationDirPath: downloadArgs.destinationDirPath,
      fileNameWithoutExtension: downloadArgs.fileNameWithoutExtension,
      extension: downloadArgs.extension,
    );
  }

  static void deleteFile(DownloadArgs downloadArgs) {
    File(downloadArgs.filePath).deleteSync();
  }

  static bool isPlatformAndroid()  {
    return Platform.isAndroid;
  }

  static bool isPlatformIos()  {
    return Platform.isIOS;
  }

}


