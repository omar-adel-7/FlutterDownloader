import '../method_channels/android_download_method_channel.dart';
import '../method_channels/ios_download_method_channel.dart';
import 'download_file_utils.dart';
import 'download_listener.dart';
import 'download_utils.dart';

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
      required String notificationMessage,
      String? androidNotificationProgressMessage,
      String? androidNotificationCompleteMessage,
      String? androidErrorMessage,
      DownloadListener? downloadListener}) async {
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.downloadFile(
          url,
          fileNameWithoutExtension,
          extension,
          destinationDirPath,
          notificationMessage,
          androidNotificationProgressMessage,
          androidNotificationCompleteMessage,
          androidErrorMessage,
          downloadListener);
    } else if (isPlatformIos()) {
      String fileName = fileNameWithoutExtension + extension;
      IOSDownloadMethodChannel.instance
          .downloadFile(url, fileName, destinationDirPath, downloadListener);
    }
  }

  static bool getFileDownloadStatus(String destinationDirPath,
      String fileNameWithoutExtension, String extension) {
    return isFileExist(
        destinationDirPath: destinationDirPath,
        fileName: fileNameWithoutExtension + extension);
  }
  static addDownloadListener(String url,DownloadListener downloadListener){
    if (isPlatformAndroid()) {
      AndroidDownloadMethodChannel.instance.addDownloadListener(url,downloadListener);
    } else if (isPlatformIos()) {
      IOSDownloadMethodChannel.instance.addDownloadListener(url,downloadListener);
     }
  }
}
