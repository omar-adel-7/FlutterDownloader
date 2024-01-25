import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'download_file_util.dart';
import 'download_listener.dart';
import 'download_util.dart';

class DownloaderPlugin {
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

  static bool getFileDownloadStatus({
    required String destinationDirPath,
    required String fileNameWithoutExtension,
    required String extension,
  }) {
    return isFileExist(
        destinationDirPath: destinationDirPath,
        fileName: fileNameWithoutExtension + extension);
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

  static cancelAndClearAndroidDownloads() {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.cancelAndClearDownloads();
    }
  }
}
