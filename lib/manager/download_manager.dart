
import '../download_args.dart';
import '../downloader_plugin.dart';
import 'download_model.dart';

class DownloadManager {
  DownloadManager._();

  static final DownloadManager _instance = DownloadManager._();

  factory DownloadManager() {
    return _instance;
  }

  static final DownloadManager instance = DownloadManager._();

  List<DownloadModel> list = [];

  downloadFile(
      {required String url,
      required String destinationPath,
      required String fileName,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage}) async {

    if (!isInDownloadList(url)) {
      _addDownload(
          url,
          destinationPath,
          fileName,
          androidNotificationMessage,
          androidNotificationProgressMessage,
          androidNotificationCompleteMessage);
      if(DownloaderPlugin.isSerial)
        {
          if (getDownloadsCount() == 1) {
            _startDownload(
                url: url,
                destinationPath: destinationPath,
                fileName: fileName,
                androidNotificationMessage: androidNotificationMessage,
                androidNotificationProgressMessage:
                androidNotificationProgressMessage,
                androidNotificationCompleteMessage:
                androidNotificationCompleteMessage);
          }
        }
      else
        {
          _startDownload(
              url: url,
              destinationPath: destinationPath,
              fileName: fileName,
              androidNotificationMessage: androidNotificationMessage,
              androidNotificationProgressMessage:
              androidNotificationProgressMessage,
              androidNotificationCompleteMessage:
              androidNotificationCompleteMessage);
        }
    }
  }

  cancelUrlDownload(String url) {
    if(DownloaderPlugin.isSerial)
    {
      if (ifCurrentlyDownloading(url)) {
        removeDownload(url);
        _checkToDownloadNext();
      } else {
        removeDownload(url);
      }
    }
    else
    {
      removeDownload(url);
    }
  }

  cancelMultiUrlsDownload(List<String> urlsList) {
    bool foundCurrentlyDownloadingLink = false;
    for (String url in urlsList) {
      DownloadModel? downloadModel = getDownloadIfExist(url);
      if (downloadModel != null) {
        DownloaderPlugin.cancelUrlDownload(url);
        if(DownloaderPlugin.isSerial)
        {
          if (ifCurrentlyDownloading(url)) {
            foundCurrentlyDownloadingLink = true;
            removeDownload(url);
          } else {
            removeDownload(url);
          }
        }
        else
        {
          removeDownload(url);
        }
      }
    }
    if (foundCurrentlyDownloadingLink) {
      _checkToDownloadNext();
    }
  }

  void _startDownload(
      {required String url,
      required String destinationPath,
      required String fileName,
      required String androidNotificationMessage,
      required String androidNotificationProgressMessage,
      required String androidNotificationCompleteMessage}) {
    DownloaderPlugin.startDownload(
        url: url,
        destinationPath: destinationPath,
        fileName: fileName,
        androidNotificationMessage: androidNotificationMessage,
        androidNotificationProgressMessage: androidNotificationProgressMessage,
        androidNotificationCompleteMessage: androidNotificationCompleteMessage);
  }

  void _startDownloadModel(DownloadModel downloadModel) {
    _startDownload(
        url: downloadModel.url,
        destinationPath: downloadModel.destinationPath,
        fileName: downloadModel.fileName,
        androidNotificationMessage: downloadModel.notificationMessage,
        androidNotificationProgressMessage:
            downloadModel.notificationProgressMessage,
        androidNotificationCompleteMessage:
            downloadModel.notificationCompleteMessage);
  }

  int getDownloadsCount() {
    //print("getDownloadsCount list.length=${list.length}");
    return list.length;
  }

  bool isDownloadsNotEmpty() {
    bool isDownloadsNotEmpty = list.isNotEmpty;
    //print("isDownloadsNotEmpty = $isDownloadsNotEmpty");
    return isDownloadsNotEmpty;
  }

  _addDownload(
      String url,
      String destinationPath,
      String fileName,
      String notificationMessage,
      String notificationProgressMessage,
      String notificationCompleteMessage) {
    list.add(DownloadModel(
        url: url,
        destinationPath: destinationPath,
        fileName: fileName,
        notificationMessage: notificationMessage,
        notificationProgressMessage: notificationProgressMessage,
        notificationCompleteMessage: notificationCompleteMessage));
  }

  updateProgress(String url, int progress) {
    int index = list.indexWhere((element) => element.url == url);
    ((index != -1) && (index < list.length))
        ? list[index].progress = progress
        : null;
  }

  removeAndDownloadNext(String url) {
    removeDownload(url);
    _checkToDownloadNext();
  }

  removeDownload(String url) {
    list.removeWhere((item) => item.url == url);
  }

  _checkToDownloadNext() {
    if (isDownloadsNotEmpty()) {
      _startDownloadModel(list[0]);
    }
  }

  bool isInDownloadList(String url) {
    return getDownloadIfExist(url) != null;
  }

  DownloadModel? getDownloadIfExist(String url) {
    for (var downloadModel in list) {
      if (downloadModel.url == url) return downloadModel;
    }
    return null;
  }

  bool ifCurrentlyDownloading(String url) {
    return list.isNotEmpty ? list[0].url == url : false;
  }

  clearDownloads() {
    list.clear();
  }
}
